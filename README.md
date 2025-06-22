# git-shield 🛡️

A Git hook system that prevents secret tokens from being committed to your repositories. Protects against accidentally committing API keys, passwords, and other sensitive information.

## 🚀 Quick Install

```bash
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash
```

The enhanced installer now **automatically finds and protects existing repositories** in common locations!

## 🔧 Installation Options

### Option 1: Automatic Installation (Recommended)
The install script now automatically:
- ✅ Installs git-shield globally for new repositories
- ✅ Scans common directories for existing repositories
- ✅ Automatically protects found repositories
- ✅ Provides interactive options for custom directories

```bash
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/install.sh | bash
```

### Option 2: Manual Installation
```bash
git clone https://github.com/anhducmata/git-shield.git
cd git-shield
./install.sh
```

### Option 3: Protect Existing Repositories Later
If you want to protect existing repositories after installation:

```bash
# Download and run the protection script
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/protect-existing-repos.sh | bash

# Or with custom directories
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/protect-existing-repos.sh | bash -s -- ~/my-projects ~/work-repos

# Or recursively scan a directory
curl -sSL https://raw.githubusercontent.com/anhducmata/git-shield/main/protect-existing-repos.sh | bash -s -- -r ~/projects
```

## 🛡️ Protecting Existing Repositories

### Automatic Protection
The installer now automatically finds and protects repositories in these common locations:
- `~/projects`, `~/Projects`
- `~/code`, `~/Code`
- `~/dev`, `~/Development`
- `~/repos`, `~/git`
- `~/workspace`
- `~/Documents`, `~/Desktop`

### Manual Protection Options

#### Option A: One-liner for specific directory
```bash
find ~/projects -name ".git" -type d | while read d; do (cd "$(dirname "$d")" && git init); done
```

#### Option B: Protect all repositories on your system
```bash
find ~ -name ".git" -type d -maxdepth 4 | while read d; do (cd "$(dirname "$d")" && git init); done
```

#### Option C: Protect specific repository
```bash
cd /path/to/your/repo
git init  # This applies the git-shield hook
```

#### Option D: Use the dedicated protection script
```bash
# Basic usage - scans common directories
./protect-existing-repos.sh

# Scan specific directories
./protect-existing-repos.sh ~/projects ~/work-code

# Recursive scan with custom depth
./protect-existing-repos.sh -r -d 5 ~/projects

# Get help
./protect-existing-repos.sh --help
```

## ✨ Features

🛡️ A simple global Git hook to block secret tokens from being committed (e.g., GitHub, AWS, Slack, AI services).

- **Global Installation**: Automatically applies to all new Git repositories
- **Secret Detection**: Blocks common secret patterns including:
  - AWS Access Keys (`AKIA...`, `ASIA...`)
  - GitHub Personal Access Tokens (`ghp_...`)
  - Google API Keys (`AIza...`)
  - Slack Tokens (`xox...`)
  - Private Keys (`-----BEGIN PRIVATE KEY-----`)
  - **AI Service Credentials** (OpenAI, Anthropic, Google AI, Azure AI, etc.)
  - **ML Framework Credentials** (Hugging Face, Weights & Biases, MLflow, etc.)
  - **Vector Database Credentials** (Pinecone, Weaviate, Qdrant, Chroma, etc.)
- **Easy Setup**: One-command installation
- **Safe**: Only scans staged files, doesn't access your entire codebase
- **Configurable**: Customize patterns and settings via `config.sh`

## 🧪 Testing

Test your installation:

```bash
bash test.sh
```

This will verify that git-shield is properly installed and can detect secrets.

## 🔍 What Gets Detected

### Traditional Secrets
- **AWS Access Keys**: `AKIA[0-9A-Z]{16}`, `ASIA[0-9A-Z]{16}`
- **GitHub Tokens**: `ghp_[A-Za-z0-9]{36}`
- **Slack Tokens**: `xox[baprs]-[0-9a-zA-Z]+`
- **Private Keys**: `-----BEGIN PRIVATE KEY-----`
- **Google API Keys**: `AIza[0-9A-Za-z-_]{35}`

### AI Service Credentials
- **OpenAI API Keys**: `sk-[a-zA-Z0-9]{48}`, `sk-proj-[a-zA-Z0-9]{48}`
- **Anthropic API Keys**: `sk-ant-[a-zA-Z0-9]{48}`, `sk-ant-api03-[a-zA-Z0-9]{48}`
- **Google AI (Vertex AI, Gemini)**: `AIza[0-9A-Za-z-_]{35,39}`
- **Azure OpenAI**: `sk-[a-zA-Z0-9]{32}`
- **Hugging Face Tokens**: `hf_[a-zA-Z0-9]{39}`
- **Cohere API Keys**: Various patterns
- **Replicate API Keys**: `r8_[a-zA-Z0-9]{37}`
- **Stability AI**: Various patterns
- **ElevenLabs API Keys**: Various patterns
- **AssemblyAI API Keys**: Various patterns
- **Deepgram API Keys**: Various patterns

### ML/AI Framework Credentials
- **Weights & Biases**: `wandb_api_key` patterns
- **MLflow**: Tracking URIs with credentials
- **TensorBoard**: Credential patterns
- **Jupyter**: Token patterns
- **Streamlit**: Secret patterns
- **Gradio**: API key patterns
- **LangChain**: API key patterns
- **LangSmith**: API key patterns

### Vector Database Credentials
- **Pinecone**: API key patterns
- **Weaviate**: API key patterns
- **Qdrant**: API key patterns
- **Chroma**: API key patterns

### Web Framework Secrets
- **FastAPI**: API key patterns
- **Flask**: Secret key patterns
- **Django**: Secret key patterns
- **Node.js JWT**: Secret patterns

### Database Credentials
- **Redis**: Password patterns
- **Elasticsearch**: Password patterns
- **PostgreSQL/MySQL/MongoDB**: URL patterns with credentials

## 🛠️ Configuration

The hook is installed globally and will apply to all new Git repositories. To apply to existing repositories:

```bash
# Apply to all repos in ~/projects (prompted during install)
# Or manually for specific repos:
cd /path/to/your/repo
git init  # This will apply the global template
```

### Customizing AI Credential Detection

Edit `config.sh` to customize AI credential detection:

```bash
# Enable/disable specific AI credential types
ENABLE_AI_CREDENTIAL_DETECTION=1
ENABLE_ML_FRAMEWORK_DETECTION=1
ENABLE_CLOUD_AI_DETECTION=1

# Add custom AI service patterns
CUSTOM_PATTERNS=(
    "your_ai_service_api_key.*['\"][a-zA-Z0-9]{32,}['\"]"
    "custom_ml_model_token.*['\"][a-zA-Z0-9]{32,}['\"]"
)
```

## 📋 Supported Patterns

// ... existing code ...

## 🚫 Uninstall

```bash
bash uninstall.sh
```

## 🤝 Contributing

Feel free to submit issues and enhancement requests!

## 📄 License

MIT License - feel free to use this project for your own needs.
