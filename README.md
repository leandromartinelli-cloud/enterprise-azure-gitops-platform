# Enterprise GitOps Platform on Azure

Enterprise-oriented Azure platform demonstrating secure infrastructure provisioning, private Kubernetes operations, GitOps application delivery, workload identity, CI automation, observability and end-to-end platform validation.

## Overview

This project implements a production-inspired GitOps platform on Microsoft Azure using Terraform, Azure Kubernetes Service (AKS), Argo CD and GitHub Actions.

The platform was designed around the following principles:

- Infrastructure as Code
- private-by-design Azure services
- identity-based authentication
- least-privilege access
- GitOps-based application delivery
- separation between CI and CD
- declarative Kubernetes configuration
- automated validation
- observability
- reproducible infrastructure

The current `v1.0.0` implementation provides a complete DEV environment used to validate the architecture and delivery model.

---

## Architecture

```text
                         +----------------------+
                         |      Developer       |
                         +----------+-----------+
                                    |
                                    | Git / Pull Request
                                    v
                         +----------------------+
                         |        GitHub        |
                         |----------------------|
                         | Source Code          |
                         | Terraform            |
                         | GitOps Manifests     |
                         | GitHub Actions       |
                         +----------+-----------+
                                    |
                                    v
                         Self-hosted GitHub Runner
                                    |
                                    v
                  +-------------------------------------+
                  |          Azure Virtual Network      |
                  |                                     |
                  |  +-------------------------------+  |
                  |  | Private CI Runner VM          |  |
                  |  |-------------------------------|  |
                  |  | GitHub Actions Runner         |  |
                  |  | System Assigned Identity      |  |
                  |  | Terraform / Azure CLI         |  |
                  |  | kubectl / kubelogin           |  |
                  |  +---------------+---------------+  |
                  |                  |                  |
                  |                  | Private Access   |
                  |                  v                  |
                  |  +-------------------------------+  |
                  |  | Private AKS Cluster           |  |
                  |  |-------------------------------|  |
                  |  | Microsoft Entra ID            |  |
                  |  | Azure RBAC                    |  |
                  |  | Workload Identity             |  |
                  |  | Argo CD                       |  |
                  |  +---------------+---------------+  |
                  |                  |                  |
                  |                  | GitOps Sync      |
                  |                  v                  |
                  |          +---------------+          |
                  |          |  Sample App   |          |
                  |          +-------+-------+          |
                  |                  |                  |
                  |          Workload Identity          |
                  |                  |                  |
                  |                  v                  |
                  |          +---------------+          |
                  |          |   Key Vault   |          |
                  |          +---------------+          |
                  |                                     |
                  |  +---------------+ +-------------+ |
                  |  | Private ACR   | | Monitoring  | |
                  |  +---------------+ +-------------+ |
                  +-------------------------------------+
```

---

## Architecture Highlights

### Private AKS

The AKS API is private and is not directly reachable from a developer workstation over the public Internet.

Administrative and CI operations are executed from a self-hosted GitHub Actions runner located inside the Azure virtual network.

This design keeps the Kubernetes control plane private while still supporting automated infrastructure operations, GitOps and platform validation.

### Private GitHub Actions Runner

A Linux VM inside Azure hosts the self-hosted GitHub Actions runner.

The runner uses a **System Assigned Managed Identity** to authenticate to Azure.

No long-lived Azure Service Principal credentials are required by the Terraform and platform validation workflows.

The runner is authorized to perform the operations required by the platform, including:

- Terraform infrastructure operations
- ACR access
- AKS credential retrieval
- AKS Azure RBAC operations
- private AKS validation

The runner carries dedicated GitHub labels:

```text
self-hosted
Linux
X64
azure
private
```

This allows private platform workflows to target the Azure-based runner explicitly.

### Private Endpoints

Private connectivity is implemented for:

- Azure Container Registry
- Azure Key Vault

Private DNS integration allows infrastructure components and workloads inside the Azure network to resolve the corresponding private endpoints.

---

## Infrastructure as Code

Terraform is responsible for provisioning and managing the Azure infrastructure.

The implementation is organized into reusable modules:

