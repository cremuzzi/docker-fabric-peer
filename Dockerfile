FROM golang:1.11.1-alpine3.8

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"
LABEL version="1.2.1"

WORKDIR /opt/builder

RUN apk add --no-cache --virtual .build-deps \
        curl \
    && curl -fsL https://github.com/hyperledger/fabric/archive/v1.2.1.tar.gz  -o fabric-1.2.1.tar.gz \
    && tar -zxf fabric-1.2.1.tar.gz \
    && rm fabric-1.2.1.tar.gz \
    && cd fabric-1.2.1

