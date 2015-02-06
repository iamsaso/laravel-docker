FROM debian:jessie

MAINTAINER "Saso Matejina" <matejina@gmail.com>

# Update packeges
RUN apt-get update

# install packages
RUN apt-get install -y sudo
RUN apt-get install -y curl
RUN apt-get install -y git
RUN apt-get install -y php5-fpm php5-mcrypt php5-cli php5-gd php5-mongo php5-mssql php5-mysqlnd php5-pgsql php5-redis php5-sqlite php5-gd
RUN apt-get install -y nginx
RUN apt-get install -y supervisor
RUN apt-get install -y vim
RUN php5enmod mcrypt

# User
RUN echo %sudo        ALL=NOPASSWD: ALL >> /etc/sudoers
RUN useradd docker && echo "docker:docker" | chpasswd && adduser docker sudo
RUN mkdir -p /home/docker/www && chown -R docker:docker /home/docker
RUN usermod -a -G www-data docker

# Shared volume
VOLUME ["/home/docker/www"]

# Composer
RUN curl -sS https://getcomposer.org/installer | php && \
    mv composer.phar /usr/local/bin/composer
RUN composer global require "laravel/installer=~1.1"

# Bower
RUN curl -sL https://deb.nodesource.com/setup | bash - && \
    apt-get install -y nodejs && \
    npm install -g bower

# Setup config files
RUN echo "cgi.fix_pathinfo = 0;" >> /etc/php5/fpm/php.ini
RUN echo "daemon off;" >> /etc/nginx/nginx.conf
ADD ./nginx/default /etc/nginx/sites-enabled/default
ADD ./supervisor/supervisord.conf /etc/supervisor/supervisord.conf
ADD ./php-fpm/php-fpm.conf /etc/php5/fpm/php-fpm.conf

# Default command for container, start supervisor
CMD ["sudo", "supervisord", "--nodaemon"]

USER docker
WORKDIR /home/docker/www

# Expose port 80 of the container
EXPOSE 80