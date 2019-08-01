FROM httpd:latest

ENV OPENJPG_VERSION 2.3.0
ENV IIP_VERSION 1.1

RUN apt-get update
RUN apt-get install -y wget build-essential autoconf cmake libtool gawk gawk g++ libjpeg62-turbo libjpeg62-turbo-dev libtiff-dev libmemcached-dev memcached pkg-config libapache2-mod-fcgid

RUN mkdir -p /var/www/images
RUN ln -s /usr/local/apache2/htdocs/ /var/www/html

RUN mkdir /etc/httpd
RUN mkdir /usr/local/apache2/conf.d
RUN ln -s /usr/local/apache2/conf /etc/httpd/conf
RUN ln -s /usr/local/apache2/conf.d /etc/httpd/conf.d
RUN cat /etc/apache2/mods-available/fcgid.load >> /etc/httpd/conf/httpd.conf
RUN echo "Include conf.d/*" >> /etc/httpd/conf/httpd.conf
COPY iip.conf /etc/httpd/conf.d
RUN mkdir /usr/local/apache2/fcgi-bin
RUN chown -R daemon /var/lib/apache2

#Build OpenJPEG
WORKDIR /usr/local/src
RUN wget -c https://github.com/uclouvain/openjpeg/archive/v$OPENJPG_VERSION.tar.gz -O openjpeg-$OPENJPG_VERSION.tar.gz \
     && tar -zxvf openjpeg-$OPENJPG_VERSION.tar.gz \
     && cd openjpeg-$OPENJPG_VERSION \
     && mkdir -v build \
     && cd build \
     && cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_INSTALL_PREFIX=/usr .. \
     && make \
     && make install

WORKDIR /usr/local/src
RUN wget 'https://github.com/ruven/iipsrv/archive/iipsrv-1.1.tar.gz'
RUN tar zxvf iipsrv-1.1.tar.gz

WORKDIR /usr/local/src/iipsrv-iipsrv-1.1
RUN export USE_OPENJPEG=1
RUN ./autogen.sh
RUN ./configure
RUN make && make check && make install
RUN cp src/iipsrv.fcgi /usr/local/apache2/fcgi-bin

COPY images/* /var/www/images/

#RUN echo "FcgidInitialEnv FILESYSTEM_PREFIX /var/www/images/" >> /etc/httpd/conf.d/iipsrv.conf
#RUN echo 'ScriptAlias /iiif "/usr/libexec/iipsrv/iipsrv.fcgi"' >>  /etc/httpd/conf.d/iipsrv.conf
#RUN echo 'FcgidInitialEnv URI_MAP "iiif=>IIIF"' >> /etc/httpd/conf.d/iipsrv.conf
#RUN echo 'FcgidInitialEnv VERBOSITY 6' >> /etc/httpd/conf.d/iipsrv.conf
#RUN chmod 777 /var/log/httpd
#
#COPY images/* /var/www/images/

#CMD ["/usr/local/bin/httpd-foreground"]
