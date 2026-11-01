# Agent instructions

This repository contains a scheduled GitHub backup service packaged for container and systemd use. Review the entrypoint, runner, and unit files together when changing its schedule or execution behavior.

## Working and validation

- Keep backup and service changes narrowly scoped; do not run a backup against a real account as a test.
- Validate shell changes with a syntax check and the repository's available lint checks.
- Before changing GitHub Actions, check whether [pschmitt/ci-workflows](https://github.com/pschmitt/ci-workflows) provides a reusable workflow or action. Preserve current behavior and check coverage, and use `@main` for shared workflow or action references.
