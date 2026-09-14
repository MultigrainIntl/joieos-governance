# JoieOS Governance

The single definition of JoieOS compliance for every MultigrainIntl repository.

**Repositories do not copy these rules. They call them.** Editing
`.github/workflows/compliance.yml` here changes the rules everywhere at once.

## How a repository joins

Add one file, `.github/workflows/joieos-compliance.yml`:

```yaml
name: JoieOS Compliance
on: [push, pull_request, workflow_dispatch]
jobs:
  compliance:
    uses: MultigrainIntl/joieos-governance/.github/workflows/compliance.yml@main
```

And a `CLAUDE.md` that references JoieOS — see `templates/CLAUDE.md`.

## What is checked

| Rule | Effect |
|---|---|
| `CONTROL-INHERIT-001` | The repo must carry a `CLAUDE.md` or `AGENTS.md` that references JoieOS |
| `CONTROL-SECRET-001` | No server-side credential committed. Hard failure |
| `CONTROL-SECRET-002` | Client-side Firebase/Maps keys noted, not failed — public by design |
| `CONTROL-VERIFY-001` | `INDEPENDENTLY_VERIFIED` may not be claimed without naming the verifier |
| Build and tests | Run when the project defines them |

Passing proves these checks only. It does not prove the product works.

## Canonical protocol

`MultigrainIntl/ai-project-operating-system` — `joieos/JOIEOS.md` (authority, execution,
memory) and `joieos/JOIEOS_PROTOCOL.md` (philosophy). This repository holds the machine-
checkable subset; that one holds the whole constitution.
