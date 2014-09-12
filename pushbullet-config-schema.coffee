module.exports = {
  title: "pushbullet config options"
  type: "object"
  properties: 
    apikey:
      description:"Pushbullet api key"
      type: "string"
      required: yes
    device: #might be overwritten by predicate, not implemented yet
      description:"device to send the notifcation to"
      type: "string"
      default: ""
}
