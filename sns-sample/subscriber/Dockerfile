FROM golang:1.21

ENV GOPATH=

WORKDIR /go
COPY ./go.mod ./go.sum ./
RUN go mod tidy
COPY ./ ./
RUN go build -o subscriber

CMD ["./subscriber"]
