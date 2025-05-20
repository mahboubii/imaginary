FROM golang:1.24 AS builder

ARG IMAGINARY_VERSION=dev

WORKDIR /project
RUN apt-get update && apt-get install -y libvips-dev
COPY go.mod go.sum ./
RUN go mod download
COPY . .
RUN mkdir -p /project/builds
RUN go build -ldflags="-s -w -X main.Version=${IMAGINARY_VERSION}" -o /project/builds/imaginary

FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y libvips42 && \
  apt-get clean && \
  rm -rf /var/lib/apt/lists/*

COPY --from=builder /project/builds/imaginary /usr/local/bin/imaginary

ENV PORT=8000
EXPOSE 8000
ENTRYPOINT ["/usr/local/bin/imaginary"]
