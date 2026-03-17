#!/bin/bash

set -e

echo "=== UPDATE SYSTEM ==="
sudo apt update && sudo apt upgrade -y

echo "=== INSTALL DEPENDENCIES ==="
sudo apt install -y curl git

echo "=== INSTALL OLLAMA ==="
curl -fsSL https://ollama.com/install.sh | sh

echo "=== START OLLAMA (BACKGROUND) ==="
# expose na wszystkie interfejsy (ważne dla n8n)
export OLLAMA_HOST=0.0.0.0
export OLLAMA_ORIGINS=*

nohup ollama serve > ollama.log 2>&1 &

echo "Waiting for Ollama to start..."
sleep 5

echo "=== PULL MODEL qwen3-vl:4b ==="
ollama pull qwen3-vl:4b

echo "=== TEST MODEL ==="
ollama run qwen3-vl:4b "Powiedz w jednym zdaniu czym jest multimodalny model AI"

echo "=== DONE ==="
echo "Ollama działa na: http://0.0.0.0:11434"
echo "Logi: tail -f ollama.log"
