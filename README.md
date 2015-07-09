# backup-utils

##Overview

Backup Utilities - useful instrument to create and manage your backups.


##Description

There are 2 scripts that should be used to create backups. These scripts running under low priority (``nice``) so they not going to kill your envirement. 

###mysql.sh

This script performs backup of MySQL databases. It also cleans old backups and can compress backup file to save some disk space for you.
By defaut it performs backup for every single database but you can specify excludes. This is really convenient you'll like it.

Output example:

    $ sudo ./mysql.sh
    >>> Creating Backup of databases
    ] Processing database "somedatabase"
    ] Processing database "walkaround"
    ] Processing database "inside"
    ] Processing database "greatlook"
    ] Processing database "aws_instances"
    ] Processing database "mail"
    ] Processing database "alikesegment"
    ] Processing database "roundcube"
    ] Processing database "ttanimed"
    ] Processing database "jlogs"
    ] Processing database "zond"
    >>> Cleaning old Backups
    >>> Creating an archive using /usr/local/bin/7z
    >>> Operation took time from 09.07.2015.22.10 to 09.07.2015.22.21
    
###www.sh

This script performs backup of your Web Sites. You are able to exclude any dir in configuration file if it's messy inside your www root(s).
It also cleans old backups, saves file mode bits (chmod), files owner/group, and can compress backup file to save some disk space for you.

Output example:

    $ sudo ./www.sh
    >>> Processing (aion_forum):
    /var/jails/jaila/var/www/forum.example.com/www
    Elapsed time: 81
    >>> Processing (aion):
    /var/jails/jailb/var/www/example.com/www
    Elapsed time: 28
    >>> Processing (denshaotoko):
    /var/jails/jailc/var/www/www.example.org/www
    Elapsed time: 5
    >>> Processing (denshaotoko_storage):
    /var/jails/jaild/var/www/www.example.org.storage
    Elapsed time: 7
    >>> Processing (audionstreaming):
    /var/www/www.example.net
    Elapsed time: 39
    >>> Processing (tvtt):
    /var/jails/jaile/var/www/balancer.example.net
    Elapsed time: 317
    >>> Processing (tvonline):
    /var/jails/jailf/var/www/online.example.net
    Elapsed time: 404
    >>> Cleaning old Backups
    >>> Operation took time from 09.07.2015.22.19 to 09.07.2015.22.34

##Requirements

* **mysql client** and **mysqldump**. Usually mysqldump comes with mysql client, depends on your distributive/package system.
* **7-zip** to compress backups.
Basically you can use whatever you want but I would recommend [7-zip](http://www.7-zip.org/ "7-zip") to get best compress results.
_You really want to install that from package/port system._


##Setup

You should create config files first

    $ cp .config.example .config
    $ cp .www.example .www
    $ chown root .config .www
    $ chmod 600 .config .www
    
If your OS other then FreeBSD you must change path in configuration file for each unix tool _(like path to tar, 7z, mysqldump, etc...)_.
    
Also if you going to backup your MySQL data,
be sure that you have [MySQL defaults file](https://dev.mysql.com/doc/refman/5.5/en/option-files.html "defaults file")
which contain password.

Example:

    [client]
    user        = "root"
    password    = "secretpassword"

You should provide path for [MySQL defaults file](https://dev.mysql.com/doc/refman/5.5/en/option-files.html "defaults file")
inside **.config** file.

To setup backups for websites modify **.www**. Variable ``ACTIVE_PROJECTS`` should contain project names separated with space.
Unique names allowed only! Then based on project name you need to create following related variables.

    PATH_WEBSITE_ROOT_projectname=
    PATH_WEBSITE_EXCLUDE_projectname=

Where _projectname_ is a key name which placed into ``ACTIVE_PROJECTS`` variable.

Example:

    ACTIVE_PROJECTS="MYSITE MYWHATEVER MYFORUM_L2"

    # www.example.org
    PATH_WEBSITE_ROOT_MYSITE="/var/jails/jailb/var/www/www.example.org/www"
    PATH_WEBSITE_EXCLUDE_MYSITE=""

    # example.com
    PATH_WEBSITE_ROOT_MYWHATEVER="/var/www/example.com"
    PATH_WEBSITE_EXCLUDE_MYWHATEVER="/var/www/example.com/downloads /var/www/example.com/tmp"

    # forum.example.net
    PATH_WEBSITE_ROOT_MYFORUM_L2="/var/jails/jaila/var/www/forum.example.net/www"
    PATH_WEBSITE_EXCLUDE_MYFORUM_L2="cache"

Pay attention on different variation of ``PATH_WEBSITE_EXCLUDE_xxxxx`` variable.
You can specify full path or you are able to use relative path from ``PATH_WEBSITE_ROOT_xxxxx`` variable.
If you want to exclude more then single resource just use space as delimiter.


You probably want put that into your crontab under root account for each machine/instance.
_As a fancy improvement you can put that into Rundeck instead of Crontab or puppetize that._

    $ crontab -l -u root
    # .---------------- minute (0 - 59)
    # |     .------------- hour (0 - 23)
    # |     |       .---------- day of month (1 - 31)
    # |     |       |       .------- month (1 - 12) OR jan,feb,mar,apr ...
    # |     |       |       |       .---- day of week (0 - 6) (Sunday=0 or 7)  OR sun,mon,tue,wed,thu,fri,sat
    # |     |       |       |       |       commands
    50      5       *       *       2,5     /home/user/backup-utils/mysql.sh
    30      5       *       *       2,5     /home/user/backup-utils/www.sh


##Limitations

These utilities are tested on FreeBSD only but they should work on any unix OS as well.


##Development

###Contributing

Feel free to send pull requests with updates.
