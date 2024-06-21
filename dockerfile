# Start with a suitable base image of Alpine Linux
FROM alpine:latest

# Install required packages including CA certificates and update them
RUN apk --no-cache add ca-certificates && \
    update-ca-certificates

# Set the working directory for subsequent commands
WORKDIR /app

# Continue with your build steps here
# For example, if you need to install additional dependencies or clone repositories

# Example: Install Git
RUN apk --no-cache add git

# Example: Clone and build xk6
RUN git clone https://github.com/k6io/xk6.git /go/src/go.k6.io/xk6 && \
    cd /go/src/go.k6.io/xk6 && \
    go install ./cmd/xk6

# Example: Build k6 with necessary extensions
RUN /go/bin/xk6 build --with github.com/grafana/xk6-output-influxdb@latest

# Stage 2: Final image
FROM alpine:latest

# Copy CA certificates from the builder stage
COPY --from=0 /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/

# Copy k6 binary from the builder stage
COPY --from=0 /go/bin/k6 /usr/bin/k6

# Set the entry point for the final image
ENTRYPOINT ["k6"]