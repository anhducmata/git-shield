# git-shield

🛡️ A simple global Git hook to block secret tokens from being committed (e.g., GitHub, AWS, Slack, AI services).

## Features

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

## How It Works

1. **Pre-commit Hook**: Automatically runs before each commit
2. **Pattern Matching**: Uses regex patterns to detect common secret formats
3. **Staged Files Only**: Only scans files that are staged for commit
4. **AI-Specific Scanning**: Enhanced detection for AI/ML files and directories
5. **Blocking**: Prevents commit if secrets are found

## Configuration

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

## Testing

Test your installation:

```bash
bash test.sh
```

This will verify that git-shield is properly installed and can detect secrets.

## Uninstall

```bash
bash uninstall.sh
```

## AI Credential Security Best Practices

When working with AI services:

1. **Use Environment Variables**: Store credentials in `.env` files (add to `.gitignore`)
2. **Cloud Secret Management**: Use AWS Secrets Manager, Azure Key Vault, or Google Secret Manager
3. **Credential Rotation**: Regularly rotate API keys and tokens
4. **Least Privilege**: Use API keys with minimal required permissions
5. **Monitoring**: Set up alerts for credential usage and potential leaks
6. **Development vs Production**: Use different credentials for different environments

## Contributing

Feel free to submit issues and enhancement requests!

## License

MIT License - feel free to use this project for your own needs.
