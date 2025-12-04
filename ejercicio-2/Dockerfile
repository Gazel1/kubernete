FROM matomo:latest

ENV PHP_MEMORY_LIMIT=512M

RUN apt-get update && apt-get install -y \
    curl \
    wget \
    && rm -rf /var/lib/apt/lists/*

COPY zzz-matomo.ini /usr/local/etc/php/conf.d/zzz-matomo.ini

RUN chown -R www-data:www-data /var/www/html

RUN sed -i 's/Listen 80/Listen 81/' /etc/apache2/ports.conf && \
    sed -i 's/<VirtualHost \*:80>/<VirtualHost \*:81>/' /etc/apache2/sites-available/000-default.conf

EXPOSE 81

CMD ["apache2-foreground"]