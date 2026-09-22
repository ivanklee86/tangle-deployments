FROM ghcr.io/ivanklee86/devcontainer/devops:main

ARG TARGETARCH

USER root

# Helm chart tooling (chart-repo specific, not centralized)
RUN ARCH=$([ "${TARGETARCH}" = "amd64" ] && echo "x86_64" || echo "arm64") && \
    curl -fsSL "https://github.com/norwoodj/helm-docs/releases/download/v1.14.2/helm-docs_1.14.2_Linux_${ARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin helm-docs

RUN curl -fsSL "https://github.com/yannh/kubeconform/releases/download/v0.8.0/kubeconform-linux-${TARGETARCH}.tar.gz" \
    | tar -xz -C /usr/local/bin kubeconform

# Node, for the semver-based chart version math in scripts/. Copied from the official LTS
# image (Krypton/24.x) rather than apt, which lags well behind on trixie.
COPY --from=node:24.21.0-trixie-slim /usr/local/bin/node /usr/local/bin/node
COPY --from=node:24.21.0-trixie-slim /usr/local/lib/node_modules/npm /usr/local/lib/node_modules/npm
RUN ln -sf ../lib/node_modules/npm/bin/npm-cli.js /usr/local/bin/npm && \
    ln -sf ../lib/node_modules/npm/bin/npx-cli.js /usr/local/bin/npx

USER vscode
