FROM php:7.3-fpm-bullseye

ENV DEBIAN_FRONTEND noninteractive

WORKDIR /app

#
# Install all necessary libs and PHP modules
#
RUN	true \
#
# Update package list and update packages
#
    && apt-get update \
    && apt-get dist-upgrade -y \
#
# Install all necessary PHP mods
#
    && apt-get install -y libxml2-dev libzip-dev libpq-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxpm-dev libwebp-dev libsodium-dev libgmp-dev \
    && docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/ --with-xpm-dir=/usr/incude/ --with-webp-dir=/usr/include/ \
    && docker-php-ext-install -j$(nproc) gd xml pgsql pdo_pgsql zip gmp intl opcache \
#
# Use the default PHP production configuration
#
    && mv $PHP_INI_DIR/php.ini-production $PHP_INI_DIR/php.ini \
#
# Install NGINX and all other tools
#
    && apt-get install -y nginx supervisor socat localehelper msmtp msmtp-mta procps vim \
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
COPY --from=composer:1.9 /usr/bin/composer /usr/bin/composer

# Disable warning for running composer as root
ENV COMPOSER_ALLOW_SUPERUSER=1

# Configure OPCACHE
ENV OPCACHE_ENABLE=1
ENV OPCACHE_VALIDATE_TIMESTAMPS=1
ENV OPCACHE_REVALIDATE_FREQ=2
ENV OPCACHE_FILE_CACHE=""

#
CMD ["/usr/bin/supervisord", "-c", "/supervisord.conf"]
