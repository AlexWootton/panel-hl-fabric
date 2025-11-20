#!/bin/bash -eu
#
# Copyright IBM Corp. All Rights Reserved.
#
# SPDX-License-Identifier: Apache-2.0

GOROOT='/opt/go'
# Extract Go version from go.mod
# We assume the fabric repo is mounted at /home/vagrant/fabric
GO_VERSION=$(grep '^go ' /home/vagrant/fabric/go.mod | awk '{print $2}')

# ----------------------------------------------------------------
# Install Golang
# ----------------------------------------------------------------
GO_URL=https://storage.googleapis.com/golang/go${GO_VERSION}.linux-amd64.tar.gz
mkdir -p $GOROOT
curl -sL "$GO_URL" | (cd $GOROOT && tar --strip-components 1 -xz)

# ----------------------------------------------------------------
# Setup environment
# ----------------------------------------------------------------
cat <<EOF >/etc/profile.d/goroot.sh
export GOROOT=$GOROOT
export PATH=\$PATH:$GOROOT/bin
EOF
