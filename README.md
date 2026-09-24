# Hostim Linux Workspace

A GitHub-ready container for Hostim that gives you a password-protected browser VS Code
(code-server), an integrated Linux terminal, outbound internet access, persistent project
storage, and common developer tools including Go, Python and Node.js.

## Included

- code-server 4.138.0 (VS Code in the browser)
- Go 1.27.1
- Python 3 + pip + venv
- Node.js + npm (Ubuntu package version)
- Git + SSH client
- GCC/G++/make/CMake/pkg-config
- curl, wget, jq, rsync, zip/unzip
- nano, vim, tmux, htop, shellcheck
- DNS/ping/netcat/lsof/process utilities
- passwordless `sudo` for the normal `coder` terminal user

## Persistent paths

Mount a Hostim volume at `/workspace`.

The image stores these there:

- `/workspace/projects` - your repositories/projects
- `/workspace/downloads` - downloaded files
- `/workspace/.go` - Go module/cache/bin area
- `/workspace/.npm-global` - npm global packages
- `/workspace/.code-server` - VS Code settings and extensions
- `/workspace/.config`, `.local`, `.cache` - application state

## Fastest deployment: Hostim dashboard

1. Create a new GitHub repository.
2. Upload all files from this repository to its root.
3. In Hostim create a Git-based app from that repository.
4. Use the exact settings in `HOSTIM_SETTINGS.md`.
5. Create a persistent volume and mount it at `/workspace`.
6. Set `PASSWORD` to a long unique password.
7. Deploy.
8. Open the Hostim-generated HTTPS URL and log in with that password.

The image listens on port `8080`, and code-server exposes `/healthz` for Hostim's health check.

## CLI deployment

Install/login to the Hostim CLI, then create/select a project. Check the plans available in
your region before deploying:

```bash
hostim regions ls
hostim regions pricing eu-center --for apps
hostim regions pricing eu-center --for volume
```

Create the volume:

```bash
hostim volumes create workspace-data --plan vol-1
```

Deploy from your GitHub repository (replace the URL and choose a valid plan):

```bash
hostim deploy workspace \
  --git https://github.com/YOUR_USERNAME/YOUR_REPO \
  --branch main \
  --dockerfile Dockerfile \
  --plan sa-1-1 \
  --port 8080 \
  --health-check-path /healthz \
  --volume workspace-data:/workspace \
  --env PASSWORD='USE-A-LONG-RANDOM-PASSWORD'
```

## Template deployment

`hostim-template.yml` creates both the app and the persistent volume. Before using it, edit:

```yaml
url: https://github.com/REPLACE_WITH_YOUR_USERNAME/REPLACE_WITH_YOUR_REPO
```

The template uses Hostim's `GENERATE_ME_32` placeholder to create a random password. After
applying it, view the generated password with:

```bash
hostim env get -a workspace
```

Validate and deploy the local template:

```bash
hostim templates validate -f hostim-template.yml
hostim templates apply -f hostim-template.yml -y
```

## Terminal checks after login

```bash
whoami
go version
go env GOPATH GOBIN
python3 --version
node --version
npm --version
git --version
curl https://api.ipify.org
```

Expected terminal user: `coder`.

### Test Go

```bash
cd /workspace
cp -r /opt/examples/go-hello ./go-hello 2>/dev/null || true
```

The example is also included in the Git repository under `examples/go-hello`, so after you
clone this repository into `/workspace/projects` you can run:

```bash
cd /workspace/projects/YOUR_REPO/examples/go-hello
go run .
```

Install a Go CLI tool persistently:

```bash
go install golang.org/x/tools/cmd/goimports@latest
which goimports
```

Because `GOBIN=/workspace/.go/bin`, that binary remains on the Hostim volume.

### Python virtual environment

```bash
python3 -m venv /workspace/venvs/myenv
source /workspace/venvs/myenv/bin/activate
pip install requests
```

### Global npm tools

```bash
npm install -g typescript
which tsc
```

The npm prefix is `/workspace/.npm-global`, so global npm packages remain on the volume.

## Installing more Linux applications

Inside the integrated terminal you can use sudo:

```bash
sudo apt update
sudo apt install -y ripgrep
```

That installation works in the current container and has normal outbound internet access,
but it is not persistent across a Hostim rebuild/redeploy. Add packages you always need to
`Dockerfile` instead.

## Networking model

The workspace itself is exposed through Hostim as HTTP/HTTPS on the configured app port.
Programs in the terminal can make outbound internet connections (subject to Hostim's platform
and acceptable-use/network restrictions). Do not assume arbitrary inbound TCP/UDP ports are
publicly reachable like they would be on a VPS.

## Security

- Never commit your `PASSWORD`, API keys, tokens or private SSH keys to GitHub.
- Use Hostim environment variables for secrets.
- Keep password authentication enabled because this app is publicly reachable.
- Use a unique, long password.
- Only install extensions/packages you trust; they execute inside your workspace account.

## Updating Go or code-server later

The versions are pinned in `Dockerfile` for reproducibility. Update the image tag and Go
version/checksum, commit the change, and redeploy.
