#!/bin/bash

# Display the script header , providing basic information about the script.
cat <<start_content
########################################################################
#                                                                      #
#                             PixelFed Updater                         #
#                                                                      #
#                  Created by Honeytree Technologies, LLC              #
#                            www.honeytreetech.com                     #
#                                                                      #
#                      Mastodon: honeytree.social                      #
#                      Email : info@honeytreetech.com                  #
#                                                                      #
########################################################################
start_content

sleep 3

cat <<startup_warning
########################################################################
#####  THIS IS IMPORTANT, PLEASE READ CAREFULLY BEFORE SELECTING   #####
#####                                                              #####
#####  This will only update from Elastio to Github version.       #####
#####                                                              #####
########################################################################
startup_warning

WIPE_DATA=""
read -p "Do you want to wipe old application data?. (Type 'yes' to confirm, or 'no' to cancel): " WIPE_DATA

if [[ "${WIPE_DATA}" == "yes" ]]; then
   sudo docker rm -f $( sudo docker ps -a -q)
   sudo docker volume rm $(sudo docker volume ls -q)
fi


sudo apt-get update -y
sudo apt install git -y
work_dir=~/pixelfed
cp ${work_dir}/.env.docker env
rm -rf ${work_dir}
git clone https://github.com/pixelfed/pixelfed
cp env ${work_dir}/.env.compose
rm env

cat <<docker_content >>${work_dir}/compose.yml
version: '3'

# In order to set configuration, please use a .env file in
# your compose project directory (the same directory as your
# docker-compose.yml), and set database options, application
# name, key, and other settings there.
# A list of available settings is available in .env.example
#
# The services should scale properly across a swarm cluster
# if the volumes are properly shared between cluster members.

services:
## App and Worker
  app:
    # Comment to use dockerhub image
    build: 
      context: .
      dockerfile: ./contrib/docker/Dockerfile
    restart: unless-stopped
    env_file:
      - .env.compose
    volumes:
      - app-storage:/var/www/storage
      - app-bootstrap:/var/www/bootstrap
      - "./.env.compose:/var/www/.env"
    networks:
      - external
      - internal
    ports:
      - "8080:80"
    depends_on:
      - db
      - redis

  worker:
    build: 
      context: .
      dockerfile: ./contrib/docker/Dockerfile
    restart: unless-stopped
    env_file:
      - .env.compose
    volumes:
      - app-storage:/var/www/storage
      - app-bootstrap:/var/www/bootstrap
    networks:
      - external
      - internal
    command: gosu www-data php artisan horizon
    depends_on:
      - db
      - redis

## DB and Cache
  db:
    image: mariadb:jammy
    restart: unless-stopped
    networks:
      - internal
    command: --default-authentication-plugin=mysql_native_password
    env_file:
      - .env.compose
    volumes:
      - "db-data:/var/lib/mysql"

  redis:
    image: redis:5-alpine
    restart: unless-stopped
    env_file:
      - .env.compose
    volumes:
      - "redis-data:/data"
    networks:
      - internal

volumes:
  db-data:
  redis-data:
  app-storage:
  app-bootstrap:

networks:
  internal:
    internal: true
  external:
    driver: bridge

docker_content

cat <<dockerfile >> ${work_dir}/contrib/docker/Dockerfile
FROM php:8.1-apache-bullseye

ENV COMPOSER_MEMORY_LIMIT=-1
ARG DEBIAN_FRONTEND=noninteractive
WORKDIR /var/www/

COPY --from=composer:2.4.4 /usr/bin/composer /usr/bin/composer

RUN apt-get update \
  && apt-get upgrade -y \
  && apt-get install -y --no-install-recommends \
      locales \
      locales-all \
      git \
      gosu \
      zip \
      unzip \
      libzip-dev \
      libcurl4-openssl-dev \
      optipng \
      pngquant \
      jpegoptim \
      gifsicle \
      libjpeg62-turbo-dev \
      libpng-dev \
      libmagickwand-dev \
      libxpm4 \
      libxpm-dev \
      libwebp-dev \
      ffmpeg \
      mariadb-client \
  && locale-gen \
  && update-locale \
  && docker-php-source extract \
  && pecl install imagick \
  && docker-php-ext-enable imagick \
  && docker-php-ext-configure gd \
      --with-freetype \
      --with-jpeg \
      --with-webp \
      --with-xpm \
  && docker-php-ext-install -j\$(nproc) gd \
  && pecl install redis \
  && docker-php-ext-enable redis \
  && docker-php-ext-install pdo_mysql \
  && docker-php-ext-configure intl \
  && docker-php-ext-install -j\$(nproc) intl bcmath zip pcntl exif curl \
  && a2enmod rewrite remoteip \
 && {\
     echo RemoteIPHeader X-Real-IP ;\
     echo RemoteIPTrustedProxy 10.0.0.0/8 ;\
     echo RemoteIPTrustedProxy 172.16.0.0/12 ;\
     echo RemoteIPTrustedProxy 192.168.0.0/16 ;\
     echo SetEnvIf X-Forwarded-Proto "https" HTTPS=on ;\
    } > /etc/apache2/conf-available/remoteip.conf \
 && a2enconf remoteip \
  && docker-php-source delete \
  && apt-get autoremove --purge -y \
  && apt-get clean \
  && rm -rf /var/cache/apt \
  && rm -rf /var/lib/apt/lists/

COPY contrib/docker/php.production.ini "\$PHP_INI_DIR/php.ini"

COPY . /var/www/
RUN cp -r storage storage.skel \
  && composer install --prefer-dist --no-interaction --no-ansi --optimize-autoloader \
  && rm -rf html && ln -s public html \
  && chown -R www-data:www-data /var/www

RUN php artisan horizon:publish

VOLUME /var/www/storage /var/www/bootstrap

CMD ["/var/www/contrib/docker/start.apache.sh"]

dockerfile

sudo docker rm -f $( sudo docker ps -a -q)
cd ~/pixelfed  &&  git pull origin dev && docker compose -f compose.yml up -d --build
