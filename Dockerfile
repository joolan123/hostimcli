FROM codercom/code-server:4.138.0-noble

USER root

ARG DEBIAN_FRONTEND=noninteractive
ARG GO_VERSION=1.27.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        bash-completion \
        build-essential \
        ca-certificates \
        cmake \
        curl \
        dnsutils \
        file \
        git \
        htop \
        iputils-ping \
        jq \
        less \
        lsof \
        make \
        nano \
        netcat-openbsd \
        nodejs \
        npm \
        openssh-client \
        pkg-config \
        procps \
        python3 \
        python3-dev \
        python3-pip \
        python3-venv \
        rsync \
        shellcheck \
        sudo \
        tmux \
        unzip \
        vim \
        wget \
        xz-utils \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Install Go from the official Go binary archive and verify its SHA-256 checksum.
RUN set -eux; \
    arch="$(dpkg --print-architecture)"; \
    case "$arch" in \
      amd64) go_sha256='63d339f0da5ab53635a56f2490a7984dfe12dfcff22ad749f63edaf590168445' ;; \
      arm64) go_sha256='3450b45a3f9ee8568792736a5c5e70a1f2e9b36c35a8f74958c03e51d7d92bec' ;; \
      *) echo "Unsupported architecture: $arch" >&2; exit 1 ;; \
    esac; \
    go_file="go${GO_VERSION}.linux-${arch}.tar.gz"; \
    curl -fsSLo "/tmp/${go_file}" "https://go.dev/dl/${go_file}"; \
    echo "${go_sha256}  /tmp/${go_file}" | sha256sum -c -; \
    rm -rf /usr/local/go; \
    tar -C /usr/local -xzf "/tmp/${go_file}"; \
    rm -f "/tmp/${go_file}"; \
    /usr/local/go/bin/go version

# The official code-server image already creates the 'coder' user with passwordless sudo.
# Persistent developer state is kept below /workspace, which should be a Hostim volume.
ENV GOPATH=/workspace/.go \
    GOBIN=/workspace/.go/bin \
    NPM_CONFIG_PREFIX=/workspace/.npm-global \
    PATH=/usr/local/go/bin:/workspace/.go/bin:/workspace/.npm-global/bin:$PATH

COPY examples /opt/examples
COPY start.sh /usr/local/bin/start-workspace
RUN chmod 0755 /usr/local/bin/start-workspace

WORKDIR /workspace
EXPOSE 8080

# Start as root only long enough to prepare/chown the mounted volume, then drop to coder.
USER root
ENTRYPOINT ["/usr/local/bin/start-workspace"]
