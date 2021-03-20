ARG DEBIAN_CODENAME="buster"
ARG VSCODE_VERSION_BASE=1.54
ARG VSCODE_VERSION=${VSCODE_VERSION_BASE}.3
ARG CODE_SERVER_VERSION=3.9.1
ARG CODE_SERVER_BRANCH


FROM node:lts-${DEBIAN_CODENAME}-slim AS build-base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy \
    python3-dev \
    python3-distutils \
    libpython3-stdlib \
 && apt-get install --no-install-recommends -qqy \
    apt-transport-https \
    gpg-agent \
    gnupg2 \
    pkg-config \
    build-essential \
    git \
    libx11-dev \
    libxkbfile-dev \
    libpython2.7 \
    libncurses5 \
    libxml2 \
    ca-certificates \
    gconf-service \
    libexpat1 \
    libssl1.1 \
    libxext6 \
    libxfixes3 \
    libxi6 \
    libxrandr2 \
    libxrender1 \
    libcairo2 \
    libcups2 \
    libdbus-1-3 \
    libexpat1 \
    libfontconfig1 \
    libgcc1 \
    libgconf-2-4 \
    libgdk-pixbuf2.0-0 \
    libglib2.0-0 \
    libgtk-3-0 \
    libnspr4 \
    libpango-1.0-0 \
    libpangocairo-1.0-0 \
    libstdc++6 \
    libx11-6 \
    libx11-xcb1 \
    libxcb1 \
    libx11-dev \
    libxcomposite1 \
    libxcursor1 \
    libxdamage1 \
    libxss1 \
    libxtst6 \
    libappindicator1 \
    libnss3 \
    libasound2 \
    libatk1.0-0 \
    libc6 \
    fonts-liberation \
    lsb-release \
    xdg-utils \
    curl \
    wget \
    jq \
    rsync \
    libsecret-1-0 \
    gettext-base \
 && curl -sSLo /tmp/nfpm_amd64.deb https://github.com/goreleaser/nfpm/releases/download/v1.9.0/nfpm_amd64.deb \
 && dpkg -i /tmp/nfpm_amd64.deb \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && rm -rf /var/lib/apt /var/log/apt

FROM build-base AS clone

ARG VSCODE_VERSION_BASE
ARG CODE_SERVER_VERSION
ARG CODE_SERVER_BRANCH

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root

RUN if [ -n "${CODE_SERVER_BRANCH}" ]; then BRANCH_TAG="${CODE_SERVER_BRANCH}"; else BRANCH_TAG="v${CODE_SERVER_VERSION}"; fi \
 && git clone --depth=1 -b "${BRANCH_TAG}" https://github.com/cdr/code-server.git

FROM clone AS build

WORKDIR /root/code-server
RUN yarn install \
#  && echo "${VSCODE_VERSION_BASE}" > yarn update:vscode\
 && yarn --frozen-lockfile \
 && yarn build \
 && yarn build:vscode \
 && yarn release \
 && yarn release:standalone \
 && yarn package

FROM node:lts-${DEBIAN_CODENAME}-slim AS release

ARG CODE_SERVER_VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root


COPY --from=build "/root/code-server/release-packages/code-server_${CODE_SERVER_VERSION}_amd64.deb" "/usr/src/code-server_${CODE_SERVER_VERSION}_amd64.deb"

# # https://wiki.debian.org/Locale#Manually
# RUN sed -i "s/# en_US.UTF-8/en_US.UTF-8/" /etc/locale.gen \
#   && locale-gen

ENV LANG=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder
RUN mkdir -p /home/coder \
 && chown -R 1000:1000 /home/coder

RUN dpkg -i "/usr/src/code-server_${CODE_SERVER_VERSION}_amd64.deb" \
 && rm -rf "/usr/src/code-server_${CODE_SERVER_VERSION}_amd64.deb"

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy \
    dumb-init \
 && rm -rf /var/lib/apt /var/log/apt

COPY ./assets/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

EXPOSE 8080

# This way, if someone sets $DOCKER_USER, docker-exec will still work as
# the uid will remain the same. note: only relevant if -u isn't passed to
# docker-run.
USER 1000
ENV USER=coder
WORKDIR /home/coder

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
