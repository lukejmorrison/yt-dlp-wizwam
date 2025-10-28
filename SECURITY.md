# Security Policy

## Supported Versions

The project is currently in alpha (0.x) releases. Security fixes will be provided on a best-effort basis for the latest published version.

## Reporting a Vulnerability

If you discover a security vulnerability, please **do not** create a public issue. Instead:

1. Email the maintainer at [security@wizwam.com](mailto:security@wizwam.com) with the details.
2. Include steps to reproduce the issue and the potential impact.
3. Allow at least 72 hours for an initial response.

All reports will be acknowledged, investigated, and resolved as quickly as possible. When a fix is ready, coordinated disclosure will be discussed with the reporter.

## Handling Sensitive Information

- Do not commit API keys, passwords, or tokens to the repository.
- Store secrets in environment variables or configuration files that are excluded via `.gitignore`.
- If a secret is accidentally committed, contact the maintainer immediately so it can be revoked and replaced.

## Scope

This policy covers the yt-dlp-wizwam Python package, its CLI, web interface, and related scripts contained in this repository.

Thank you for helping keep yt-dlp-wizwam safe for everyone!
