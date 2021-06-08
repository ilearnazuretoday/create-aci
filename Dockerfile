# Stage 1 - build phase
# Build binaries of your go app

# Use image containing golang distribution as base image
FROM golang:1.16 as builder

# Copy all files excluding the ones specified in .dockerignore
COPY ./main.go ./

# Build our app
RUN go build -o /go-app ./main.go

# Output content of the folder for readability
RUN ls

# Stage 2 - packaging phase
# We don't need all the packages and dependencies from previous image
# They would make our image big and create larger attack surface
# Using distroless image ensures good performance and security
FROM gcr.io/distroless/base

# This command tells docker to expose port 8080 in the running container
EXPOSE 8080

# Finally we are copying the binaries from previous image and executing the app
COPY --from=builder /go-app /.
ENTRYPOINT ["./go-app"]