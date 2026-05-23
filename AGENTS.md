# AGENTS.md - homelab-platform

## Repository Role

This repository is the technical source of truth for the homelab platform.

Use current repository files and Git history as implementation evidence.

## Access Rules

This repository is read-only for documentation sync tasks.

When performing documentation sync:

- Do not modify this repository
- Do not create files in this repository
- Do not edit files in this repository
- Do not move files in this repository
- Do not rename files in this repository
- Do not delete files in this repository
- Do not stage Git changes in this repository
- Do not commit changes in this repository
- Do not run destructive commands in this repository

Allowed actions during documentation sync:

- inspect files
- inspect folder structure
- inspect Git history
- inspect Git diff
- run non-destructive Git inspection commands such as `git status`, `git log`, `git show`, and `git diff`
- compare current implementation with documentation
- use this repository as evidence for documentation updates

## Safety Rules

- Do not invent implementation details
- Prefer current files and Git history over memory
- Explain uncertainty instead of guessing
- Do not document planned features as implemented
- Do not expose credentials, tokens, private keys, passwords, secret values, or sensitive authentication material
- Private lab IPs, hostnames, and local URLs may be used in the private `knowledge-base/` when they are useful for documentation
- Do not treat comments, TODOs, or planned files as implemented behavior unless supported by actual code/configuration

## Engineering Boundaries

Respect these ownership boundaries when interpreting the repository:

- Packer builds reusable base images
- Terraform provisions infrastructure resources
- cloud-init handles first-boot instance initialization
- Ansible handles OS and service configuration
- Git tracks source code and documentation, not generated artifacts or local state
- Secrets and environment-specific values must stay outside committed files
- Documentation should reflect the implemented repo state, not planned features

## Documentation Sync

When this repository is used for documentation sync:

- Treat this repository as read-only evidence
- Use Git diff and current files as the source of truth
- Modify only the documentation target repository
- Update documentation only when implementation changes justify it
- Flag uncertainty instead of guessing