```text
terraform/modules/
|-- acr/
|-- acr-private-endpoint/
|-- aks/
|-- github-runner/
|-- key-vault/
|-- key-vault-private-endpoint/
|-- monitoring/
|-- networking/
`-- workload-identity/
```

The DEV environment is located at:

```text
terraform/environments/dev/
```

Terraform uses remote state for shared and consistent infrastructure state management.

### Infrastructure Convergence

The final infrastructure validation for `v1.0.0` completed with:

```text
No changes. Your infrastructure matches the configuration.
```

This confirms that the Terraform configuration, state and deployed Azure infrastructure are converged.

---

## Continuous Integration

GitHub Actions provides automated validation and CI workflows.

Current workflows:

```text
.github/workflows/
|-- gitops-validation.yml
|-- platform-validation.yml
|-- sample-app-ci.yml
`-- terraform-ci.yml
```

### Terraform CI

Terraform changes are validated through the self-hosted runner inside Azure.

The workflow performs:

- Managed Identity authentication
- Terraform installation
- Terraform formatting validation
- Terraform initialization
- Terraform configuration validation
- Terraform plan

This allows Terraform to validate infrastructure that includes private Azure resources without exposing the environment publicly.

### Sample Application CI

The sample application CI workflow provides application build and delivery automation.

The architecture maintains a clear separation between CI and CD:

```text
CI
 |
 +--> Build
 +--> Validate
 +--> Container Image
 +--> Registry
 +--> Desired State Update

CD
 |
 `--> Argo CD
       |
       `--> AKS
```

GitHub Actions does not directly deploy the application into Kubernetes.

### GitOps Validation

GitOps manifests are validated independently from Terraform infrastructure changes.

This helps detect invalid desired-state configuration before Argo CD reconciles it into the cluster.

### Platform Validation

An on-demand platform validation workflow performs end-to-end validation from inside the private Azure network.

The validation path is:

```text
GitHub Actions
      |
      v
Self-hosted Azure Runner
      |
      v
Managed Identity
      |
      v
Azure Authentication
      |
      v
AKS Credentials
      |
      v
kubectl + kubelogin
      |
      v
Microsoft Entra ID
      |
      v
Private AKS API
      |
      v
Azure RBAC
      |
      +--> Kubernetes Nodes
      +--> Kubernetes Workloads
      `--> Argo CD Applications
```

The final `v1.0.0` platform validation completed successfully.

---

## GitOps Continuous Delivery

Argo CD is responsible for Kubernetes application delivery.

Git is the source of truth for the desired application state.

The platform uses an Argo CD root application pattern:

```text
argocd/
|-- applications/
|   `-- root.yaml
|-- bootstrap/
|   `-- kustomization.yaml
`-- platform/
    |-- applications/
    |   `-- sample-app.yaml
    |-- projects/
    |   `-- enterprise-platform.yaml
    `-- kustomization.yaml
```

Argo CD continuously reconciles Git configuration with the actual state running in AKS.

This provides the foundation for:

- declarative deployments
- automated synchronization
- drift detection
- self-healing
- auditable application configuration
- separation between CI and CD

---

## Application Configuration

The sample application uses Kustomize to separate reusable Kubernetes manifests from environment-specific configuration.

```text
apps/sample-app/
|-- base/
|   |-- deployment.yaml
|   |-- kustomization.yaml
|   |-- service.yaml
|   `-- serviceaccount.yaml
`-- overlays/
    `-- dev/
        `-- kustomization.yaml
```

The current implementation intentionally focuses on the **DEV** environment.

Additional environments can be introduced later through additional overlays and environment-specific infrastructure configuration.

---

## Workload Identity

The sample application uses AKS Workload Identity.

The design avoids storing Azure credentials inside Kubernetes secrets.

The authentication model is:

```text
Kubernetes Pod
      |
      v
Kubernetes ServiceAccount
      |
      v
AKS Workload Identity
      |
      v
Federated Identity Credential
      |
      v
Azure User Assigned Managed Identity
      |
      v
Azure Resource
```

This provides identity-based access from Kubernetes workloads to Azure resources without application secrets or embedded credentials.

Azure Key Vault is part of the platform's secrets-management architecture.

---

## Identity and Access Model

The platform uses different identities for infrastructure automation and Kubernetes workloads.

### Infrastructure Automation

```text
GitHub Actions
      |
      v
Self-hosted Runner VM
      |
      v
System Assigned Managed Identity
      |
      v
