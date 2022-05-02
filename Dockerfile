FROM golang:1.18-alpine AS builder

# Update/Upgrade/Add packages for building

RUN apk add --no-cache bash git build-base

# Create appuser.
ENV USER=appuser
ENV UID=10001

RUN adduser \
    --disabled-password \
    --gecos "" \
    --home "/none" \
    --shell "/sbin/nologin" \
    --no-create-home \
    --uid "${UID}" \
    "${USER}"


# Build betterlog

WORKDIR /build/betterlog

ADD . .

ENV GOPATH=/build/betterlog/gospace

RUN make clobber

RUN make setup all

RUN CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -a -tags netgo -ldflags='-w -s' -o betterlog-server cmd/betterlog-server/main.go

FROM scratch AS runner

COPY --from=builder /etc/passwd /etc/passwd

COPY --from=builder /etc/group /etc/group

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt

WORKDIR /

COPY --from=builder --chown=appuser:appuser /build/betterlog/betterlog-server /

EXPOSE 5514

ENTRYPOINT [ "/betterlog-server" ]
