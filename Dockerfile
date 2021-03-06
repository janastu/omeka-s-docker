FROM php:apache
MAINTAINER Jonas Strassel <jo.strassel@gmail.com>
# Install git ant and java
RUN curl -sL https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get -y install \
    git-core \
#    ant \
#    openjdk-7-jdk \
    nodejs \
    apt-utils \
    zip \
    unzip \
    libfreetype6-dev \
    libjpeg62-turbo-dev \
    libmcrypt-dev \
    libpng12-dev \
    libmemcached-dev \
    zlib1g-dev \
    imagemagick
# Install php-extensions
RUN docker-php-ext-install -j$(nproc) iconv mcrypt \
    pdo pdo_mysql gd
RUN docker-php-ext-configure gd --with-freetype-dir=/usr/include/ --with-jpeg-dir=/usr/include/
# Clone omeka-s - replace with git clone...

RUN rm -rf /var/www/html/*
RUN git clone https://github.com/omeka/omeka-s.git /var/www/html

# enable the rewrite module of apache
RUN a2enmod rewrite
# Create a default php.ini
COPY files/php.ini /usr/local/etc/php/

# build omeka-s
RUN cd /var/www/html/
# && ant init
RUN node -v
RUN npm -v
RUN cd /var/www/html/ && npm install
RUN cd /var/www/html/ && npm install --global gulp-cli 
RUN cd /var/www/html/ && gulp init


# Clone all the Omeka-S Modules
RUN cd /var/www/html/modules && curl "https://api.github.com/users/omeka-s-modules/repos?page=$PAGE&per_page=100" | grep -e 'git_url*' | cut -d \" -f 4 | xargs -L1 git clone
# Clone all the Omeka-S Themes
RUN cd /var/www/html/themes && rm -r default && curl "https://api.github.com/users/omeka-s-themes/repos?page=$PAGE&per_page=100" | grep -e 'git_url*' | cut -d \" -f 4 | xargs -L1 git clone
# copy over the database and the apache config
COPY ./files/database.ini /var/www/html/config/database.ini
COPY ./files/apache-config.conf /etc/apache2/sites-enabled/000-default.conf
# set the file-rights
RUN chown -R www-data:www-data /var/www/html/
RUN chmod -R +w /var/www/html/files
# Expose the Port we'll provide Omeka on
EXPOSE 80
