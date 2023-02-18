#!/usr/bin/env bash
set -euo pipefail

if [[ -z "${GITHUB_USER}" ]]; then
  echo "Please define environment variable 'GITHUB_USER'"
  exit 1
fi

if [[ -z "${GITHUB_TOKEN}" ]]; then
  echo "Please define environment variable 'GITHUB_TOKEN'"
  exit 1
fi

cd ./terraform
terraform init
terraform fmt
terraform validate
terraform apply
cd -