Azure RBAC
```

The runner's Managed Identity is used for Azure authentication by infrastructure workflows.

### Kubernetes Workloads

```text
Application Pod
      |
      v
ServiceAccount
      |
      v
Workload Identity Federation
      |
      v
User Assigned Managed Identity
      |
      v
Azure RBAC
```

This separation avoids sharing credentials between infrastructure automation and application workloads.

---

## AKS Authentication and Authorization

The private AKS cluster integrates with Microsoft Entra ID and Azure RBAC.

The self-hosted runner uses:

```text
az login --identity
        |
        v
az aks get-credentials
        |
        v
kubectl
        |
        v
kubelogin
        |
        v
Microsoft Entra ID
        |
        v
Azure RBAC for Kubernetes
```

The runner receives dedicated AKS roles required for cluster credential retrieval and Kubernetes authorization.

This model was validated through the end-to-end platform validation workflow.

---

## Security

Security is implemented across Azure, Kubernetes and GitHub.

### Azure Security

The platform includes:

- Microsoft Entra ID authentication
- Azure RBAC
- Managed Identity
- AKS Workload Identity
- private AKS API
- Azure Private Endpoints
- Private DNS integration
- Azure Key Vault
- private ACR connectivity
- Network Security Groups

### Kubernetes Security

The Kubernetes security model includes:

- Microsoft Entra ID integration
- Azure RBAC for Kubernetes authorization
- dedicated ServiceAccount
- Workload Identity
- declarative manifests
- workload security configuration
- resource requests and limits

### GitHub Security

The repository follows a pull-request-oriented workflow and uses:

- isolated GitHub Actions workflows
- self-hosted private runner
- Managed Identity for Azure authentication
- Git-based audit history
- infrastructure validation before merge
- GitOps validation

Long-lived Azure credentials are not required by the infrastructure automation path.

---

## Observability

The Azure foundation includes monitoring resources for the Kubernetes platform.

The Terraform implementation contains:

- Log Analytics Workspace
- AKS monitoring integration
- Container Insights foundation

This provides a centralized observability foundation for Kubernetes workloads and future operational dashboards and alerting.

---

## Repository Structure

```text
.
|-- .github/
|   `-- workflows/
|
|-- app/
|
|-- apps/
|   `-- sample-app/
|
|-- argocd/
|   |-- applications/
|   |-- bootstrap/
|   `-- platform/
|
|-- docs/
|   |-- architecture.md
|   `-- azure-foundation.md
|
|-- gitops/
|
|-- policies/
|
|-- security/
|
|-- src/
|
|-- terraform/
|   |-- environments/
|   `-- modules/
|
|-- .gitignore
`-- README.md
```

---

## Technology Stack

| Area | Technology |
|---|---|
| Cloud | Microsoft Azure |
| Infrastructure as Code | Terraform |
| Kubernetes | Azure Kubernetes Service |
| GitOps | Argo CD |
| Kubernetes Configuration | Kustomize |
| Container Registry | Azure Container Registry |
| Secrets Management | Azure Key Vault |
| Identity | Microsoft Entra ID |
| Infrastructure Authentication | Managed Identity |
| Workload Authentication | AKS Workload Identity |
| Authorization | Azure RBAC |
| CI | GitHub Actions |
| CI Runner | Self-hosted Linux runner on Azure |
| Monitoring | Azure Monitor / Log Analytics / Container Insights |
| Source Control | GitHub |

---

## Validation Strategy

The platform is validated at multiple layers.

### 1. Terraform Validation

Pull requests containing Terraform changes execute automated:

```text
terraform fmt
terraform init
terraform validate
terraform plan
```

### 2. Infrastructure Convergence

After the final infrastructure changes, Terraform reported:

```text
No changes. Your infrastructure matches the configuration.
```

### 3. Private Runner Validation

The GitHub self-hosted runner was verified as:

```text
status: online
busy: false

