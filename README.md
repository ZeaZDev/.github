# ZeaZDev `.github`

This repository is the public organization profile, community-health baseline, engineering governance reference, and starter workflow catalog for [ZeaZDev](https://github.com/ZeaZDev).

Repository-specific policy takes precedence where it is stricter or more specific.

## Organization baseline

| Path | Purpose |
| --- | --- |
| `profile/README.md` | Public ZeaZDev organization profile |
| `CONTRIBUTING.md` | Contribution and bounded-delivery workflow |
| `SECURITY.md` | Coordinated vulnerability reporting and security handling |
| `SUPPORT.md` | Support and triage guidance |
| `CODE_OF_CONDUCT.md` | Collaboration expectations |
| `GOVERNANCE.md` | Governance, merge-readiness and release principles |
| `REPOSITORY-STANDARDS.md` | Production-oriented repository maturity baseline |
| `RELEASE-CHECKLIST.md` | Evidence-backed release readiness checklist |
| `MAINTAINERS.md` | Maintainer review, merge, incident and release guide |
| `CODEOWNERS` | Ownership baseline for this community-health repository |
| `.github/dependabot.yml` | Automated GitHub Actions dependency updates for this repository |
| `.github/PULL_REQUEST_TEMPLATE.md` | Evidence-oriented pull request template |
| `.github/ISSUE_TEMPLATE/` | Structured bug/feature intake and security routing |
| `workflow-templates/secure-ci.yml` | Least-privilege CI starter |
| `workflow-templates/codeql.yml` | CodeQL starter; adjust language matrix per repository |
| `workflow-templates/dependency-review.yml` | Pull-request dependency risk review starter |
| `workflow-templates/release-attestation.yml` | Artifact-agnostic release supply-chain starter |

Each workflow template has a companion `.properties.json` file so it can be presented as an organization workflow template by GitHub where supported.

## Policy precedence

For a ZeaZDev repository, explicit legal/security requirements and repository-specific policy apply first. Repository-specific `SECURITY.md`, `CONTRIBUTING.md`, workflows, CODEOWNERS, templates, branch/ruleset requirements and maintainer guidance override these fallback defaults.

## Engineering baseline

Shared guidance emphasizes security by design, least privilege, explicit trust boundaries, bounded changes, regression evidence, exact-head CI/security verification, dependency and supply-chain hygiene, migration/rollback awareness, observability, recovery, truthful release maturity and documentation as part of delivery.

## GitHub administrative controls

Some important controls cannot be completed merely by committing files. Organization/repository administrators should configure, according to plan and repository risk: branch protection or rulesets, required reviews and status checks, signed-commit requirements where desired, secret scanning and push protection, code scanning/default setup, Dependabot alerts, private vulnerability reporting, Actions policy/allowed actions, environment protection and deployment approvals, organization secrets/variables, repository visibility/access, and release/tag protection.

Source-controlled files in this repository intentionally do not pretend those administrative settings are enabled. Verify them in GitHub before treating a repository as fully hardened.

## Workflow adoption

Workflow templates are starters, not universal drop-ins. Copy the appropriate template into a project and adapt language/runtime matrices, build commands, tests, package managers and artifact paths to the actual repository. Do not add a security gate that cannot meaningfully analyze that project's code, and do not remove a meaningful gate merely to make CI green.

For release attestations, build the real artifact first, compute/use its exact digest, generate the appropriate SBOM/provenance, and attest that artifact. The shared template deliberately refuses to manufacture placeholder provenance.

## Maintainer rule

Changes to this repository may affect contributor experience across ZeaZDev. Keep organization defaults broadly applicable, evidence-oriented and safe across different languages and architectures. Project-specific assumptions belong in the project repository.

## Public profile

The organization landing page is maintained in [`profile/README.md`](profile/README.md).

---

**ZeaZDev** — secure systems, automated delivery, production-minded engineering.
