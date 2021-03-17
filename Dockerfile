ARG DEBIAN_CODENAME="buster"

FROM node:lts-${DEBIAN_CODENAME}-slim AS base

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

FROM base AS build

ARG VERSION=1.54.3
ARG CODE_SERVER_VERSION=v3.9.1

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root

RUN git clone --depth=1 -b jsjoeio/upgrade-vscode-1.54 https://github.com/cdr/code-server.git

WORKDIR /root/code-server
RUN yarn install \
 && yarn --frozen-lockfile \
 && yarn build

FROM build AS release

RUN yarn build:vscode
RUN yarn release
RUN yarn release:standalone

RUN yarn package

WORKDIR /root/code-server/release

ENTRYPOINT [ "yarn", "--production" ]