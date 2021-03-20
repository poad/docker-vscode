#!/usr/bin/env bash

if [ -n "${PASSWORD}" ] || [ -n "${HASHED_PASSWORD}" ]; then
  AUTH="password"
else
  AUTH="none"
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

/usr/bin/code-server \
    --bind-addr "${BIND}" \
    --user-data-dir "${USER_DATA_DIR}" \
    --extensions-dir "${EXTENTIONS_DIR}" \
    --disable-telemetry \
    --auth "${AUTH}" \
    "${PROXY}" \
    "${WORKSPACE_DIR}"

