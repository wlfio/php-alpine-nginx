FROM alpine:3.10.3
LABEL Maintainer="Wolfgang von Caron <wolfgang@wlf.io>" \
    Description="Based on Tim de Pater <code@trafex.nl>'s Lightweight container with Nginx 1.14 & PHP-FPM 7.2 based on Alpine Linux."

# Install packages
RUN apk --no-cache add \
    bash \
    bash-doc \
    bash-completion \
    php7 \
    php7-cli \
    php7-ctype \
    php7-curl \
    php7-dom \
    php7-exif \
    php7-fileinfo \
    php7-fpm \
    php7-ftp \
    php7-gd \
    php7-gmp \
    php7-imagick \
    php7-intl \
    php7-json \
    php7-ldap \
    php7-mbstring \
    php7-mysqli \
    php7-openssl \
    php7-opcache \
    php7-pdo \
    php7-pdo_mysql \
    php7-phar \
    php7-redis \
    php7-simplexml \
    php7-tokenizer \
    php7-xml \
    php7-xmlreader \
    php7-xmlwriter\
    php7-xmlrpc \
    php7-xsl \
    php7-zip \
    php7-zlib \
    nginx \
    supervisor \
    nano \
    jq \
    curl \
    make \
    xmlstarlet

# Configure nginx
COPY alpine/nginx.conf /etc/nginx/nginx.conf

# Configure PHP-FPM
COPY alpine/fpm-pool.conf /etc/php7/php-fpm.d/www.conf
COPY alpine/php.ini /etc/php7/conf.d/zzz_custom.ini

# Configure supervisord
COPY alpine/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

# Make sure files/folders needed by the processes are accessable when they run under the nobody user
RUN chown -R nobody.nobody /run && \
  chown -R nobody.nobody /var/lib/nginx && \
  chown -R nobody.nobody /var/tmp/nginx && \
  chown -R nobody.nobody /var/log/nginx

# Setup document root
RUN mkdir -p /var/www \
    && mkdir -p /run/php \
    && mkdir -p /app \
    && rm -fr /var/www/html \
    && ln -s /app /var/www/html \
    && sed -i "s/upload_max_filesize.*/upload_max_filesize = 1024M/g" /etc/php7/php.ini \
    && sed -i "s/post_max_size.*/post_max_size = 1024M/g" /etc/php7/php.ini \
    && sed -i "s/max_execution_time.*/max_execution_time = 0/g" /etc/php7/php.ini \
    && sed -i "s/short_open_tag\ =\ Off/short_open_tag\ =\ On/g" /etc/php7/php.ini \
    && sed -i "s/variables_order.*/variables_order = \"EGPCS\"/g" /etc/php7/php.ini \
    && sed -i "s/error_reporting.*/error_reporting = E_ALL \& \~E_DEPRECATED \& \~E_STRICT \& \~E_CORE_WARNING/g" /etc/php7/php.ini

# Switch to use a non-root user from here on
USER nobody

# Expose the port nginx is reachable on
EXPOSE 8080

# Let supervisord start nginx & php-fpm
CMD ["/usr/bin/supervisord", "-c", "/etc/supervisor/conf.d/supervisord.conf"]

# Configure a healthcheck to validate that everything is up&running
HEALTHCHECK --timeout=10s CMD curl --silent --fail http://127.0.0.1:8080/fpm-ping

# Add application
ONBUILD ADD ./ /app
ONBUILD WORKDIR /app
