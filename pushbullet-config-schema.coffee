module.exports = {
  title: "pushbullet config options"
  type: "object"
  properties: 
    apikey:
      description:"Pushbullet api key"
      type: "string"
      required: yes
    device:
      description:"device to send the notifcation to"
      type: "number"
      default: 0
}
