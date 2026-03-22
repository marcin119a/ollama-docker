#!/bin/bash

set -e

echo "=== UPDATE SYSTEM ==="
sudo apt update -y
sudo apt upgrade -y

echo "=== INSTALL DEPENDENCIES ==="
sudo apt install -y curl git

echo "=== INSTALL OLLAMA ==="
curl -fsSL https://ollama.com/install.sh | sh

echo "=== CONFIGURE OLLAMA ENV ==="

# tworzymy override dla systemd
sudo mkdir -p /etc/systemd/system/ollama.service.d

sudo tee /etc/systemd/system/ollama.service.d/override.conf > /dev/null <<EOF
[Service]
Environment="OLLAMA_HOST=0.0.0.0"
Environment="OLLAMA_ORIGINS=*"
Environment="OLLAMA_GPU=1"
EOF

echo "=== RELOAD SYSTEMD ==="
sudo systemctl daemon-reexec
sudo systemctl daemon-reload

echo "=== ENABLE & START OLLAMA ==="
sudo systemctl enable ollama
sudo systemctl restart ollama

echo "Waiting for Ollama to start..."
sleep 5

echo "=== CHECK PORT ==="
ss -tulnp | grep 11434 || echo "⚠️ Port 11434 not visible yet"

echo "=== OPEN FIREWALL (if UFW exists) ==="
if command -v ufw &> /dev/null
then
    sudo ufw allow 11434/tcp || true
fi

echo "=== PULL MODEL qwen3-vl:4b ==="
ollama pull qwen3-vl:4b

echo "=== TEST MODEL ==="
ollama run qwen3-vl:4b "Powiedz w jednym zdaniu czym jest multimodalny model AI"

echo "=== TEST HTTP LOCAL ==="
curl http://localhost:11434 || echo "⚠️ HTTP test failed"

echo "=== NETWORK INFO ==="
IP=$(hostname -I | awk '{print $1}')
echo "Server IP: $IP"
echo "Endpoint: http://$IP:11434"

echo "=== DONE ==="
echo "Jeśli nie działa z zewnątrz:"
echo "1. Sprawdź Security Group (AWS/Brev)"
echo "2. Otwórz port 11434"
echo "3. curl http://$IP:11434"