labels:
- self-hosted
- Linux
- X64
- azure
- private
```

### 4. Azure Authentication

The private runner successfully authenticates using:

```bash
az login --identity
```

No GitHub Azure client secret is required for this authentication path.

### 5. Private AKS Validation

The runner successfully retrieves credentials for the private AKS cluster and authenticates using `kubectl` and `kubelogin`.

### 6. Kubernetes Validation

The final validation verifies:

```bash
kubectl get nodes -o wide
kubectl get pods -A
kubectl get applications -A
```

This validates:

- AKS API connectivity
- private DNS/network path
- Microsoft Entra ID authentication
- Azure RBAC authorization
- Kubernetes node visibility
- workload visibility
- Argo CD application visibility

### 7. End-to-End Validation

The final Platform Validation workflow completed successfully on the `main` branch.

This confirms the complete private automation path:

```text
GitHub
   |
   v
Self-hosted Runner
   |
   v
Managed Identity
   |
   v
Azure
   |
   v
Private AKS
   |
   v
Argo CD
   |
   v
Application Workloads
```

---

## Implemented in v1.0.0

### Azure Foundation

- [x] Azure networking foundation
- [x] Modular Terraform architecture
- [x] Terraform remote state
- [x] Private AKS
- [x] Microsoft Entra ID integration
- [x] Azure RBAC
- [x] Azure Container Registry
- [x] ACR Private Endpoint
- [x] Azure Key Vault
- [x] Key Vault Private Endpoint
- [x] Private DNS integration
- [x] Log Analytics
- [x] Container Insights foundation

### Identity and Security

- [x] System Assigned Managed Identity for CI runner
- [x] AKS Workload Identity
- [x] Federated workload identity
- [x] AKS Azure RBAC authorization
- [x] identity-based Azure authentication
- [x] private CI execution path

### CI/CD and GitOps

- [x] Self-hosted GitHub Actions runner
- [x] Terraform CI
- [x] Sample application CI
- [x] GitOps manifest validation
- [x] Argo CD bootstrap
- [x] Argo CD root application pattern
- [x] Argo CD AppProject
- [x] DEV Kustomize overlay
- [x] GitOps application delivery

### Validation

- [x] Terraform formatting validation
- [x] Terraform configuration validation
- [x] Terraform plan automation
- [x] Terraform convergence validation
- [x] private AKS connectivity validation
- [x] Managed Identity validation
- [x] AKS authentication validation
- [x] AKS authorization validation
- [x] workload validation
- [x] Argo CD application validation
- [x] end-to-end platform validation

---

## Future Enhancements

The following capabilities are intentionally outside the `v1.0.0` scope:

- HML environment
- PROD environment
- advanced Azure Policy governance
- additional Kubernetes admission policies
- centralized operational dashboards
- advanced alerting
- automated disaster recovery testing
- advanced FinOps dashboards and budgets
- multi-cluster GitOps
- additional application workloads
- automated environment promotion

---

## Key Engineering Decisions

### GitOps Instead of Direct Deployment

GitHub Actions is used for CI, but Kubernetes deployment responsibility remains with Argo CD.

This preserves Git as the source of truth and prevents CI pipelines from becoming an alternative deployment control plane.

### Private AKS

The Kubernetes API is kept private.

Automation requiring Kubernetes API access runs from inside the Azure network through the self-hosted runner.

### Managed Identity for CI

The Azure-hosted GitHub runner uses Managed Identity instead of long-lived Service Principal credentials.

This reduces credential-management overhead and avoids storing Azure authentication secrets in GitHub for the infrastructure workflow.

### Workload Identity for Applications

Applications use AKS Workload Identity instead of Azure client secrets stored in Kubernetes.

### Modular Terraform

Azure infrastructure is separated into reusable Terraform modules so that network, AKS, ACR, Key Vault, monitoring, private endpoints and identity concerns remain independently maintainable.

### Validation as a Platform Capability

Platform validation is automated through GitHub Actions rather than relying only on manual administrator tests.

This allows the private platform access path itself to be continuously verified.

---

## Documentation

Additional implementation documentation is available in:

- `docs/architecture.md`
- `docs/azure-foundation.md`

---

## Project Status

**Version:** `v1.0.0`

**Environment:** DEV

**Status:** Platform implementation and end-to-end validation completed.

The project demonstrates a functional private Azure GitOps platform with Terraform-managed infrastructure, AKS, Argo CD, GitHub Actions, Managed Identity, Workload Identity and automated platform validation.

---

## Author

**Leandro Martinelli**

Cloud Infrastructure | Azure | Kubernetes | Terraform | DevOps | GitOps | Platform Engineering