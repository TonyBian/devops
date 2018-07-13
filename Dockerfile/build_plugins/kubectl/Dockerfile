#FROM concourse/busyboxplus:git
FROM alpine

ENV VERSION=v1.10.4

ADD https://storage.googleapis.com/kubernetes-release/release/$VERSION/bin/linux/amd64/kubectl \
    /usr/local/bin/kubectl

RUN chmod +x /usr/local/bin/kubectl
