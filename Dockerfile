ARG DEBIAN_CODENAME="focal"
ARG NODE_VERSION="14.x"

FROM buildpack-deps:${DEBIAN_CODENAME}-curl AS download

ARG NODE_VERSION

SHELL ["/bin/bash", "-o", "pipefail", "-c"]

WORKDIR /root

ENV LANG=en_US.UTF-8

RUN adduser --gecos '' --disabled-password coder

RUN apt-get update -qq \
 && apt-get install --no-install-recommends -qqy \
    software-properties-common \
#  && add-apt-repository ppa:deadsnakes/ppa -y \
 && curl -fsSL "https://deb.nodesource.com/setup_${NODE_VERSION}" | bash - \
 && apt-get install --no-install-recommends -qqy \
   #  python3.9-distutils \
   #  libpython3.9-stdlib \
    nodejs \
 && rm -rf /var/lib/apt /var/log/apt /tmp/node_setup.sh \
 && npm i -g yarn node-gyp \
 && update-alternatives --install /usr/bin/python python /usr/bin/python3 1

RUN curl -fsSL https://code-server.dev/install.sh | sh

COPY ./assets/entrypoint.sh /usr/local/bin/entrypoint.sh

RUN chmod +x /usr/local/bin/entrypoint.sh

RUN mkdir -p /home/coder/.config/code-server/ /home/coder/.local/share/code-server/extensions \
 && chown -R coder:coder /home/coder

USER coder
ENV USER=coder
WORKDIR /home/coder

EXPOSE 8080

ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
