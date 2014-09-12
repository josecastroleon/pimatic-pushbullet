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

    if it is 08:00 push title:"Good morning!" message:"Good morning Dave!"

in general: if X then push title:

    "title of the push notification" message:"message for the notification"
