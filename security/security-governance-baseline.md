# Security & Governance Baseline

This document defines the minimum security and governance controls for the Enterprise GitOps Platform on Azure.

The controls defined here must be implemented, tested and documented during the project.

## 1. Identity and Access

### SEC-001 — No Long-Lived Azure Credentials

GitHub Actions must authenticate to Microsoft Azure using OIDC federation.

Long-lived Azure client secrets must not be stored in GitHub.

**Validation**

- GitHub Actions authenticates using OIDC
- no Azure client secret exists in GitHub Actions secrets
- federated identity configuration is documented

### SEC-002 — Least Privilege

Azure identities must receive only the permissions required for their responsibilities.

**Validation**

- Terraform identity permissions are documented
- GitHub Actions permissions are documented
- workload identities have scoped access
- unnecessary Owner permissions are avoided

### SEC-003 — Workload Identity

AKS workloads requiring access to Azure resources must use AKS Workload Identity.

**Validation**

- Kubernetes ServiceAccount is mapped to an Azure identity
- workload accesses the target Azure service without stored Azure credentials

---

## 2. Secrets Management

### SEC-004 — Secrets Must Not Be Stored in Git

Application secrets must not be committed to the repository.

Secrets must be stored in Azure Key Vault.

**Validation**

- repository contains no application credentials
- application retrieves a secret through the approved integration
- secret access is identity-based

---

## 3. Container Security

### SEC-005 — Container Image Scanning

Container images must be scanned for known vulnerabilities before promotion.

**Validation**

- CI pipeline executes an image vulnerability scan
- critical findings can fail the pipeline

### SEC-006 — Non-Root Workloads

Application containers should run without root privileges.

Target controls include:

```yaml
securityContext:
  runAsNonRoot: true
  allowPrivilegeEscalation: false
```

### SEC-007 — Resource Controls

Application workloads must define CPU and memory requests and limits.

---

## 4. Kubernetes Governance

### GOV-001 — Namespace Isolation

Application environments must use separate Kubernetes namespaces.

Target model:

```text
app-dev
app-hml
app-prod
```

### GOV-002 — Network Policies

Network Policies must restrict unnecessary workload communication.

The default design should move toward deny-by-default with explicitly allowed communication.

### GOV-003 — Admission Governance

Policy controls will validate Kubernetes workloads before admission.

Controls should evaluate:

- privileged containers
- required resource limits
- security context
- approved registries
- required labels

### GOV-004 — Controlled Production Changes

Production configuration must be changed through Git.

Direct manual production changes are considered configuration drift.

Argo CD must be able to detect this drift.

---

## 5. Azure Governance

### GOV-005 — Mandatory Tags

Azure resources must use standardized tags.

Initial required tags:

```text
Environment
Application
Owner
ManagedBy
CostCenter
Project
```

Example:

```text
Environment = lab
Application = enterprise-gitops
ManagedBy   = terraform
Project     = enterprise-azure-gitops-platform
```

### GOV-006 — Azure Policy

Azure Policy will be used to evaluate platform compliance.

Target areas include:

- required tags
- allowed Azure regions
- AKS security configuration
- diagnostic settings
- approved resource configurations

### GOV-007 — Infrastructure as Code

Azure infrastructure managed by the project must be provisioned through Terraform.

Manual Azure Portal changes should be avoided except when explicitly required for testing or investigation.

---

## 6. GitHub Governance

### GOV-008 — Pull Request Workflow

Changes to protected branches should occur through Pull Requests.

### GOV-009 — CODEOWNERS

Critical platform paths will have defined ownership.

Examples:

```text
/terraform/
/argocd/
/gitops/overlays/prod/
/policies/
/security/
```

### GOV-010 — Production Approval

Production changes should require explicit approval before promotion.

### GOV-011 — Automated Validation

Pull Requests should execute automated checks such as:

- Terraform validation
- Kubernetes manifest validation
- security scanning
- policy validation

---

## 7. GitOps Controls

### GITOPS-001 — Git as Source of Truth

The desired application state must exist in Git.

### GITOPS-002 — No kubectl apply from CI

GitHub Actions must not directly deploy application workloads using:

```text
kubectl apply
```

The deployment responsibility belongs to Argo CD.

### GITOPS-003 — Drift Detection

Manual changes in Kubernetes must be detected by Argo CD.

### GITOPS-004 — Self-Healing

Selected applications will use Argo CD self-healing to restore the state declared in Git.

### GITOPS-005 — Auditable Rollback

Application rollback must be performed through an auditable GitOps workflow.

---

## 8. Observability

### OBS-001 — Centralized Platform Logs

Platform diagnostics must be sent to an approved monitoring destination.

Target services:

- Azure Monitor
- Log Analytics

### OBS-002 — Kubernetes Visibility

The lab must provide visibility into:

- workload health
- Kubernetes events
- resource utilization
- deployment failures

### OBS-003 — GitOps Visibility

The lab must provide visibility into:

- Argo CD synchronization state
- application health
- OutOfSync resources
- synchronization failures

---

## 9. FinOps

### FIN-001 — Resource Ownership

Azure resources must contain ownership and project metadata through tags.

### FIN-002 — Workload Resource Governance

Kubernetes workloads must define CPU and memory requests and limits.

### FIN-003 — Lab Lifecycle

Resources created for testing must be identifiable and safely removable through Terraform.

---

## 10. Compliance Validation Matrix

| ID | Control | Implementation | Validation |
|---|---|---|---|
| SEC-001 | OIDC authentication | Planned | Pending |
| SEC-002 | Least privilege | Planned | Pending |
| SEC-003 | Workload Identity | Planned | Pending |
| SEC-004 | Key Vault secrets | Planned | Pending |
| SEC-005 | Image scanning | Planned | Pending |
| SEC-006 | Non-root containers | Planned | Pending |
| SEC-007 | Resource controls | Planned | Pending |
| GOV-001 | Namespace isolation | Planned | Pending |
| GOV-002 | Network Policies | Planned | Pending |
| GOV-003 | Admission governance | Planned | Pending |
| GOV-004 | Controlled production | Planned | Pending |
| GOV-005 | Mandatory Azure tags | Planned | Pending |
| GOV-006 | Azure Policy | Planned | Pending |
| GOV-007 | Terraform IaC | Planned | Pending |
| GOV-008 | Pull Request workflow | Planned | Pending |
| GOV-009 | CODEOWNERS | Planned | Pending |
| GOV-010 | Production approval | Planned | Pending |
| GOV-011 | Automated validation | Planned | Pending |
| GITOPS-001 | Git source of truth | Planned | Pending |
| GITOPS-002 | No deployment from CI | Planned | Pending |
| GITOPS-003 | Drift detection | Planned | Pending |
| GITOPS-004 | Self-healing | Planned | Pending |
| GITOPS-005 | Auditable rollback | Planned | Pending |
| OBS-001 | Centralized logs | Planned | Pending |
| OBS-002 | Kubernetes visibility | Planned | Pending |
| OBS-003 | GitOps visibility | Planned | Pending |
| FIN-001 | Resource ownership | Planned | Pending |
| FIN-002 | Resource governance | Planned | Pending |
| FIN-003 | Lab lifecycle | Planned | Pending |