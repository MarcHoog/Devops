# 🛠️ Codex: DevOps Agent

## Overview

This repository contains a collection of **Python-based DevOps automation scripts** designed to deploy and manage applications on **Linux systems**. Scripts use `argparse` for CLI interfaces and are intended to be modular, reusable, and easy to invoke either manually or via CI/CD (e.g., Azure DevOps, GitHub Actions).

### Key Folders

* `scripts/`: Main automation entry points (CLI tools).

## 🧠 Script Design Philosophy

* **Argparse-based CLI**: All scripts expose clear CLI arguments. Avoids hidden config.
* **Stateless execution**: Scripts should be idempotent or safe to rerun.
* **No `.env` or magic files**: Explicit over implicit. Pass it in, log it out.
* **Modular utils**: Scripts should rely on `utils/` for SSH, config edits, etc.
* **Fail loudly**: Use logging and `sys.exit(1)` on failure. Avoid silent skips.

## 🧰 Tools & Libraries

* Python 3.10+
* `jinja2` for config generation
* `argparse` for CLI interface
* (Optional) `rich` or `loguru` for nicer logs

## 🪵 Logging

Each script logs to stdout by default. You can redirect to a file or pipe into a logging system.

Example:

```bash
python scripts/deploy_app.py ... > deploy.log 2>&1
```

## 🔒 Security

* **No passwords in code** — use SSH key-based auth.
* **Sanitize inputs** from CLI before using them in shell commands.

## 👷 Best Practices

* Document new scripts in this file.
* Keep each script focused — no 500-line do-it-alls.
* Include examples at the top of each script in the docstring.

## ✅ Adding a New Script

1. Place it in `scripts/`, name it descriptively (`do_thing.py`)
2. Use `argparse` to define CLI inputs
4. Add an example here under **Usage**
5. Keep the entrypoint in a `main()` function:

   ```python
   def main():
       ...
   if __name__ == "__main__":
       main()
   ```
## Usage

* `deploy_wireguard.py` - Deploys a simple WireGuard VPN and manage clients.
  Example:
  ```bash
  sudo python3 scripts/deploy_wireguard.py deploy --endpoint YOUR_PUBLIC_IP
  sudo python3 scripts/deploy_wireguard.py add-client --name alice --endpoint YOUR_PUBLIC_IP
  ```
