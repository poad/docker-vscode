FROM buildpack-deps:buster-curl AS version

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy \
    jq \
 && VERSION="$(curl -sSL https://api.github.com/repos/microsoft/vscode/releases/latest | jq -r .tag_name)" \
 && echo "${VERSION}" > /tmp/version.txt



FROM node:lts-buster-slim AS base

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
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 1 \
 && rm -rf /var/lib/apt /var/log/apt

FROM base

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root

COPY --from=version /tmp/version.txt /tmp/version.txt

RUN git clone --depth=1 -b "$(cat /tmp/version.txt)" https://github.com/microsoft/vscode \
 && rm -rf /tmp/version.txt

WORKDIR /root/vscode
RUN yarn install
RUN yarn run compile \
 && yarn run compile-extensions-build \
 && yarn compile-web 
 
EXPOSE 8080 8081

ENTRYPOINT [ "yarn", "web" ]

