FROM golang:1.16-alpine AS build
WORKDIR /app
COPY . .
RUN go mod init && \ 
    go build -o ./go-app

FROM alpine 
COPY --from=build /app /
CMD ["./go-app"]

