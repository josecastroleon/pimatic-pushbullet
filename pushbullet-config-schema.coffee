module.exports = {
  title: "pushbullet config options"
  type: "object"
  properties: 
    apikey:
      description:"Pushbullet api key"
      type: "string"
      required: yes
    device:
      description:"Device nickname to send the notification to. Note, a channeltag will take precedence over device"
      type: "string"
      default: ""
    title:
      description:"Default title for notification"
      type: "string"
      default: "message title"
    message:
      description:"Default message, link URL or file path for notification"
      type: "string"
      default: "message text"
    type:
      description:"Default type of notification"
      enum: ["note", "link", "file"]
      default: "note"
    channeltag:
      description:"Channel tag to send the notification to"
      type: "string"
      default: ""
}
