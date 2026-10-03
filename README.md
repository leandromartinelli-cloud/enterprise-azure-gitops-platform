# Enterprise GitOps Platform on Azure

Secure and governed application delivery platform built on Microsoft Azure, AKS, Argo CD, Terraform and GitHub.

## Overview

This project demonstrates the design and implementation of an enterprise-oriented GitOps platform on Microsoft Azure.

The platform combines Infrastructure as Code, GitOps, security, governance, observability and FinOps practices to provide a controlled and auditable application delivery model for Kubernetes workloads.

The architecture uses Git as the source of truth for application configuration while Argo CD continuously reconciles the desired state stored in Git with the actual state running on Azure Kubernetes Service (AKS).

## Architecture

The platform is based on the following flow:

```text
Developer
    |
    | Pull Request
    v
GitHub
    |
    +-- Application Source
    +-- Terraform
    +-- GitOps Manifests
    +-- GitHub Actions
    |
    | OIDC
    v
Microsoft Entra ID
    |
    v
Microsoft Azure
    |
    +-- Azure Kubernetes Service (AKS)
    +-- Azure Container Registry (ACR)
    +-- Azure Key Vault
    +-- Azure Policy
    +-- Azure Monitor / Log Analytics
    |
    v
Argo CD
    |
    +-- DEV
    +-- HML
    +-- PROD
```

## Core Principles

### Infrastructure as Code

Azure infrastructure is provisioned and managed through Terraform.

### Continuous Integration

GitHub Actions is responsible for:

- application build
- automated tests
- security scanning
- container image build
- publishing images to Azure Container Registry
- updating the desired application version in the GitOps repository

GitHub Actions does **not** deploy workloads directly to Kubernetes.

### GitOps Continuous Delivery

Argo CD is responsible for application delivery to AKS.

Git represents the desired state of the platform.

Argo CD continuously compares the desired state stored in Git with the actual state running in Kubernetes.

Capabilities demonstrated by this project include:

- automated synchronization
- drift detection
- self-healing
- rollback
- environment promotion
- declarative application delivery

### Security

The platform is designed around least-privilege and identity-based access.

Security controls include:

- Microsoft Entra ID
- Azure RBAC
- GitHub Actions authentication using OIDC
- AKS Workload Identity
- Azure Key Vault
- container image scanning
- Kubernetes security contexts
- network policies
- controlled secrets management

Long-lived Azure credentials should not be stored in GitHub.

### Governance

Governance is applied across Azure, Kubernetes and GitHub.

Azure governance includes:

- Azure Policy
- RBAC
- resource tagging
- diagnostic settings
- security controls
- cost governance

Kubernetes governance includes:

- admission policies
- resource requests and limits
- namespace isolation
- approved container registries
- workload security requirements

GitHub governance includes:

- branch protection
- pull requests
- CODEOWNERS
- required reviews
- automated security checks

### Observability

The platform will integrate:

- Azure Monitor
- Log Analytics
- AKS monitoring
- Kubernetes events
- Argo CD metrics and health information

### FinOps

Cost governance is considered part of the platform design.

The project will demonstrate:

- Azure resource tagging
- Kubernetes resource requests and limits
- monitoring cost awareness
- container registry lifecycle considerations
- controlled lab resource lifecycle

## Repository Structure

```text
.
|-- .github/
|   `-- workflows/
|
|-- app/
|
|-- argocd/
|   |-- applications/
|   `-- projects/
|
|-- docs/
|
|-- gitops/
|   |-- base/
|   `-- overlays/
|       |-- dev/
|       |-- hml/
|       `-- prod/
|
|-- policies/
|   |-- azure/
|   `-- kubernetes/
|
|-- security/
|
|-- terraform/
|   |-- environments/
|   |   |-- dev/
|   |   `-- prod/
|   `-- modules/
|
|-- .gitignore
`-- README.md
```

## Technology Stack

- Microsoft Azure
- Azure Kubernetes Service (AKS)
- Azure Container Registry (ACR)
- Azure Key Vault
- Microsoft Entra ID
- Azure Policy
- Azure Monitor
- Log Analytics
- Terraform
- Kubernetes
- Argo CD
- GitHub
- GitHub Actions
- OIDC
- Kustomize / Helm
- Container Security Scanning

## Project Roadmap

- [x] Repository foundation
- [ ] Architecture documentation
- [ ] Security and governance baseline
- [ ] Terraform foundation
- [ ] Azure networking
- [ ] AKS deployment
- [ ] Azure Container Registry
- [ ] GitHub Actions OIDC authentication
- [ ] Argo CD installation
- [ ] GitOps repository structure
- [ ] DEV / HML / PROD environments
- [ ] Automated synchronization
- [ ] Drift detection
- [ ] Self-healing
- [ ] Rollback validation
- [ ] Azure Key Vault integration
- [ ] AKS Workload Identity
- [ ] Kubernetes security controls
- [ ] Azure Policy governance
- [ ] Observability
- [ ] FinOps controls
- [ ] Architecture diagram
- [ ] Failure and recovery tests
- [ ] Final case study

## Author

**Leandro Martinelli**

Cloud Infrastructure | Azure | Kubernetes | DevOps | Platform Engineering