FROM golang:1.18.0-alpine3.15 as builder

LABEL version=1.0

RUN apk update && \
    apk add --no-cache git && \
    apk add --no-cache ca-certificates && \
    update-ca-certificates 2>/dev/null

WORKDIR /app
COPY . .

RUN CGO_ENABLED=0 GOOS=linux go build -o /cloudflare_exporter -a -installsuffix cgo -ldflags '-extldflags "-static"' .

FROM scratch

COPY --from=builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
COPY --from=builder /cloudflare_exporter /cloudflare_exporter

ENTRYPOINT ["/cloudflare_exporter"]

