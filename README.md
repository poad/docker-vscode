# docker-vscode

## usage

```
docker run --rm -d -p 8080:8080 -p 8081:8081 -v ${HOME}/.code-server/:/home/coder/.config/code-server/ --name vscode poad/docker-vscode:latest
```
