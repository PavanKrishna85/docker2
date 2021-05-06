From ubuntu:18.04

RUN apt update -y

ENV TZ=America/Rochester

RUN DEBIAN_FRONTEND=noninteractive apt install build-essential apache2 php git zip unzip libapache2-mod-php libapache2-mod-security2 -y

COPY ./sample.zip sample.zip

RUN unzip sample.zip -d sample

RUN cp sample/etc/apache2/privkey.pem /etc/apache2/privkey.pem

RUN cp sample/etc/apache2/publiccert.pem /etc/apache2/publiccert.pem

RUN cp sample/etc/apache2/apache2.conf /etc/apache2/apache2.conf

RUN cp sample/etc/apache2/sites-enabled/000-default.conf /etc/apache2/sites-enabled/000-default.conf

RUN cp sample/etc/apache2/conf-enabled/security.conf /etc/apache2/conf-enabled/security.conf

RUN cp /etc/modsecurity/modsecurity.conf-recommended /etc/modsecurity/modsecurity.conf

RUN sed -i 's/SecRuleEngine DetectionOnly/SecRuleEngine On/' /etc/modsecurity/modsecurity.conf

RUN echo "ServerName 127.0.0.1" >> /etc/apache2/apache2.conf
RUN rm -rf /usr/share/modsecurity-crs

RUN git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git

RUN mv owasp-modsecurity-crs/crs-setup.conf.example /etc/modsecurity/crs-setup.conf

RUN mv owasp-modsecurity-crs/rules/ /etc/modsecurity

RUN sed -i '9 a Include /etc/modsecurity/rules/*.conf' /etc/apache2/mods-enabled/security2.conf


RUN sed -i '22 a SecRuleEngine On' /etc/apache2/sites-enabled/000-default.conf
RUN sed -i '23 a ProxyPass / http://192.168.44.179:8080/' /etc/apache2/sites-enabled/000-default.conf
RUN cat /etc/hosts
RUN a2enmod headers
RUN a2enmod ssl
RUN a2enmod proxy
RUN a2enmod proxy_http

COPY ./start_services.sh /etc/init.d/start_services.sh

RUN chmod +x /etc/init.d/start_services.sh

EXPOSE 80

ENTRYPOINT ["/etc/init.d/start_services.sh"]
