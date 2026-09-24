# Hostim app settings

Use these values if you create the app in the Hostim dashboard instead of using the CLI template.

| Setting | Value |
|---|---|
| Source | Git repository |
| Branch | `main` |
| Dockerfile | `Dockerfile` |
| Public app | Yes |
| HTTP port | `8080` |
| Health check | `/healthz` |
| Replicas | `1` |
| App plan | At least about 1 GB RAM recommended; `sa-1-1` is the CLI documentation example |
| Environment variable | `PASSWORD=<a long random password>` |
| Volume | Create a persistent volume (`vol-1` is documented as 5 GB) |
| Volume mount path | `/workspace` |
| Start/command override | Leave empty; the Docker image already starts itself |

## Important

The app will deliberately refuse to start if `PASSWORD` is missing.

The persistent volume should be mounted at `/workspace`. Projects, Go-installed binaries,
VS Code settings/extensions and npm global tools are configured to live there.

Packages you install at runtime with `sudo apt install ...` are temporary container changes.
To make an OS package survive a Hostim rebuild/redeploy, add it to the `apt-get install`
list in `Dockerfile`, commit, and redeploy.
