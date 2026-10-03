# Enterprise GitOps Platform — Architecture

## 1. Architecture Goals

The platform is designed to demonstrate an enterprise-oriented application delivery architecture based on GitOps principles.

The main goals are:

- declarative infrastructure and application delivery
- Git as the source of truth
- separation between CI and CD
- identity-based authentication
- least-privilege access
- policy-driven governance
- secure secrets management
- automated drift detection and remediation
- auditable production changes
- centralized observability
- cost governance

---

## 2. High-Level Architecture

```text
                           Developer
                               |
                         Pull Request
                               |
                               v
                         +-----------+
                         |  GitHub   |
                         +-----------+
                          /    |    \
                         /     |     \
                 Source Code   |    GitOps
                               |
                         GitHub Actions
                               |
                         OIDC Federation
                               |
                               v
                     Microsoft Entra ID
                               |
                               v
+-------------------------------------------------------------+
|                       Microsoft Azure                       |
|                                                             |
|  Governance                                                 |
|  +-------------------------------------------------------+  |
|  | Azure Policy | RBAC | Tags | Defender | Diagnostics   |  |
|  +-------------------------------------------------------+  |
|                                                             |
|       +---------------+            +----------------+       |
|       |      ACR      |            |   Key Vault    |       |
|       +-------+-------+            +-------+--------+       |
|               |                            |                |
|               | Container Images           | Secrets        |
|               v                            v                |
|       +------------------------------------------------+    |
|       |                     AKS                        |    |
|       |                                                |    |
|       |  +-------------+                               |    |
| Git --+->|   Argo CD   |                               |    |
|       |  +------+------+                               |    |
|       |         |                                      |    |
|       |    Desired State                               |    |
|       |         |                                      |    |
|       |   +-----+------+--------+                      |    |
|       |   |            |        |                      |    |
|       |  DEV          HML      PROD                    |    |
|       |                                                |    |
|       | Workload Identity | Policies | Network Policy  |    |
|       +------------------------------------------------+    |
|                                                             |
|            Azure Monitor / Log Analytics                    |
+-------------------------------------------------------------+
```

---

## 3. CI/CD Responsibility Model

### Continuous Integration — GitHub Actions

GitHub Actions is responsible for:

- source validation
- automated testing
- security scanning
- container image creation
- publishing images to ACR
- updating the desired application version in Git

GitHub Actions does not directly deploy application workloads to AKS.

### Continuous Delivery — Argo CD

Argo CD is responsible for:

- monitoring the GitOps configuration
- comparing desired and actual state
- synchronizing Kubernetes resources
- detecting configuration drift
- self-healing
- application health monitoring
- rollback and recovery workflows

This separation prevents the CI platform from requiring direct deployment privileges inside the Kubernetes cluster.

---

## 4. Environment Model

The platform contains three logical application environments:

```text
DEV
 |
 v
HML
 |
 v
PROD
```

Each environment maintains its own GitOps configuration.

```text
gitops/
|
+-- base/
|
`-- overlays/
    +-- dev/
    +-- hml/
    `-- prod/
```

Changes are promoted through Git rather than by manually modifying Kubernetes resources.

Production changes require controlled Git workflows.

---

## 5. Identity Architecture

Human and workload identities must be separated.

### Human Access

Human access will use:

- Microsoft Entra ID
- Azure RBAC
- AKS authorization controls
- least privilege

### GitHub Actions

GitHub Actions will authenticate to Azure using:

```text
GitHub Actions
      |
      | OIDC Token
      v
Microsoft Entra ID
      |
      | Federated Identity
      v
Azure RBAC
```

No long-lived Azure client secret should be required by the CI pipeline.

### Kubernetes Workloads

Applications running in AKS will use AKS Workload Identity where Azure resource access is required.

---

## 6. Secrets Management

Secrets must not be committed to Git.

The target pattern is:

```text
Azure Key Vault
       |
       | Workload Identity
       v
Secrets Integration
       |
       v
AKS Workload
```

The exact Kubernetes-to-Key-Vault integration will be implemented and validated during the security phase.

---

## 7. Network Architecture

The platform will follow controlled network access principles.

The target design includes:

- dedicated Azure Virtual Network
- dedicated AKS subnet
- controlled ingress and egress
- Kubernetes Network Policies
- Private Endpoint evaluation
- Private DNS evaluation
- restricted access to Azure PaaS services where appropriate

Network architecture will be implemented through Terraform.

---

## 8. Governance Model

Governance exists at three layers.

### Azure

Controls include:

- Azure Policy
- Azure RBAC
- mandatory resource tags
- diagnostic settings
- approved configurations
- security posture controls
- cost governance

### Kubernetes

Controls include:

- namespace isolation
- Pod Security controls
- non-root containers
- restricted container privileges
- resource requests and limits
- Network Policies
- approved registries
- admission policies

### GitHub

Controls include:

- protected branches
- Pull Requests
- CODEOWNERS
- required reviews
- automated validation
- security scanning
- controlled production promotion

---

## 9. GitOps Governance Principle

GitOps defines:

> What state should exist?

Governance policies define:

> What state is allowed to exist?

Both controls work together.

A Git manifest can represent the desired state while admission and governance policies determine whether that desired state complies with organizational requirements.

---

## 10. Observability

The platform will provide visibility across infrastructure, Kubernetes and GitOps.

Target capabilities include:

- Azure Monitor
- Log Analytics
- AKS monitoring
- Kubernetes logs and events
- Argo CD application health
- Argo CD synchronization status
- platform diagnostics

---

## 11. FinOps

Cost management is part of the architecture.

Controls include:

- standardized Azure tags
- environment identification
- ownership identification
- Kubernetes resource requests and limits
- logging cost awareness
- ACR lifecycle management
- controlled creation and destruction of lab resources

---

## 12. Architecture Principles

The implementation follows these principles:

1. Everything possible should be declarative.
2. Infrastructure changes should be made through Terraform.
3. Application changes should be promoted through Git.
4. CI should not directly deploy application workloads to AKS.
5. Secrets should not be stored in Git.
6. Long-lived cloud credentials should be avoided.
7. Access should follow least privilege.
8. Security and governance should be implemented as code where practical.
9. Production changes should be auditable.
10. Manual drift should be detectable and recoverable.