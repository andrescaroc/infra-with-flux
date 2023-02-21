# infra-with-flux

This repository shows how to create, manage and automate the SDL of multiple applications including http, https and tcp services. The example creates two environments: `staging` which is based on a local k3d cluster and `production` which is an aws EKS cluster. Both clusters are bootstraped with flux to reconcile with this repo, that means all the provisioning is managed by the source code found here. This project is inspired by the [flux2-kustomize-helm-example](https://github.com/fluxcd/flux2-kustomize-helm-example) and enhanced with the incorporation of more apps including one tcp based.

## Prerequisites

This example assume that you are in a Linux system, might work in MacOS with minor modifications but haven't been tested.

Make sure you have the following cli tools installed:

- terraform
- awscli
- k3d
- docker
- flux
- helm
- kubectl

Set the aws environment variables for your `AWS_PROFILE`, validate they match the ones found in `./terraform/variables.tf` or modify accordingly

Set the github environment variables including the personal access token.

```shell
export GITHUB_USER=andrescaroc
export GITHUB_TOKEN=*redacted*
```

## Create and bootstrap staging and production clusters

```shell
./create.sh
```

## Repository structure

The Git repository contains the following top directories:

- **apps** dir contains Helm releases with a custom configuration per cluster
- **infrastructure** dir contains common infra tools such as ingress-nginx and cert-manager
- **clusters** dir contains the Flux configuration per cluster
- **terraform** dir contains the terraform configuration that create and bootstrap staging and production clusters

```
├── apps
│   ├── base
│   ├── production
│   └── staging
├── infrastructure
│   ├── configs
│   └── controllers
├── clusters
│   ├── production
│   └── staging
└── terraform
```

### Applications

The apps configuration is structured into:

- **apps/base/** dir contains namespaces, Helm releases and kustomizations
- **apps/production/** dir contains the production kustomizations
- **apps/staging/** dir contains the staging kustomizations

```
./apps/
├── base
│   ├── podinfo
│   │   ├── kustomization.yaml
│   │   ├── namespace.yaml
│   │   ├── release.yaml
│   │   └── repository.yaml
│   └── tcp-echo
│       ├── kustomization.yaml
│       ├── Kustomization.yaml
│       ├── namespace.yaml
│       └── repository.yaml
├── production
│   ├── kustomization.yaml
│   ├── podinfo
│   │   ├── kustomization.yaml
│   │   └── podinfo-values.yaml
│   └── tcp-echo
│       └── kustomization.yaml
└── staging
    ├── kustomization.yaml
    ├── podinfo
    │   ├── kustomization.yaml
    │   └── podinfo-values.yaml
    └── tcp-echo
        └── kustomization.yaml
```

### Infrastructure

The infrastructure is structured into:

- **infrastructure/controllers/** dir contains namespaces and Helm release definitions for Kubernetes controllers
- **infrastructure/configs/** dir contains Kubernetes custom resources such as ingress-nginx, could also include cert-manager

```
./infrastructure/
├── configs
│   └── kustomization.yaml
└── controllers
    ├── ingress-nginx.yaml
    └── kustomization.yaml
```

