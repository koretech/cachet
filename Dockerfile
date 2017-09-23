FROM richarvey/nginx-php-fpm
MAINTAINER Mike Kornelson

RUN git clone https://github.com/cachethq/Cachet.git /cachet
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

WORKDIR /cachet
RUN git checkout v2.3.13

COPY env /cachet/.env

RUN composer install --no-dev -o
RUN php artisan key:generate
RUN touch /cachet/database/database.sqlite && \
  chown -R nginx.nginx /cachet && \
  chmod -R 777 /cachet/storage && \
  chmod -R 777 /cachet/bootstrap

RUN php artisan migrate --force
RUN php artisan app:install

RUN rm /etc/nginx/sites-enabled/default.conf
COPY cachet-nginx.conf /etc/nginx/sites-enabled/default.conf

RUN mkdir /data && \
  mv /cachet/database/database.sqlite /cachet/database.original.sqlite && \
  touch /data/database.sqlite && \
  ln -s /data/database.sqlite /cachet/database/ && \
  chown -R nginx.nginx /data
VOLUME /data
