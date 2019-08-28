FROM php:7.2-fpm-stretch

LABEL maintainer="Jan Ole Suhr <ole@janole.com>"

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

RUN	true \
#
# Install all necessary PHP mods
#
	&& apt-get update \
	&& apt-get install -y libxml2-dev zlib1g-dev libpq-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxpm-dev libwebp-dev libsodium-dev libgmp-dev \
	&& docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-xpm-dir=/usr/incude/ --with-webp-dir=/usr/include/ \
	&& docker-php-ext-install -j$(nproc) gd \
	&& docker-php-ext-install xml pgsql pdo_pgsql zip gmp intl \
	&& pecl install mailparse \
	&& docker-php-ext-enable mailparse \
#
# Use the default PHP production configuration
#
	&& mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
#
# Install NGINX and all other tools
#
	&& apt-get install -y nginx supervisor socat unzip localehelper msmtp msmtp-mta procps vim \
#
# Link NGINX log to stdout
#
	&& ln -sf /dev/stdout /var/log/nginx/access.log \
	&& ln -sf /dev/stdout /var/log/nginx/error.log \
#
# Remove unnecessary NGINX files, change access rights (just to be on the safe side ...)
#
	&& rm -rf /etc/nginx/sites-available/* && chown -Rc www-data:www-data /var/www \
#
# Prepare supervisord
#
	&& mkdir -p /var/log/supervisor && rm -f /etc/supervisor/conf.d/* \
#
# Install Node.js
#
	&& curl -sL https://deb.nodesource.com/setup_11.x | bash - \
	&& apt-get install -y nodejs \
#
# Install some imaging tools
#
	&& apt-get install -y imagemagick poppler-utils exiftool \
#
# Prepare folder structure ...
#
   	&& mkdir -p bootstrap/cache storage/framework/cache storage/framework/sessions storage/framework/views \
	&& chown -R www-data:www-data /app \
#
# Clean-up
#
	&& rm -rf /var/lib/apt/lists/*

#
# Copy our custom configs
#
COPY ./configs /

# Install composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Disable warning for running composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

#
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
