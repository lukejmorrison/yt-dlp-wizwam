# Contributing to yt-dlp-wizwam

First off, thank you for considering contributing! This project aims to provide a polished, easy-to-install wrapper around [yt-dlp](https://github.com/yt-dlp/yt-dlp) with both CLI and web interfaces. Contributions of all kinds are welcome—from bug reports and documentation fixes to new features.

## Code of Conduct

This project adheres to the [Contributor Covenant](CODE_OF_CONDUCT.md). By participating, you are expected to uphold this code. Please report unacceptable behavior to [maintainer@wizwam.com](mailto:maintainer@wizwam.com).

## Getting Started

1. **Fork** the repository and clone your fork locally.
2. **Create a virtual environment** (Python 3.10+):
   ```bash
   python -m venv .venv
   source .venv/bin/activate
   pip install -e ".[dev]"
   ```
3. **Run the test suite** (when available):
   ```bash
   pytest
   ```
4. **Create a feature branch:**
   ```bash
   git checkout -b feature/short-description
   ```

## Development Workflow

1. Write code following [PEP 8](https://peps.python.org/pep-0008/) guidelines.
2. Add or update tests where appropriate.
3. Update documentation (README, CHANGELOG) when changing user-facing behavior.
4. Ensure the test suite passes (`pytest`).
5. If adding dependencies, make sure they are recorded in `pyproject.toml` and `requirements.txt`.
6. Commit using clear, descriptive messages (see **Commit Guidelines** below).
7. Push to your fork and open a pull request against `main`.

## Commit Guidelines

- Use the conventional commit style when possible:
  - `feat: add new macro runner`
  - `fix: handle multi-stream progress`
  - `chore: update dependencies`
- Keep commits focused—one logical change per commit.
- Reference issues with `Fixes #123` when applicable.

## Pull Request Checklist

Before submitting a PR:

- [ ] Tests added/updated and passing
- [ ] Linting/formatting applied (`black`, `flake8`, etc., when available)
- [ ] Documentation updated (README, STATUS, CHANGELOG)
- [ ] No secrets or user-specific paths committed

Please include a summary of the changes and any relevant screenshots or logs.

## Reporting Issues

Use [GitHub Issues](https://github.com/lukejmorrison/yt-dlp-wizwam/issues) to report bugs or request features. Please include:

- Environment details (OS, Python version)
- Steps to reproduce
- Expected vs. actual behavior
- Relevant logs or stack traces (redacted for sensitive data)

## Security Issues

Do **not** open a public issue for suspected security vulnerabilities. Instead, follow the instructions in [SECURITY.md](SECURITY.md).

## Community

- Project updates: https://github.com/lukejmorrison/yt-dlp-wizwam
- Maintainer: Luke J Morrison ([@lukejmorrison](https://github.com/lukejmorrison))

Thank you for helping make yt-dlp-wizwam better! 🙌
