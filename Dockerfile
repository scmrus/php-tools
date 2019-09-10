FROM php:7.3-cli-alpine

# dependencies: pcntl, php-ast
RUN docker-php-ext-install pcntl \
    && apk add --no-cache git \
    && apk add --no-cache --virtual .build-dependencies autoconf gcc g++ make \
    && git clone -q https://github.com/nikic/php-ast.git \
    && cd php-ast \
    && phpize && ./configure && make install \
    && mv ./modules/ast.so /usr/local/lib/php/extensions/ast.so \
    && echo "extension=$(find /usr/local/lib/php/extensions/ -name ast.so)" > $PHP_INI_DIR/conf.d/ast.ini \
    && apk del .build-dependencies \
    && cd .. && rm -rf php-ast

# Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
ENV COMPOSER_ALLOW_SUPERUSER=1

ENV PATH /composer/vendor/bin:${PATH}

# Install phan/phan
RUN COMPOSER_HOME="/composer" composer global require --prefer-dist --no-progress --dev phan/phan

# Install vimeo/psalm
RUN COMPOSER_HOME="/composer" composer global require --prefer-dist --no-progress --dev vimeo/psalm

# Install phpstan/phpstan-shim
RUN COMPOSER_HOME="/composer" composer global require --prefer-dist --no-progress --dev phpstan/phpstan-shim

WORKDIR "/app"

CMD ["ls", "-lah", "/composer/vendor/bin/"]