#!/usr/bin/env bash
set -euxo pipefail

sleep 30

while kubectl -n kube-system get po | grep traefik
do
    helm -n kube-system uninstall traefik-crd --wait=false || true
    helm -n kube-system uninstall traefik --wait=false || true
    kubectl -n kube-system delete job helm-install-traefik-crd --wait=false || true
    kubectl -n kube-system delete job helm-install-traefik --wait=false || true
    sleep 5
done
