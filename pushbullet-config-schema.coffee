module.exports = {
  title: "pushbullet config options"
  type: "object"
  properties: 
    apikey:
      description:"Pushbullet api key"
      type: "string"
      required: yes
    device:
      description:"device to send the notification to"
      type: "number"
      default: 0
    title:
      description:"Default title for notification"
      type: "string"
      default: "title"
    message:
      description:"Default message or file for notification"
      type: "string"
      default: "message"
    type:
      description:"Default type of notification"
      type: "string"
      default: "note"
}
