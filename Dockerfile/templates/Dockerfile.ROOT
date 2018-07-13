FROM ${PROD_IMAGE}

WORKDIR /usr/local/tomcat/webapps

RUN rm -rf ./ROOT/*

COPY ${PKG_PATH} ./ROOT/
