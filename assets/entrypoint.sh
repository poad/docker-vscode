#!/usr/bin/env bash

if [ -n "${PASSWORD}" ] || [ -n "${HASHED_PASSWORD}" ]; then
  AUTH="password"
  if [ -n "${PASSWORD}" ]; then
    PASSWORD_YAML="password: ${PASSWORD}"
  else
    PASSWORD_YAML="password: ${HASHED_PASSWORD}"
  fi
else
  AUTH="none"
  PASSWORD_YAML=""
  echo "starting with no password"
fi

if [ -z ${PROXY_DOMAIN+x} ]; then
  PROXY=""
else
  PROXY="--proxy-domain=${PROXY_DOMAIN}"
fi

if [ -z ${BIND_ADDR+x} ]; then
  BIND="0.0.0.0:8080"
else
  BIND="${BIND_ADDR}"
fi

if [ -z ${BASE_DIR+x} ]; then
  BASE_DIR_PATH="${HOME}/config"
else
  BASE_DIR_PATH="${BASE_DIR}"
fi

USER_DATA_DIR="${BASE_DIR_PATH}/data"
EXTENTIONS_DIR="${BASE_DIR_PATH}/extensions"
WORKSPACE_DIR="${BASE_DIR_PATH}/workspace"

if [ ! -e "${HOME}/.config/code-server/config.yaml" ]; then
cat << EOS > "${HOME}/.config/code-server/config.yaml"
bind-addr: ${BIND}
auth: ${AUTH}
${PASSWORD_YAML}
cert: false
EOS
fi

/usr/bin/code-server \
    --bind-addr "${BIND}" \
    --user-data-dir "${USER_DATA_DIR}" \
    --extensions-dir "${EXTENTIONS_DIR}" \
    --disable-telemetry \
    --auth "${AUTH}" \
    "${PROXY}" \
    "${WORKSPACE_DIR}"

