FROM centos:7

RUN yum -y install net-tools \
    && curl -sLf http://static.corp.lc.com/static/jdk/8/install.sh | bash \
    && ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && rm -rf /var/cache/yum/*
