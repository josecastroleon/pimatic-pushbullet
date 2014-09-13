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

      # Helper to convert 'some text' to [ '"some text"' ]
      strToTokens = (str) => ["\"#{str}\""]

      titleTokens = strToTokens defaultTitle
      messageTokens = strToTokens defaultMessage
      device = defaultDevice

      setTitle = (m, tokens) => titleTokens = tokens
      setMessage = (m, tokens) => messageTokens = tokens

      m = M(input, context)
        .match('send ', optional: yes)
        .match(['push','pushbullet','notification'])

      next = m.match(' title:').matchStringWithVars(setTitle)
      if next.hadMatch() then m = next

      next = m.match(' message:').matchStringWithVars(setMessage)
      if next.hadMatch() then m = next

      if m.hadMatch()
        match = m.getFullMatch()

        assert Array.isArray(titleTokens)
        assert Array.isArray(messageTokens)

        return {
          token: match
          nextInput: input.substring(match.length)
          actionHandler: new PushbulletActionHandler(
            @framework, titleTokens, messageTokens, device
          )
        }
            

  class PushbulletActionHandler extends env.actions.ActionHandler 

    constructor: (@framework, @titleTokens, @messageTokens, @device) ->

    executeAction: (simulate, context) ->
      Promise.all( [
        @framework.variableManager.evaluateStringExpression(@titleTokens)
        @framework.variableManager.evaluateStringExpression(@messageTokens)
      ]).then( ([title, message]) =>
        if simulate
          # just return a promise fulfilled with a description about what we would do.
          return __("would push message \"%s\" with title \"%s\"", message, title)
        else
          return pusherService.noteAsync(@device, title, message).then( =>
            __("pushbullet message sent successfully") 
          )
      )

  module.exports.PushbulletActionHandler = PushbulletActionHandler

  # and return it to the framework.
  return plugin   
