FROM golang:1.11.1-alpine3.8 AS builder

ENV BASEIMAGE_RELEASE=0.4.10
ENV BASE_VERSION=1.2.0
ENV PROJECT_VERSION=1.2.0
ENV FABRIC_ROOT=$GOPATH/src/github.com/hyperledger/fabric
ENV FABRIC_CFG_PATH=/etc/hyperledger/fabric
ENV LD_FLAGS="-X github.com/hyperledger/fabric/common/metadata.Version=${BASE_VERSION} \
             -X github.com/hyperledger/fabric/common/metadata.BaseVersion=${BASEIMAGE_RELEASE} \
             -X github.com/hyperledger/fabric/common/metadata.BaseDockerLabel=org.hyperledger.fabric \
             -X github.com/hyperledger/fabric/common/metadata.DockerNamespace=hyperledger \
             -X github.com/hyperledger/fabric/common/metadata.BaseDockerNamespace=hyperledger \
             -X github.com/hyperledger/fabric/common/metadata.Experimental=true \
             -linkmode external -extldflags '-static -lpthread'"

RUN apk add --no-cache --virtual .build-deps \
        build-base \
        curl \
    && mkdir -p $GOPATH/src/github.com/hyperledger \
    && mkdir -p $FABRIC_CFG_PATH \
    && cd $GOPATH/src/github.com/hyperledger \
    && wget https://github.com/hyperledger/fabric/archive/v${PROJECT_VERSION}.zip \
    && unzip v${PROJECT_VERSION}.zip \
    && rm v${PROJECT_VERSION}.zip \
    && mv fabric-${PROJECT_VERSION} fabric \
    && cp -r $FABRIC_ROOT/sampleconfig/* $FABRIC_CFG_PATH/ \
    && cd fabric/peer \
    && go install -tags "experimental" -ldflags "$LD_FLAGS" \
    && go clean \
    && apk del .build-deps

VOLUME ["/var/hyperledger/production"]

EXPOSE 7051

CMD ["peer","node","start"]
