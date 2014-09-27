pimatic-pushbullet
=======================

A plugin for sending [pushbullet](https://www.pushbullet.com/) notifications in pimatic.

Configuration
-------------
You can load the backend by editing your `config.json` to include:

    {
      "plugin": "pushbullet",
      "apikey": "xxxxxxxxxxxxxxxxxxxxxxxxxx"
    }

in the `plugins` section. For all configuration options see 
[pushbullet-config-schema](pushbullet-config-schema.coffee)

Currently you can send pushbullet notifications via action handler within rules.

Example:
--------
By default if the type is not specified it sends a note notification

    if it is 08:00 push title:"Good morning!" message:"Good morning Dave!"

if you want to send a file you need to specify 'file' as type and in the message the location of the file like:

    if it is 10:00 push title:"Good morning!" message:"/home/pi/photo.jpg" type:"file"

in general:

    if X then push title: "title of the push notification" message: "message for the notification" type: "note|file"
