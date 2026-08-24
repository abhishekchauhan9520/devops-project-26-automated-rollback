# Project 26 — Automated Deployment Rollback

A production-style deployment workflow that records a last-known-good release, deploys a candidate, verifies health gates, and automatically rolls back when verification fails.

## Flow

```text
Known-good release
       ↓
Record release state
       ↓
Deploy candidate
       ↓
Health / smoke checks
   ┌───┴────┐
 PASS      FAIL
  ↓          ↓
Promote    Roll back
  ↓          ↓
Record     Verify recovery
success    Record incident
```

## Repository layout

- `app/` — small HTTP application
- `deploy/` — versioned release manifests
- `scripts/deploy.sh` — guarded deployment entrypoint
- `scripts/health_check.sh` — deployment verification
- `scripts/rollback.sh` — rollback to recorded known-good release
- `scripts/state.sh` — release-state management
- `tests/` — local state-machine and safety checks
- `.github/workflows/rollback.yml` — CI validation

## Safety model

A candidate must pass the health gate before it becomes the new known-good release. A failed verification triggers rollback to the previous known-good release. Rollback is idempotent and refuses to operate without a recorded release.

The local scripts model the release-control logic. A real Kubernetes implementation can replace the deployment adapter with `kubectl`, Argo Rollouts, or another controller without changing the release-state and gate logic.
