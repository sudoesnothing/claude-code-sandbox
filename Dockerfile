FROM ubuntu:24.04

# Prevent interactive prompts during package installation
ENV DEBIAN_FRONTEND=noninteractive

# Layer 1: System packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    curl \
    wget \
    git \
    python3 \
    python3-pip \
    python3-venv \
    sox \
    libsox-fmt-all \
    build-essential \
    sudo \
    ca-certificates \
    gnupg \
    lsb-release \
    unzip \
    vim \
    jq \
    rsync \
    && rm -rf /var/lib/apt/lists/*

# Layer 2: Node.js 22 LTS via NodeSource
RUN curl -fsSL https://deb.nodesource.com/setup_22.x | bash - \
    && apt-get install -y --no-install-recommends nodejs \
    && rm -rf /var/lib/apt/lists/* \
    && node --version \
    && npm --version

# Layer 3: Create claude user with passwordless sudo (UID/GID 1001)
RUN groupadd --gid 1001 claude \
    && useradd --uid 1001 --gid 1001 --shell /bin/bash --create-home claude \
    && echo "claude ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/claude \
    && chmod 440 /etc/sudoers.d/claude

# Layer 4: Install Claude Code CLI globally
RUN npm install -g @anthropic-ai/claude-code

# Layer 5: Prepare workspace and config directories
RUN mkdir -p /workspace \
    && chown claude:claude /workspace \
    && mkdir -p /home/claude/.claude \
    && chown claude:claude /home/claude/.claude

# Layer 6: Copy entrypoint script
COPY --chmod=755 scripts/setup/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh

# Runtime config
USER claude
WORKDIR /workspace

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD echo healthy || exit 1

ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]
CMD ["sleep", "infinity"]
