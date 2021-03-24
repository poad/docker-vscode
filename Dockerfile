ARG DEBIAN_CODENAME="buster"
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

ARG CODE_SERVER_VERSION
ARG CODE_SERVER_BRANCH

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root

RUN if [ -n "${CODE_SERVER_BRANCH}" ]; then BRANCH_TAG="${CODE_SERVER_BRANCH}"; else BRANCH_TAG="v${CODE_SERVER_VERSION}"; fi \
 && git clone --depth=1 -b "${BRANCH_TAG}" https://github.com/cdr/code-server.git

FROM clone AS build

WORKDIR /root/code-server

# RUN yarn install \
#  && echo "${VSCODE_VERSION_BASE}" > yarn update:vscode \
#  && yarn --frozen-lockfile \
#  && yarn build \
#  && yarn build:vscode \
#  && yarn release \
#  && yarn release:standalone \
#  && yarn package \
#  && cp -pR "/root/code-server/release-packages/code-server*$(dpkg --print-architecture).deb" /root/code-server/release-packages/code-server_${CODE_SERVER_VERSION}.deb

RUN yarn install \
 && yarn --frozen-lockfile \
 && yarn build \
 && yarn build:vscode \
 && yarn release \
 && yarn release:standalone \
 && yarn package \
 && cp -pR /root/code-server/release-packages/code-server*"$(dpkg --print-architecture).deb" "/root/code-server/release-packages/code-server_${CODE_SERVER_VERSION}.deb"

FROM node:lts-${DEBIAN_CODENAME}-slim AS release

ARG CODE_SERVER_VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root


COPY --from=build "/root/code-server/release-packages/code-server_${CODE_SERVER_VERSION}.deb" "/usr/src/code-server_${CODE_SERVER_VERSION}.deb"

ENV LANG=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder

RUN dpkg -i "/usr/src/code-server_${CODE_SERVER_VERSION}.deb" \
 && rm -rf "/usr/src/code-server_${CODE_SERVER_VERSION}.deb"

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy \
    dumb-init \
    python3-distutils \
    libpython3-stdlib \
    libssl1.1 \
 && rm -rf /var/lib/apt /var/log/apt

COPY ./assets/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /home/coder/.config/code-server/ \
 && chown -R coder:coder /home/coder

USER coder
ENV USER=coder
WORKDIR /home/coder

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
