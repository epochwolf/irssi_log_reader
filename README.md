== Title of App ==
Explain the application

== Irssi Autolog Configuration ==
This program is designed to work with irssi's logging functionality. 

These are the settings I use for my logs. I find a need for daily log rotation.

    log_theme = default
    log_timestamp = "%H:%M:%S";
    autolog = ON
    autolog_colors = OFF
    autolog_level = all -crap -clientcrap -ctcps
    autolog_path = ~/irclogs/$tag/$0/$0_%Y%m%d.log
    log_create_mode = 640
    log_open_string = --- Log opened %a %b %d %H:%M:%S %Y
    log_day_changed = --- Day changed %a %b %d %Y
    log_close_string = --- Log closed %a %b %d %H:%M:%S %Y

`~/irclogs/$tag/$0/$0_%Y%m%d.log` translates to `~/irclogs/FreeNode/#slicehost/#slicehost_20091025.log`

`log_create_mode = 640` is required so the webserver can read the logs. The group the application runs as will need to own the irclog folder, or you can change this to 644, so anyone can read it. (Not recommended!)

This format is required because it's been hardcoded into the application.

== Cronjobs ==
A nightly cronjob is required to update the file list cache. 

