FROM php:5-apache
MAINTAINER Jamgo Coop <info@jamgo.coop>

ENV PPMA_VERSION 0.5.1

RUN set -x; \
    apt-get update \
    && apt-get install -y --no-install-recommends libmcrypt-dev \
    && rm -rf /var/lib/apt/lists/*

RUN docker-php-ext-install mysql mcrypt pdo_mysql mysqli

RUN set -x; \
    curl -L http://sourceforge.net/projects/ppma/files/0.5.1/ppma-$PPMA_VERSION.tar.gz/download > /tmp/ppma-$PPMA_VERSION.tar.gz \
	&& tar -xf /tmp/ppma-$PPMA_VERSION.tar.gz -C /usr/src \
	&& mv /usr/src/ppma-$PPMA_VERSION /usr/src/ppma

COPY ppma.php /usr/src/ppma/protected/config/ppma.php
COPY docker-entrypoint.sh /entrypoint.sh
EXPOSE 80
ENTRYPOINT ["/entrypoint.sh"]
CMD ["apache2-foreground"]