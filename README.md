# git-shield

🛡️ A simple global Git hook to block secret tokens from being committed (e.g., GitHub, AWS, Slack).

## Installation

**Quick install:**
```bash
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash
```

**Manual install:**
```bash
git clone https://github.com/anhducmata/git-shield.git
cd git-shield
bash install.sh
```

## What It Blocks

- AWS Access Keys
- GitHub Tokens
- Slack Tokens
- Private Keys
- Google API Keys

## Uninstall

```bash
bash uninstall.sh
```
