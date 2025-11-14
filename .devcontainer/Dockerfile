FROM mcr.microsoft.com/devcontainers/base:ubuntu-24.04

# Install required tools for Hyperledger Fabric development
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
    golang-go \
    make \
    git \
    curl \
    jq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
