FROM syhily/orange

RUN set -ex; \
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
        yum -y install crontabs; \
        rm -rf /var/cache/yum/*

COPY docker-entrypoint.sh /usr/local/bin
COPY divide_sync.cron /usr/local/orange/
COPY sync.py /usr/local/orange/

RUN sed -i 's#"auth": false#"auth": true#g' /usr/local/orange/conf/orange.conf; \
    sed -i 's#"auth_enable": true#"auth_enable": false#g' /usr/local/orange/conf/orange.conf; \
    chmod +x /usr/local/bin/docker-entrypoint.sh; \
    crontab /usr/local/orange/divide_sync.cron
    
ENTRYPOINT [ "docker-entrypoint.sh" ]
