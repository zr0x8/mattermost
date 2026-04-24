# Frontend Build
FROM node:24 AS frontend
WORKDIR /webapp
COPY webapp/ ./
RUN npm ci && npm run build

# Backend Build
FROM golang:1.25.8-alpine AS backend
WORKDIR /server
RUN apk add --no-cache make git
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server/ .
RUN make build-linux

# Final Image 
FROM ubuntu:noble
ARG PUID=2000
ARG PGID=2000

ENV PATH="/mattermost/bin:${PATH}" \
    MM_SERVICESETTINGS_ENABLELOCALMODE="true" \
    MM_INSTALL_TYPE="docker"

RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
    ca-certificates media-types mailcap unrtf wv poppler-utils tidy tzdata \
  && rm -rf /var/lib/apt/lists/* \
  && groupadd --gid ${PGID} mattermost \
  && useradd --uid ${PUID} --gid ${PGID} --comment "" --home-dir /mattermost mattermost \
  && mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins /mattermost/.postgresql \
  && chmod 700 /mattermost/.postgresql

COPY --from=backend  --chown=${PUID}:${PGID} /server/bin/mattermost  /mattermost/bin/mattermost
COPY --from=backend  --chown=${PUID}:${PGID} /server/config/         /mattermost/config/
COPY --from=backend  --chown=${PUID}:${PGID} /server/fonts/          /mattermost/fonts/
COPY --from=backend  --chown=${PUID}:${PGID} /server/i18n/           /mattermost/i18n/
COPY --from=backend  --chown=${PUID}:${PGID} /server/templates/      /mattermost/templates/
COPY --from=frontend --chown=${PUID}:${PGID} /webapp/channels/dist/  /mattermost/client/

USER ${PUID}
WORKDIR /mattermost
CMD ["/mattermost/bin/mattermost"]
EXPOSE 8065 8067 8074 8075
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
HEALTHCHECK --interval=30s --timeout=10s \
  CMD ["/mattermost/bin/mmctl", "system", "status", "--local"]
