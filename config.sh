#!/bin/bash

# git-shield configuration file
# You can customize the secret patterns and settings here

# Enable/disable git-shield (set to 0 to disable)
ENABLE_GIT_SHIELD=1

# Verbose mode (set to 1 to enable detailed output)
VERBOSE=0

# AI-specific settings
ENABLE_AI_CREDENTIAL_DETECTION=1
ENABLE_ML_FRAMEWORK_DETECTION=1
ENABLE_CLOUD_AI_DETECTION=1

# Custom secret patterns (add your own patterns here)
CUSTOM_PATTERNS=(
    # Add your custom patterns here, for example:
    # "your_custom_pattern_here"
    # "another_pattern_[0-9]{10}"
    
    # Custom AI service patterns
    # "your_ai_service_api_key.*['\"][a-zA-Z0-9]{32,}['\"]"
    # "custom_ml_model_token.*['\"][a-zA-Z0-9]{32,}['\"]"
)

# AI-specific patterns to enable/disable
AI_PATTERNS_ENABLED=(
    "openai"
    "anthropic"
    "google_ai"
    "azure_ai"
    "aws_ai"
    "huggingface"
    "cohere"
    "replicate"
    "stability_ai"
    "elevenlabs"
    "assemblyai"
    "deepgram"
    "pinecone"
    "weaviate"
    "qdrant"
    "chroma"
    "langchain"
    "langsmith"
    "wandb"
    "mlflow"
    "tensorboard"
    "jupyter"
    "streamlit"
    "gradio"
    "fastapi"
    "flask"
    "django"
    "jwt"
    "redis"
    "elasticsearch"
)

# ML/AI file extensions to scan (case insensitive)
AI_FILE_EXTENSIONS=(
    "py"
    "ipynb"
    "r"
    "jl"
    "scala"
    "java"
    "cpp"
    "c"
    "js"
    "ts"
    "json"
    "yaml"
    "yml"
    "toml"
    "ini"
    "cfg"
    "conf"
    "env"
    "sh"
    "bash"
    "zsh"
    "fish"
    "ps1"
    "bat"
    "cmd"
)

# AI/ML directories to scan (relative to repository root)
AI_SCAN_DIRECTORIES=(
    "src"
    "app"
    "api"
    "backend"
    "frontend"
    "models"
    "data"
    "config"
    "scripts"
    "notebooks"
    "experiments"
    "ml"
    "ai"
    "nlp"
    "cv"
    "rl"
    "utils"
    "lib"
    "include"
    "tests"
    "test"
    "spec"
    "fixtures"
)

# File extensions to skip (case insensitive)
SKIP_EXTENSIONS=(
    "jpg"
    "jpeg"
    "png"
    "gif"
    "bmp"
    "ico"
    "svg"
    "pdf"
    "zip"
    "tar"
    "gz"
    "rar"
    "7z"
    "exe"
    "dll"
    "so"
    "dylib"
    "bin"
    "obj"
    "class"
    "jar"
    "war"
    "ear"
    "pyc"
    "pyo"
    "pyd"
    "o"
    "a"
    "lib"
    "dylib"
    "framework"
    "model"
    "pkl"
    "pickle"
    "h5"
    "hdf5"
    "onnx"
    "pb"
    "tflite"
    "pt"
    "pth"
    "ckpt"
    "safetensors"
    "bin"
    "weights"
    "checkpoint"
)

# Directories to skip
SKIP_DIRECTORIES=(
    ".git"
    "node_modules"
    "vendor"
    "dist"
    "build"
    "target"
    "bin"
    "obj"
    "__pycache__"
    ".pytest_cache"
    ".mypy_cache"
    ".coverage"
    "coverage"
    ".nyc_output"
    "logs"
    "tmp"
    "temp"
    "cache"
    ".cache"
    "uploads"
    "downloads"
    "media"
    "static"
    "assets"
    "models"
    "checkpoints"
    "weights"
    "saved_models"
    "trained_models"
    "model_cache"
    "data_cache"
    "dataset_cache"
    "embeddings"
    "vectors"
    "indexes"
    "indices"
)

# Maximum file size to scan (in bytes, 0 = no limit)
MAX_FILE_SIZE=1048576  # 1MB

# AI-specific file size limits
AI_MAX_FILE_SIZE=2097152  # 2MB for AI/ML files

# Exit codes
EXIT_SUCCESS=0
EXIT_SECRETS_FOUND=1
EXIT_ERROR=2

# AI credential severity levels
AI_CREDENTIAL_SEVERITY=(
    "critical:openai_api_key"
    "critical:anthropic_api_key"
    "critical:azure_openai_api_key"
    "high:google_ai_api_key"
    "high:huggingface_token"
    "high:cohere_api_key"
    "medium:replicate_api_token"
    "medium:stability_api_key"
    "low:elevenlabs_api_key"
    "low:assemblyai_api_key"
) 