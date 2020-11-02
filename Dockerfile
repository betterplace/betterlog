FROM alpine:3.12.1 AS builder

# Update/Upgrade/Add packages for building

RUN apk add --no-cache bash git go build-base

# Build happening

WORKDIR /build/betterlog

ADD . .

ENV GOPATH=/build/betterlog/gospace

RUN make clobber

RUN go get -u github.com/betterplace/go-init

RUN make setup all

FROM alpine:3.12.1 AS runner

# Update/Upgrade/Add packages

RUN apk add --no-cache bash ca-certificates

RUN apk add --no-cache tzdata && \
  cp /usr/share/zoneinfo/Europe/Berlin /etc/localtime && \
  echo Europe/Berlin >/etc/timezone && \
  apk del tzdata

ARG APP_DIR=/app

RUN adduser -h ${APP_DIR} -s /bin/bash -D appuser

RUN mkdir -p /opt/bin

COPY --from=builder --chown=appuser:appuser /build/betterlog/gospace/bin/go-init /build/betterlog/betterlog-server /opt/bin/

ENV PATH /opt/bin:${PATH}

EXPOSE 5514

CMD [ "/opt/bin/go-init", "-pre", "/bin/sleep 3", "-main", "/opt/bin/betterlog-server" ]
