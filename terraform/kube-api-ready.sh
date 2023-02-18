#!/usr/bin/env bash
set -euxo pipefail

CLUSTER=$1

CONTEXT=$(kubectl config get-contexts -o name | grep ${CLUSTER})

kubectl config use-context ${CONTEXT}

while ! kubectl get no | grep Ready
do
    sleep 5
done

while ! kubectl get po -A | grep 1/1
do
    sleep 5
done
