# Pushbullet Plugin

# This is an plugin to send push notifications via pushbullet

module.exports = (env) ->

  Promise = env.require 'bluebird'
  assert = env.require 'cassert'
  util = env.require 'util'
  M = env.matcher

  PushBullet = require('pushbullet');
  Promise.promisifyAll(PushBullet.prototype)
  
  pusherService = null

  class PushbulletPlugin extends env.plugins.Plugin

    init: (app, @framework, config) =>
      apikey = config.apikey
      env.logger.debug "apikey= #{apikey}"
      pusherService = new PushBullet(apikey)
      
      @framework.ruleManager.addActionProvider(new PushbulletActionProvider @framework, config)

  plugin = new PushbulletPlugin()

  class PushbulletActionProvider extends env.actions.ActionProvider
  
    constructor: (@framework, @config) ->
      return

    parseAction: (input, context) =>

      defaultTitle = @config.title
      defaultMessage = @config.message
      defaultDevice = @config.device
      defaultType = @config.type
        
      if @config.channeltag != "" then defaultDevice = {channel_tag: @config.channeltag}

      # Helper to convert 'some text' to [ '"some text"' ]
      strToTokens = (str) => ["\"#{str}\""]
      # Helper to convert [ '"some text"' ] to 'some text'
      tokensToStr = (tokens) => tokens[0].replace(/\'|\"/g, "")

      titleTokens = strToTokens defaultTitle
      messageTokens = strToTokens defaultMessage
      typeTokens = strToTokens defaultType
      device = defaultDevice

      setTitle = (m, tokens) => titleTokens = tokens
      setMessage = (m, tokens) => messageTokens = tokens
      setType = (m, tokens) => typeTokens = tokens
      setChannel = (m, tokens) => device = {channel_tag: tokensToStr tokens}

      m = M(input, context)
        .match('send ', optional: yes)
        .match(['push','pushbullet','notification'])

      next = m.match(' title:').matchStringWithVars(setTitle)
      if next.hadMatch() then m = next

      next = m.match(' message:').matchStringWithVars(setMessage)
      if next.hadMatch() then m = next

      next = m.match(' type:').matchStringWithVars(setType)
      if next.hadMatch() then m = next

      next = m.match(' channel:').matchStringWithVars(setChannel)
      if next.hadMatch() then m = next

      if m.hadMatch()
        match = m.getFullMatch()

        assert Array.isArray(titleTokens)
        assert Array.isArray(messageTokens)
        assert Array.isArray(typeTokens)

        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new PushbulletActionHandler(
            @framework, titleTokens, messageTokens, typeTokens, device
          )
        }
            

  class PushbulletActionHandler extends env.actions.ActionHandler 

    constructor: (@framework, @titleTokens, @messageTokens, @typeTokens, @device) ->

    executeAction: (simulate, context) ->
      Promise.all( [
        @framework.variableManager.evaluateStringExpression(@titleTokens)
        @framework.variableManager.evaluateStringExpression(@messageTokens)
        @framework.variableManager.evaluateStringExpression(@typeTokens)
      ]).then( ([title, message, type]) =>
        switch type
          when "file"
            if simulate
              return __("would send file \"%s\" with title \"%s\"", message, title)
            else
              try
                return pusherService.fileAsync(@device, message, title).then( =>
                  __("pushbullet file sent successfully")
                )
              catch e
                return __("File not found!") if e.code is "ENOENT"
          when "note"
            if simulate
              return __("would push message \"%s\" with title \"%s\"", message, title)
            else
              return pusherService.noteAsync(@device, title, message).then( =>
                __("pushbullet message sent successfully") 
              )
      )

  module.exports.PushbulletActionHandler = PushbulletActionHandler

  # and return it to the framework.
  return plugin   
