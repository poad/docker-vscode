# docker-vscode
[![Docker build and push](https://github.com/poad/docker-vscode/actions/workflows/main.yml/badge.svg)](https://github.com/poad/docker-vscode/actions/workflows/main.yml)

## usage

```
docker run -p 8080:8080 -p 8081:8081 -v ${HOME}/.code-server/:/home/coder/.config/code-server/ -e BASE_DIR=/home/coder/.config/code-server/ -d poad/docker-vscode:latest
```
