FROM tomcat:8.5.31

ENV LC_ALL C.UTF-8

RUN set -ex; \
        ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime; \
        apt-get update; \
        apt-get install -y --no-install-recommends cron procps; \
        rm -rf /var/lib/apt/lists/*; \
        apt-get clean

RUN set -ex; \
        echo "0 0 * * * find /usr/local/tomcat/logs -type f -mtime +7 -exec rm -f {} \;" \
        > /usr/local/tomcat/logrotate.cron; \
        crontab /usr/local/tomcat/logrotate.cron

COPY docker-entrypoint.sh /usr/local/bin/

RUN chmod +x /usr/local/bin/docker-entrypoint.sh

ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["catalina.sh", "run"] 
