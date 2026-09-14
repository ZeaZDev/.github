# ZeaZDev `.github`

This repository contains the public GitHub organization profile and organization-wide community health defaults for [ZeaZDev](https://github.com/ZeaZDev).

## Purpose

The repository provides shared guidance for ZeaZDev projects so contributors, reviewers, maintainers, and security researchers have a consistent baseline even when an individual repository does not yet define its own policy.

Repository-specific files take precedence over these defaults when both exist.

## Included Files

| Path | Purpose |
| --- | --- |
| `profile/README.md` | Public ZeaZDev organization profile |
| `CONTRIBUTING.md` | Default contribution and engineering workflow guidance |
| `SECURITY.md` | Default vulnerability-reporting and security-handling policy |
| `SUPPORT.md` | Default support and triage guidance |
| `CODE_OF_CONDUCT.md` | Default collaboration and conduct expectations |
| `GOVERNANCE.md` | Organization governance, scope, merge-readiness, and release principles |
| `.github/ISSUE_TEMPLATE/bug_report.yml` | Structured bug-report template |
| `.github/ISSUE_TEMPLATE/feature_request.yml` | Structured feature-request template |
| `.github/ISSUE_TEMPLATE/config.yml` | Issue-template configuration and security links |
| `.github/PULL_REQUEST_TEMPLATE.md` | Evidence-oriented pull request template |

## Policy Precedence

For any ZeaZDev repository:

1. explicit legal/security requirements and repository-specific policy apply first;
2. repository-specific `SECURITY.md`, `CONTRIBUTING.md`, support files, templates, and documented maintainer rules override organization defaults;
3. this repository provides the fallback baseline where a project does not define its own guidance.

## Engineering Baseline

The shared defaults emphasize:

- bounded, reviewable changes;
- security-by-design and explicit trust boundaries;
- regression testing where practical;
- evidence-backed CI/security gates;
- migration and rollback awareness;
- observability and operational readiness;
- documentation as part of delivery;
- responsible vulnerability disclosure;
- dependency and supply-chain hygiene;
- scope control during implementation and review.

## Maintaining This Repository

Changes here can affect contributor experience across the organization. Keep shared policy broadly applicable and avoid project-specific assumptions unless they belong only in the organization profile.

Before changing a shared template or policy, consider whether the change is suitable for repositories with different languages, runtimes, architectures, and release models.

## Public Organization Profile

The public profile is maintained in [`profile/README.md`](profile/README.md).

---

**ZeaZDev** — secure systems, automated delivery, production-minded engineering.
