# Build stage - Backend
FROM golang:1.25.8-alpine AS backend
WORKDIR /server
RUN apk add --no-cache make git
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server/ .
RUN make build-linux

# Final stage
FROM postgres:14

RUN apt-get update && apt-get install -y ca-certificates

ARG MATTERMOST_VERSION
#
# Configure PostgreSQL
#

ENV POSTGRES_USER=mmuser
ENV POSTGRES_PASSWORD=mostest
ENV POSTGRES_DB=mattermost_test

#
# Configure Mattermost
#
WORKDIR /mm

# Copy built backend binary from backend build stage
COPY --from=backend /server/bin/mattermost ./mattermost/bin/mattermost
COPY --from=backend /server/config /mattermost/config

# Copy configuration file (if exists)
COPY config_docker.json ./mattermost/config/config_docker.json 2>/dev/null || true
COPY docker-entry.sh .

RUN chmod +x ./docker-entry.sh
ENTRYPOINT ./docker-entry.sh

# Mattermost environment variables
ENV PATH="/mm/mattermost/bin:${PATH}"

# Create default storage directory
RUN mkdir ./mattermost-data
VOLUME /mm/mattermost-data

# Ports
EXPOSE 8065
