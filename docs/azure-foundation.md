# Azure Foundation Architecture

## 1. Purpose

This document defines the Azure infrastructure foundation for the Enterprise GitOps Platform.

The objective is to provide a secure, governed and cost-conscious Azure foundation capable of supporting AKS, Argo CD, GitOps workflows, security controls, observability and application workloads.

---

## 2. Deployment Scope

Initial environment:

```text
Environment: dev
Azure Region: Brazil South
Project: enterprise-gitops
Managed By: Terraform
```

The initial implementation uses a single Azure subscription and a dedicated Resource Group.

The architecture is designed so additional environments can be introduced without redesigning the platform.

---

## 3. Naming Convention

Azure resources follow a predictable naming convention:

```text
<resource-type>-<project>-<environment>-<region>
```

Initial resources:

```text
Resource Group
rg-enterprise-gitops-dev-brazilsouth

Virtual Network
vnet-enterprise-gitops-dev-brazilsouth

AKS
aks-enterprise-gitops-dev-brazilsouth

Log Analytics Workspace
log-enterprise-gitops-dev-brazilsouth
```

Resources with global naming requirements use a compact name and unique suffix.

Examples:

```text
Azure Container Registry
acrentgitopsdev<suffix>

Azure Key Vault
kv-entgitops-dev-<suffix>
```

---

## 4. Resource Organization

Initial resource topology:

```text
Azure Subscription
|
`-- rg-enterprise-gitops-dev-brazilsouth
    |
    +-- Virtual Network
    +-- AKS
    +-- Azure Container Registry
    +-- Azure Key Vault
    +-- Log Analytics Workspace
    +-- Managed Identities
    +-- Private DNS / Private Endpoints (future evolution)
    `-- Monitoring resources
```

For the laboratory, the initial architecture uses a single Resource Group to simplify lifecycle management and cost tracking.

A production architecture may separate resources by lifecycle and responsibility.

---

## 5. Network Architecture

The platform uses a dedicated Virtual Network.

```text
VNet
10.20.0.0/16

|
+-- AKS Subnet
|   10.20.0.0/22
|
`-- Private Endpoint Subnet
    10.20.4.0/24
```

The remaining address space is reserved for future platform evolution.

### AKS Networking

Target configuration:

```text
Network Plugin: Azure CNI
Network Plugin Mode: Overlay
Network Dataplane: Cilium
Network Policy: Cilium

Pod CIDR:
10.244.0.0/16

Service CIDR:
10.0.0.0/16

DNS Service IP:
10.0.0.10
```

The Pod CIDR is independent from the Azure VNet address space.

---

## 6. AKS Architecture

Initial AKS configuration:

```text
AKS
|
+-- Microsoft Entra ID integration
+-- Azure RBAC
+-- Managed Identity
+-- OIDC Issuer
+-- AKS Workload Identity
+-- Azure CNI Overlay
+-- Cilium
+-- Azure Monitor integration
`-- Argo CD
```

### System Node Pool

Initial laboratory configuration:

```text
VM Size:
Standard_D2as_v5

Initial Node Count:
1

Operating System:
Linux
```

The initial node count is intentionally small to control laboratory cost.

The architecture allows the node pool to be scaled when additional platform components are introduced.

---

## 7. Kubernetes API Access

The initial laboratory will use a public AKS API endpoint.

This decision reduces the operational complexity required for:

- Terraform administration
- kubectl access
- GitOps bootstrap
- troubleshooting
- laboratory demonstrations

Public API exposure does not represent the final enterprise security target.

The architecture should evolve toward:

```text
Private AKS
    |
Private DNS
    |
Private Connectivity
    |
Controlled Administration Path
```

The private cluster model will be documented as an enterprise evolution of the laboratory.

---

## 8. Azure Container Registry

Azure Container Registry stores application container images.

Initial design:

```text
SKU:
Standard

Authentication:
Microsoft Entra ID / Managed Identity

Admin Account:
Disabled
```

