# rdphelper

A simple and fast xfreerdp helper script for handling lots of hosts.

## Prerequisites

* [xfreerdp](http://www.freerdp.com)
* [ruby](https://www.ruby-lang.org)
* [fuzz](https://github.com/hrs/fuzz)
* one of the "pickers" supported by fuzz (e.g. [rofi](https://github.com/DaveDavenport/rofi))

## Note

Make sure your hostgroups-file is only accessible by yourself.

## To-Do / Ideas

* store passwords securely (keyring? pass? encrypted hostgroups-file?...)
* read settings (window geometry, keyboard layout, picker, etc.) from config file
* preselect group (and host) via command line parameters
* handle certificate changes
* read/convert RDCMan's .rdg-files
* read/convert Remminas's .remmina-files
* support for quick connections
* error handling
* ...