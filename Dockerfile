FROM golang:alpine as builder
ENV GO111MODULE=on     GOPROXY=https://goproxy.cn,direct
ARG CONF=dev
WORKDIR /go/app
COPY go.mod .
COPY go.sum .
RUN go mod download
COPY main.go main.go
RUN CGO_ENABLED=0 GOARCH=amd64 GOOS=linux go build -o app .

FROM alpine:latest as prod
ARG CONF=dev
RUN sed -i 's/dl-cdn.alpinelinux.org/mirrors.aliyun.com/g' /etc/apk/repositories && apk --no-cache add ca-certificates && apk add tzdata && cp /usr/share/zoneinfo/Asia/Shanghai /etc/localtime && echo "Asia/Shanghai" > /etc/timezone
WORKDIR /app/
COPY --from=0 /go/app/app .
CMD ["./app"]
