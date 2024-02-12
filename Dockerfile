FROM alpine:3.19
LABEL Maintainer="Go Team"

# Configure nginx
COPY config/nginx.php.conf /etc/nginx/nginx.php.conf
COPY config/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY config/fpm-pool.conf /etc/php81/php-fpm.d/www.conf
COPY config/php.ini /etc/php81/conf.d/custom.ini
COPY config/opcache.ini  /etc/php81/conf.d/opcache.ini

# Configure supervisord
COPY config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Install packages and remove default server definition

RUN apk --no-cache add \
  nginx \
  php81 \
  php81-session \
  php81-opcache \
  php81-fpm \
  php81-iconv \
  php81-pgsql \
  php81-ctype \
  php81-curl \
  php81-dom \
  php81-gd \
  php81-intl \
  php81-json \
  php81-mbstring \
  # php8-pcre \
  php81-simplexml \
  # php8-spl \
  php81-exif \
  php81-fileinfo \
  php81-xmlreader \
  php81-xml \
  php81-zip \
  php81-openssl \
  php81-soap \
  php81-sodium \
  php81-tokenizer \
  # php8-xmlrpc \
  supervisor

# Setup document root
RUN mkdir -p /var/www/
RUN mkdir -p /var/www/moodledata
RUN mkdir -p /var/www/moodle
RUN chmod -R 0777 /var/www/moodle
RUN chown -R nginx:nginx /var/www/ && \
   chown -R nginx:nginx /run && \
   chown -R nginx:nginx /var/lib/nginx && \
   chown -R nginx:nginx /var/log/nginx
  
COPY ./src /var/www/moodle
COPY ./config/config.php /var/www/moodle/config.php

# Switch to use a non-root user from here on
USER nginx

# Add application
WORKDIR /var/www/
#Set 0777 permissions to moodledata and moodle
RUN chmod -R 0777 /var/www/moodledata


# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]