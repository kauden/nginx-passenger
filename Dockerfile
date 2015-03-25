FROM ubuntu:14.04

MAINTAINER Thierry Corbin <thierry.corbin@kauden.fr>

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && \
    apt-get -y install git-core \
    curl \
    zlib1g-dev \
    build-essential \
    libssl-dev \
    libreadline-dev \
    libyaml-dev \
    libsqlite3-dev \
    sqlite3 \
    libxml2-dev \
    libxslt1-dev \
    libcurl4-openssl-dev \
    python-software-properties \
    software-properties-common \
    libffi-dev \
    supervisor \
    libmysqlclient-dev \
    imagemagick \
    wkhtmltopdf

RUN add-apt-repository ppa:chris-lea/node.js && \
    apt-get update && \
    apt-get -y install nodejs

RUN apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    rm -rf /tmp/*

RUN cd /opt && \
    curl -L -o ruby-2.1.5.tar.gz "http://ftp.ruby-lang.org/pub/ruby/2.1/ruby-2.1.5.tar.gz" && \
    tar -xzvf ruby-2.1.5.tar.gz && \
    rm -f ruby-2.1.5.tar.gz && \
    cd ruby-2.1.5/ && \
    ./configure && \
    make && \
    make install

RUN echo "gem: --no-ri --no-rdoc" > ~/.gemrc && \
    gem install bundler passenger && \
    passenger-install-nginx-module --auto --auto-download --languages ruby,nodejs

ADD asset/nginx.conf /opt/nginx/conf/nginx.conf
ADD asset/supervisord.conf /opt/supervisord.conf
ADD asset/init.sh /opt/init.sh

RUN chmod 755 /opt/init.sh && \
    mkdir /root/.ssh && \
    groupadd -r rails && \
    useradd -r -g rails rails && \
    mkdir /site && \
    chown rails:rails /site

EXPOSE 80

CMD /usr/bin/supervisord -c /opt/supervisord.conf