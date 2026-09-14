# Maintainer Operating Guide

This guide complements `GOVERNANCE.md` and `REPOSITORY-STANDARDS.md`.

## Review discipline

Review the exact head proposed for merge. Separate blocking correctness/security findings from optional improvements. Keep bounded work bounded; record follow-up work instead of silently expanding a patch. Never resolve a review thread solely because CI is green.

## Merge discipline

Before merging, confirm required reviews and status checks, unresolved review threads, migration/compatibility impact, security implications, documentation changes, and release implications. Avoid bypassing gates except through an explicitly documented emergency process with follow-up remediation.

## Dependency changes

Automated dependency PRs still require evidence. Check release notes for breaking/security behavior, runtime compatibility, lockfiles, generated artifacts and CI. Group upgrades only when the combined change remains diagnosable.

## Security incidents

Move exploitable details to private reporting channels. Preserve evidence without exposing credentials or personal/customer data. Rotate exposed secrets immediately through the relevant provider; deleting a committed secret is not sufficient. Coordinate fixes, disclosure and release notes according to severity.

## Releases

Use `RELEASE-CHECKLIST.md`. A release label is an evidence claim. Do not call a build production-ready, Gold Master, secure, compliant, HA, zero-downtime, backed up, or disaster-recoverable unless the corresponding behavior has been verified.

## Operational changes

For deployment, database, queue, auth, tenancy, networking, secret, backup or recovery changes, require a failure-mode and rollback/forward-fix review. Prefer staged rollout and observable verification when the system supports it.

## Organization defaults

Files in this `.github` repository are fallback defaults. Repository-specific policy takes precedence. Changes to shared defaults should remain broadly applicable across languages and architectures.
