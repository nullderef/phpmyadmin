FROM phusion/baseimage:0.9.22

ENV PHPMYADMIN_LANG=all-languages
ENV PHPMYADMIN_VER=4.7.5
ENV PHPMYADMIN_FILE=phpMyAdmin-$PHPMYADMIN_VER-$PHPMYADMIN_LANG.tar.gz

# Use baseimage-docker's init system.
CMD [ "/sbin/my_init" ]

RUN apt-get update -y

RUN apt-get install -y php7.0-fpm php7.0-mcrypt php-mbstring php7.0-mbstring \
    php-gettext php7.0-gd php7.0-json php7.0-mysql php7.0-curl

RUN apt-get install -y nginx wget bzip2 pwgen

RUN phpenmod mcrypt && phpenmod mbstring

RUN mkdir -p /phpmyadmin && \
    mkdir -p /phpmyadmin/config && \
    rm -rf /var/www/html

RUN wget https://files.phpmyadmin.net/phpMyAdmin/4.7.5/$PHPMYADMIN_FILE -P /root && \ 
    tar -xvzf /root/$PHPMYADMIN_FILE -C /phpmyadmin && \
    mv /phpmyadmin/phpMyAdmin-$PHPMYADMIN_VER-$PHPMYADMIN_LANG /phpmyadmin/html

COPY ./data/default /etc/nginx/sites-available/default
COPY ./data/config.inc.php /phpmyadmin/

RUN ln -s /phpmyadmin/html /var/www && ln -s /phpmyadmin/config/config.inc.php /phpmyadmin/html

RUN chown -R www-data:www-data /phpmyadmin && \ 
    chown -h www-data:www-data /var/www/html

RUN mkdir -p /etc/my_init.d
COPY data/docker-startup.sh /etc/my_init.d/docker-startup.sh
RUN chmod +x /etc/my_init.d/docker-startup.sh

USER www-data

VOLUME [ "/phpmyadmin/config" ]

USER root

EXPOSE 80/tcp

# Clean up APT when done.
RUN apt-get clean && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /root/*