
FROM php:7.1.4-fpm-alpine

MAINTAINER Lyberteam <lyberteamltd@gmail.com>
LABEL Vendor="Lyberteam"
LABEL Description="PHP-FPM v7.1.4-alpine"
LABEL Version="1.0.1"


RUN apk update && apk add  --no-cache \
    git \
    mysql-client \
    curl \
    mc \
    libmcrypt \
    libmcrypt-dev \
    libxml2-dev \
    freetype \
    freetype-dev \
    libpng \
    libpng-dev \
    libjpeg-turbo \
    libjpeg-turbo-dev g++ make autoconf

RUN docker-php-source extract \
    && pecl install xdebug redis opcache\
    && docker-php-ext-enable xdebug redis opcache\
    && docker-php-source delete \
    && docker-php-ext-install mcrypt pdo_mysql soap \
    && echo "xdebug.remote_enable=on\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_autostart=on\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_port=9000\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_handler=dbgp\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && echo "xdebug.remote_connect_back=1\n" >> /usr/local/etc/php/conf.d/docker-php-ext-xdebug.ini \
    && rm -rf /tmp/*


RUN docker-php-ext-configure gd \
        --with-gd \
        --with-freetype-dir=/usr/include/ \
        --with-png-dir=/usr/include/ \
        --with-jpeg-dir=/usr/include/ \
      && docker-php-ext-install gd \
      && apk del --no-cache freetype freetype-dev libpng libpng-dev libjpeg-turbo libjpeg-turbo-dev \
      && rm -rf /tmp/*

# Change TimeZone
RUN echo "Set default timezone - Europe/Kiev"
RUN echo "Europe/Kiev" > /etc/timezone

# Install composer globally
RUN echo "Install composer globally"
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/bin/ --filename=composer

COPY php.ini /usr/local/etc/php/

RUN rm -f /usr/local/etc/php-fpm.d/www.conf.default
ADD symfony.pool.conf /usr/local/etc/php-fpm.d/
RUN rm -f /usr/local/etc/php-fpm.d/www.conf


USER www-data

CMD ["php-fpm"]

## Let's set the working dir
WORKDIR /var/www/lyberteam

EXPOSE 9000

#RUN  dpkg-reconfigure -f noninteractive tzdata
RUN  rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*
