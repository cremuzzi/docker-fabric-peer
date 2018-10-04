FROM golang:1.11.1-alpine3.8 AS builder

WORKDIR /go/src/github.com/hyperledger/

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
    && curl -fsL https://github.com/hyperledger/fabric/archive/v1.2.1.tar.gz  -o fabric-1.2.1.tar.gz \
    && tar -zxf fabric-1.2.1.tar.gz \
    && rm fabric-1.2.1.tar.gz \
    && mv fabric-1.2.1 fabric \
    && cd fabric/peer \
    && go install 

FROM alpine:3.8

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"
LABEL version="1.2.1"

ENV FABRIC_CFG_PATH=/etc/hyperledger/fabric

RUN mkdir -p /var/hyperledger/production $FABRIC_CFG_PATH

COPY --chown=nobody:nobody --from=builder /go/bin/peer /usr/local/bin/peer 

CMD ["peer","node","start"]
