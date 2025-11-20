# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0
#

FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install essential build tools and utilities
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    apt-transport-https \
    build-essential \
    ca-certificates \
    curl \
    file \
    g++ \
    git \
    jq \
    make \
    softhsm2 \
    unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Go from official source
# IMPORTANT: Keep this version in sync with go.mod
# When updating: 1) Update go.mod, 2) Update this ARG, 3) Ona will prompt to rebuild
ARG GO_VERSION=1.25.4
RUN echo "Installing Go ${GO_VERSION}" \
    && curl -fsSL "https://go.dev/dl/go${GO_VERSION}.linux-amd64.tar.gz" | tar -xz -C /usr/local \
    && ln -sf /usr/local/go/bin/go /usr/local/bin/go \
    && ln -sf /usr/local/go/bin/gofmt /usr/local/bin/gofmt

# Install GitHub CLI
RUN curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg \
    && chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && apt-get update \
    && apt-get install -y gh \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Setup SoftHSM for PKCS11 tests
RUN mkdir -p /var/lib/softhsm/tokens \
    && chmod -R 777 /var/lib/softhsm

# Configure environment for vscode user
USER vscode
RUN mkdir -p ~/.config/softhsm2 \
    && cp /usr/share/softhsm/softhsm2.conf ~/.config/softhsm2/ \
    && softhsm2-util --init-token --slot 0 --label "ForFabric" --so-pin 1234 --pin 98765432 || true

# Set environment variables for PKCS11
ENV PKCS11_PIN=98765432 \
    PKCS11_LABEL="ForFabric"

USER root
