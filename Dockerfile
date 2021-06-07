FROM golang:1.16 AS build
EXPOSE 8080
ADD . /src
WORKDIR /src
RUN go test --cover -v ./...
RUN go build -v -o /usr/local/bin/api
RUN chmod +x /usr/local/bin/api
CMD ["api"]