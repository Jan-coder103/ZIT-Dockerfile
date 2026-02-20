# clean base image containing only comfyui, comfy-cli and comfyui-manager
FROM runpod/worker-comfyui:5.5.1-base

# 1. Install git (required for updating ComfyUI)
RUN apt-get update && apt-get install -y --no-install-recommends git && rm -rf /var/lib/apt/lists/*

# 1. Update ComfyUI Core to the latest version
# We also update the requirements to prevent "ModuleNotFoundError"
RUN cd /comfyui && \
    git switch master 2>/dev/null || git switch -c master origin/master && \
    git pull origin master && \
    pip install --upgrade --no-cache-dir -r requirements.txt

# Install GGUF support (crucial for specific models)
# Using --mode remote to ensure we get the latest registry info
RUN comfy-node-install ComfyUI-GGUF --mode remote

# Download the specific GGUF models defined in your workflow
# UNET: ZIT (GGUF Q4_K_M)
RUN comfy model download --url https://huggingface.co/unsloth/Z-Image-Turbo-GGUF/resolve/main/z-image-turbo-Q4_K_M.gguf --relative-path models/unet --filename z-image-turbo-Q4_K_M.gguf

# CLIP: Qwen3-4B (GGUF Q4_K_M)
RUN comfy model download --url https://huggingface.co/unsloth/Qwen3-4B-GGUF/resolve/main/Qwen3-4B-Q4_K_M.gguf --relative-path models/text_encoders --filename Qwen3-4B-Q4_K_M.gguf

# VAE: VAE
RUN comfy model download --url https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors --relative-path models/vae --filename ae.safetensors

# LoRA: Loras for the workflow
RUN comfy model download --url https://huggingface.co/Snowy4901/Kibeko/resolve/main/kibeko2/ZIT-flat.safetensors --relative-path models/loras --filename ZIT-flat.safetensors
RUN comfy model download --url https://huggingface.co/Snowy4901/Kibeko/resolve/main/kibeko2/ZIT-lenovo.safetensors --relative-path models/loras --filename ZIT-lenovo.safetensors
RUN comfy model download --url https://huggingface.co/Snowy4901/Kibeko/resolve/main/kibeko2/ZIT-mystic.safetensors --relative-path models/loras --filename ZIT-mystic.safetensors
RUN comfy model download --url https://huggingface.co/Snowy4901/Kibeko/resolve/main/kibeko2/ZIT-realistic.safetensors --relative-path models/loras --filename ZIT-realistic.safetensors
RUN comfy model download --url https://huggingface.co/Snowy4901/Kibeko/resolve/main/kibeko2/ZIT-small.safetensors --relative-path models/loras --filename ZIT-small.safetensors

# No COPY workflow_api.json needed here since you send it via API request!
