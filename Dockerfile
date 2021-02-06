FROM php:7.4-fpm
ENV DEBIAN_FRONTEND=noninteractive \
  TIMEZONE=Europe/Berlin \
  MEMORY_LIMIT=-1 \
  MAX_EXECUTION_TIME=480

RUN apt-get update && apt-get install -y curl
RUN curl -sL https://deb.nodesource.com/setup_12.x | bash -

RUN apt-get update && apt-get install -y libmcrypt-dev \
  libmagickwand-dev vim git libzip-dev zip unzip --no-install-recommends libxpm-dev \
  poppler-utils ghostscript mariadb-client locales software-properties-common nodejs \
  && pecl install imagick  \
  && docker-php-ext-enable imagick \
  && docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/ --with-xpm=/usr/include/ --enable-gd-jis-conv \
  && docker-php-ext-install pdo_mysql zip gd bcmath exif \
  && docker-php-ext-enable opcache \
  && apt-get clean


RUN sed -i 's/# de_DE.UTF-8 UTF-8/de_DE.UTF-8 UTF-8/' /etc/locale.gen \
  && sed -i 's/# de_DE ISO-8859-1/de_DE ISO-8859-1/' /etc/locale.gen \
  && sed -i 's/# de_DE@euro ISO-8859-15/de_DE@euro ISO-8859-15/' /etc/locale.gen \
  && locale-gen


# Set some php.ini config
RUN echo "date.timezone = $TIMEZONE" >> /usr/local/etc/php/php.ini \
  && echo "memory_limit = $MEMORY_LIMIT" >> /usr/local/etc/php/php.ini \
  && echo "realpath_cache_size = 256k" >> /usr/local/etc/php/php.ini \
  && echo "max_execution_time = $MAX_EXECUTION_TIME" >> /usr/local/etc/php/php.ini

# install phpunit
RUN curl https://phar.phpunit.de/phpunit.phar -L > phpunit.phar \
  && chmod +x phpunit.phar \
  && mv phpunit.phar /usr/local/bin/phpunit \
  && phpunit --version

RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /var/www
