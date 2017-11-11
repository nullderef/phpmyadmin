#!/bin/bash

export HOSTNAME=localhost
if [[ ! -z $SERVERHOST ]]; then
    export HOSTNAME=$SERVERHOST
fi

export BLOWFISH_SECRET=$(pwgen 40 1)
if [[ ! -z $COOKIE_SECRET ]]; then
    export BLOWFISH_SECRET=$COOKIE_SECRET
fi

if [ ! -f /phpmyadmin/config/config.inc.php ]; then
    cp /phpmyadmin/config.inc.php /phpmyadmin/config/
fi

sed -i "s:BLOWFISH_SECRET:$BLOWFISH_SECRET:g" "/phpmyadmin/config/config.inc.php"
sed -i "s:HOSTNAME:$HOSTNAME:g" "/phpmyadmin/config/config.inc.php"

chown -h www-data:www-data /phpmyadmin/config/config.inc.php
chmod 644 /phpmyadmin/config/config.inc.php

/etc/init.d/php7.0-fpm start
/etc/init.d/nginx start
