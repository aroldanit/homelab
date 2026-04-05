# Ollama — Local LLM Inference on Olympus

## Overview
Ollama enables running large language models locally on personal hardware.
This setup runs Mistral 7B on olympus and exposes it as a REST API accessible
across the homelab network.

**Node:** olympus — Intel i7 9th gen, 32GB RAM, RTX 2060  
**Model:** Mistral 7B  
**Port:** 11434

---

## Installation
```bash
curl -fsSL https://ollama.com/install.sh | sh
```

Fetches and executes the Ollama install script.  
Flags: `-f` fail on error, `-s` silent, `-S` show errors, `-L` follow redirects.

---

## Usage

### Pull a model
```bash
ollama pull mistral
```
Downloads Mistral 7B to local storage. Similar pattern to `docker pull`.

### Run interactively
```bash
ollama run mistral
```
Opens an interactive terminal session with the model. Exit with `/bye`.

### Call via API
```bash
curl http://localhost:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "Your prompt here"
}'
```
Ollama exposes a local REST API on port 11434.  
This is the pattern used for scripting and automation — same structure as
any commercial AI API (OpenAI, Anthropic, etc).

---

## Network Access from Cato

Expose Ollama on the local network from olympus:
```bash
OLLAMA_HOST=0.0.0.0 ollama serve
```

Query from cato:
```bash
curl http://OLYMPUS_IP:11434/api/generate -d '{
  "model": "mistral",
  "prompt": "Your prompt here"
}'
```

**Architecture pattern:** olympus acts as the inference node, cato consumes
the API as a client. One service, two nodes — mirrors production AI
infrastructure deployment.

---

## Skills Demonstrated
- Linux service installation and configuration
- REST API consumption via curl
- Local network service exposure
- Distributed homelab architecture
- Local LLM inference and model management

---

## Next Steps
- [ ] Write Bash script to send file contents to Ollama API and return summary
- [ ] Configure Ollama as a systemd service on olympus for persistence
- [ ] Test latency and throughput from cato over local network
