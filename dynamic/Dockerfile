FROM php:7.4-fpm

# Set working directory
WORKDIR /www

COPY ./files/www.conf "/usr/local/etc/php-fpm.d/www.conf"

# Install dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    libpng-dev \
    libpq-dev \
    libjpeg62-turbo-dev \
    libfreetype6-dev \
    locales \
    zip \
    jpegoptim optipng pngquant gifsicle \
    vim \
    unzip \
    git \
    curl \
    wget \
    nano \
    net-tools \
    libonig-dev


# Clear cache
RUN apt-get clean && rm -rf /var/lib/apt/lists/*

# Install extensions
RUN docker-php-ext-install mbstring exif pcntl
RUN docker-php-ext-configure gd --with-freetype=/usr/include/ --with-jpeg=/usr/include/
RUN docker-php-ext-install gd
# Install composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install npm
SHELL ["/bin/bash", "--login", "-c"]
RUN curl -sL https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
RUN nvm install 12.13.1

# Composer install
RUN composer global require hirak/prestissimo

# Add user for laravel application
RUN groupadd -g 1000 www
RUN useradd -g www www
RUN chown -R www:www /www
USER www
# Expose port 9000 and start php-fpm server
EXPOSE 9000
CMD ["php-fpm"]
