{
  "name": "Linux ISO Builder",
  "image": "debian:bookworm",
  
  "features": {
    "ghcr.io/devcontainers/features/common-utils:2": {}
  },
  
  "postCreateCommand": "bash .devcontainer/setup.sh",
  
  "customizations": {
    "vscode": {
      "extensions": ["ms-vscode.makefile-tools"]
    }
  },
  
  "remoteUser": "root"
}
