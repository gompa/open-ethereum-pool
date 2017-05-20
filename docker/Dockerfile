FROM ubuntu:16.04

ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get -y install curl software-properties-common && curl -sL https://deb.nodesource.com/setup_6.x | bash -
RUN apt-get update && apt-get -y install build-essential nodejs git wget

RUN git config --global http.https://gopkg.in.followRedirects true

WORKDIR /opt

# gcc for cgo
RUN apt-get update && apt-get install -y --no-install-recommends \
                g++ \
                gcc \
                libc6-dev \
                make \
                pkg-config \
        && rm -rf /var/lib/apt/lists/*

ENV GOLANG_VERSION 1.7.5

RUN set -eux; \
        \
# this "case" statement is generated via "update.sh"
        dpkgArch="$(dpkg --print-architecture)"; \
        case "${dpkgArch##*-}" in \
                ppc64el) goRelArch='linux-ppc64le'; goRelSha256='ced737e36f2b2017b59f31cce86f50a2519245f017a81b8dce93bf986717e3ed' ;; \
                i386) goRelArch='linux-386'; goRelSha256='432cb92ae656f6fe1fa96a981782ef5948438b6da6691423aae900918b1eb955' ;; \
                s390x) goRelArch='linux-s390x'; goRelSha256='858df47609594570479ff937e3704c58e06b40e485ce29d7f934eae87b7a4450' ;; \
                armhf) goRelArch='linux-armv6l'; goRelSha256='cf93c8171dda189c226fe337e3aae11db24bd600841caab36c91d753f631aa2b' ;; \
                amd64) goRelArch='linux-amd64'; goRelSha256='2e4dd6c44f0693bef4e7b46cc701513d74c3cc44f2419bf519d7868b12931ac3' ;; \
                *) goRelArch='src'; goRelSha256='4e834513a2079f8cbbd357502cccaac9507fd00a1efe672375798858ff291815'; \
                        echo >&2; echo >&2 "warning: current architecture ($dpkgArch) does not have a corresponding Go binary release; will be building from source"; echo >&2 ;; \
        esac; \
        \
        url="https://golang.org/dl/go${GOLANG_VERSION}.${goRelArch}.tar.gz"; \
        wget -O go.tgz "$url"; \
        echo "${goRelSha256} *go.tgz" | sha256sum -c -; \
        tar -C /usr/local -xzf go.tgz; \
        rm go.tgz; \
        \
        if [ "$goRelArch" = 'src' ]; then \
                echo >&2; \
                echo >&2 'error: UNIMPLEMENTED'; \
                echo >&2 'TODO install golang-any from backports for GOROOT_BOOTSTRAP (and uninstall after build)'; \
                echo >&2; \
                exit 1; \
        fi; \
        \
        export PATH="/usr/local/go/bin:$PATH"; \
        go version

ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH

RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"

RUN git clone https://github.com/ethereum/go-ethereum.git

WORKDIR /opt/go-ethereum

RUN make geth

RUN chmod a+x /opt/go-ethereum/build/bin/geth
RUN ln -s /opt/go-ethereum/build/bin/geth /usr/bin/geth

RUN apt-get update && apt-get -y install nginx
RUN apt-get update && apt-get -y install supervisor python-pip net-tools && pip install supervisor-stdout

RUN apt-get update && apt-get -y install openssl libssl-dev libudev-dev
RUN curl https://get.parity.io -kL|bash

WORKDIR /opt

RUN git config --global http.https://gopkg.in.followRedirects true
RUN git clone --branch release/music --single-branch https://github.com/GRinvest/open-ethereum-pool.git

WORKDIR /opt/open-ethereum-pool

RUN make

WORKDIR /opt/open-ethereum-pool/www

RUN npm install -g ember-cli@2.9.1 bower && npm install && bower --allow-root install && ./build.sh

WORKDIR /

COPY nginx.conf /etc/nginx/sites-enabled/default
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf
COPY pool.conf /etc/security/limits.d/pool.conf
COPY payouts.sh /payouts.sh
COPY pool.sh /pool.sh
COPY geth.sh /geth.sh
COPY parity.sh /parity.sh

RUN chmod a+x /payouts.sh && chmod a+x /pool.sh && chmod a+x /geth.sh && chmod a+x /parity.sh

CMD ["/usr/bin/supervisord"]

VOLUME ["/root/.ethereum"]

EXPOSE 8008 8088 80
