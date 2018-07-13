FROM jenkins/slave:3.19-1-alpine

USER root

RUN set -eux; \
    apk add --update --no-cache py-pip

RUN pip install --upgrade pip -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com \
    && pip install jinja2 -i http://mirrors.aliyun.com/pypi/simple/ --trusted-host mirrors.aliyun.com

# COPY preload-docker-images /usr/local/bin/preload-docker-images

COPY docker /usr/local/bin/

COPY jenkins-slave /usr/bin/jenkins-slave

RUN chmod 755 /usr/bin/jenkins-slave

COPY slave.jar /usr/share/jenkins/slave.jar

RUN curl -sLf http://static.corp.lc.com/static/jdk/8/install.sh | bash

COPY id_rsa* /root/.ssh/
 
RUN echo "StrictHostKeyChecking no" >> /etc/ssh/ssh_config

VOLUME /var/run/docker.sock
