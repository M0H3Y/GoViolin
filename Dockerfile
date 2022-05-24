# Multi stage Build to reduce the image size 

# Build Stage 
FROM golang:1.16-alpine AS build

WORKDIR /app

# Copy all files to /app directory 
COPY . .

# initializing modules and building the app
RUN go mod init && \ 
    go build -o ./go-app

# Deploy stage 
FROM alpine 

# Copy all files
COPY --from=build /app /

# Default Command to be executed when starting the container 
CMD ["./go-app"]
