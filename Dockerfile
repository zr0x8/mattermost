FROM node:24 AS frontend
WORKDIR /webapp
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential autoconf automake libtool nasm pkg-config \
    && rm -rf /var/lib/apt/lists/*
COPY webapp/ ./
RUN npm ci
RUN npm run build

FROM golang:1.25.8-alpine AS backend
WORKDIR /server
RUN apk add --no-cache make git
COPY server/go.mod server/go.sum ./
RUN go mod download
COPY server/ .
RUN make build-linux

FROM ubuntu:noble AS assembler
ARG PUID=2000
ARG PGID=2000
RUN apt-get update \
  && DEBIAN_FRONTEND=noninteractive apt-get install --no-install-recommends -y \
  ca-certificates \
  media-types \
  mailcap \
  unrtf \
  wv \
  poppler-utils \
  tidy \
  tzdata \
  && rm -rf /var/lib/apt/lists/*
RUN mkdir -p /mattermost/data /mattermost/plugins /mattermost/client/plugins /mattermost/.postgresql \
  && groupadd --gid ${PGID} mattermost \
  && useradd --uid ${PUID} --gid ${PGID} --comment "" --home-dir /mattermost mattermost \
  && chmod 700 /mattermost/.postgresql
COPY --from=backend  /server/bin/mattermost  /mattermost/bin/mattermost
COPY --from=backend  /server/config/         /mattermost/config/
COPY --from=backend  /server/i18n/           /mattermost/i18n/
COPY --from=backend  /server/templates/      /mattermost/templates/
COPY --from=frontend /webapp/dist/           /mattermost/client/
RUN chown -R mattermost:mattermost /mattermost

FROM gcr.io/distroless/base-debian12
ENV PATH="/mattermost/bin:${PATH}"
ENV MM_SERVICESETTINGS_ENABLELOCALMODE="true"
ENV MM_INSTALL_TYPE="docker"

COPY --from=assembler /etc/mime.types                    /etc/mime.types
COPY --from=assembler --chown=2000:2000 /etc/ssl/certs   /etc/ssl/certs

COPY --from=assembler /usr/bin/pdftotext   /usr/bin/pdftotext
COPY --from=assembler /usr/bin/wvText      /usr/bin/wvText
COPY --from=assembler /usr/bin/wvWare      /usr/bin/wvWare
COPY --from=assembler /usr/bin/unrtf       /usr/bin/unrtf
COPY --from=assembler /usr/bin/tidy        /usr/bin/tidy
COPY --from=assembler /usr/share/wv        /usr/share/wv

COPY --from=assembler /usr/lib/libpoppler.so*   /usr/lib/
COPY --from=assembler /usr/lib/libfreetype.so*  /usr/lib/
COPY --from=assembler /usr/lib/libpng.so*       /usr/lib/
COPY --from=assembler /usr/lib/libwv.so*        /usr/lib/
COPY --from=assembler /usr/lib/libtidy.so*      /usr/lib/
COPY --from=assembler /usr/lib/libfontconfig.so* /usr/lib/

COPY --from=assembler --chown=2000:2000 /mattermost /mattermost

USER 2000
WORKDIR /mattermost
CMD ["/mattermost/bin/mattermost"]
EXPOSE 8065 8067 8074 8075
VOLUME ["/mattermost/data", "/mattermost/logs", "/mattermost/config", "/mattermost/plugins", "/mattermost/client/plugins"]
HEALTHCHECK --interval=30s --timeout=10s \
  CMD ["/mattermost/bin/mmctl", "system", "status", "--local"]
