ARG GOLANG_VERSION=1.20

FROM golang:${GOLANG_VERSION} as build

ARG VERSION=""
ARG COMMIT=""

WORKDIR /linode-exporter

COPY main.go .
COPY collector ./collector

RUN CGO_ENABLED=0 GOOS=linux \
    go build \
    -ldflags "-X main.OSVersion=${VERSION} -X main.GitCommit=${COMMIT}" \
    -a -installsuffix cgo \
    -o /go/bin/linode-exporter \
    ./main.go

FROM scratch

COPY --from=build /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
COPY --from=build /go/bin/linode-exporter /

ENTRYPOINT ["/linode-exporter"]
