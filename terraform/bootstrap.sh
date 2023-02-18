#!/usr/bin/env bash
set -euxo pipefail

REPO=$1
STAGE=$2

flux bootstrap github \
  --owner=$GITHUB_USER \
  --components-extra=image-reflector-controller,image-automation-controller \
  --repository=$REPO \
  --branch=main \
  --read-write-key \
  --path=clusters/${STAGE} \
  --personal
