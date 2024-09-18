FROM golang:1.23 AS builder

ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG TARGETOS
ARG TARGETARCH

WORKDIR /app/
COPY . .
RUN CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -ldflags="-w -s" -o echo-server main.go

FROM scratch
WORKDIR /app/
COPY --from=builder /app/echo-server /usr/local/bin/
CMD ["echo-server"]
