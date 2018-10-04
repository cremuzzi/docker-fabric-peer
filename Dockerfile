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
    && go install \
    && apk del .build-deps

FROM alpine:3.8

LABEL maintainer="Carlos Remuzzi <carlosremuzzi@gmail.com>"
LABEL version="1.2.1"

ENV FABRIC_CFG_PATH=/etc/hyperledger/fabric

RUN mkdir -p /var/hyperledger/production $FABRIC_CFG_PATH \
    && chown nobody:nobody /var/hyperledger/production \
    && chown nobody:nobody $FABRIC_CFG_PATH

USER nobody

COPY --chown=nobody:nobody --from=builder /go/bin/peer /usr/local/bin/peer 
COPY --chown=nobody:nobody --from=builder /go/src/github.com/hyperledger/fabric/sampleconfig/ $FABRIC_CFG_PATH

CMD ["peer","node","start"]