AKS access to ACR must use identity-based authorization rather than registry credentials stored in Kubernetes.

---

## 9. Azure Key Vault

Azure Key Vault provides centralized secrets management.

Initial design:

```text
Authorization:
Azure RBAC

Soft Delete:
Enabled

Application Authentication:
AKS Workload Identity
```

Application secrets must not be stored directly in Git.

The Kubernetes-to-Key-Vault integration will be implemented during the security phase.

---

## 10. Identity Architecture

The platform avoids long-lived Azure credentials where possible.

### Terraform

Terraform authentication must use an approved Azure identity.

### GitHub Actions

Target authentication:

```text
GitHub Actions
      |
      | OIDC
      v
Microsoft Entra ID
      |
      | Federated Identity
      v
Azure RBAC
```

No long-lived Azure client secret should be required.

### AKS Workloads

Target authentication:

```text
AKS Pod
   |
ServiceAccount
   |
Workload Identity
   |
Microsoft Entra ID
   |
Azure Resource
```

---

## 11. Observability

The initial monitoring foundation includes:

```text
Azure Monitor
      |
Log Analytics Workspace
      |
AKS
```

The platform will progressively collect:

- AKS diagnostics
- workload logs
- Kubernetes events
- platform metrics
- Argo CD health information
- GitOps synchronization information

Logging cost will be considered part of the FinOps controls.

---

## 12. Governance

The Azure foundation will implement governance controls through code.

Target controls include:

```text
Azure Policy
Azure RBAC
Mandatory Tags
Diagnostic Settings
Infrastructure as Code
GitHub Pull Requests
```

Initial mandatory tags:

```text
Environment
Application
Owner
ManagedBy
CostCenter
Project
```

---

## 13. Infrastructure as Code

Terraform is the authoritative mechanism for provisioning Azure infrastructure.

Target structure:

```text
terraform/
|
+-- environments/
|   |
|   +-- dev/
|   |
|   `-- prod/
|
`-- modules/
    |
    +-- networking/
    +-- aks/
    +-- acr/
    +-- key-vault/
    +-- monitoring/
    `-- identity/
```

Reusable infrastructure components should be implemented as Terraform modules.

Environment-specific configuration belongs under:

```text
terraform/environments/
```

---

## 14. Cost Strategy

The laboratory is designed to demonstrate enterprise architecture while controlling unnecessary Azure consumption.

Initial strategy:

```text
AKS nodes:
1 x Standard_D2as_v5

AKS tier:
Free where appropriate for the laboratory

ACR:
Standard

Environment:
DEV only initially

Resource lifecycle:
Terraform managed
```

Resources should be identifiable through tags and safely removable when the laboratory is not required.

---

## 15. Enterprise Evolution

The initial laboratory intentionally balances architecture, cost and operational complexity.

Future evolution may include:

```text
Private AKS
Private ACR
Private Key Vault
Private Endpoints
Private DNS Zones
Azure Firewall
NAT Gateway
Dedicated system/user node pools
Availability Zones
Production AKS tier
Multi-environment subscriptions
Hub-and-Spoke networking
Centralized Azure Policy
Microsoft Defender for Cloud
```

These capabilities are not required to demonstrate the initial GitOps architecture but represent natural enterprise extensions of the platform.

---

## 16. Architecture Decision Summary

| Area | Decision |
|---|---|
| Region | Brazil South |
| Environment | DEV |
| Infrastructure | Terraform |
| AKS API | Public for initial lab |
| AKS VM | Standard_D2as_v5 |
| Initial nodes | 1 |
| AKS networking | Azure CNI Overlay |
| Dataplane | Cilium |
| Identity | Microsoft Entra ID |
| AKS authorization | Azure RBAC |
| CI authentication | OIDC |
| Workload authentication | Workload Identity |
| Registry | Azure Container Registry Standard |
| Secrets | Azure Key Vault |
| Monitoring | Azure Monitor + Log Analytics |
| Deployment | Argo CD |
| Governance | Policy + RBAC + Tags |