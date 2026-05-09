# Phase 1 — Linux Foundation

## Overview
Hardened Ubuntu Server configured as the olympus control plane node.
All tasks completed on Ubuntu 24.04.4 LTS.

## Completed Tasks
- SSH key-based authentication configured, password auth disabled
- Root login disabled
- ufw firewall configured (ports 22, 80, 443 only)
- User management, file permissions, process management
- Networking fundamentals and SSH hardening
- Bash scripting fundamentals
- Cron job automation
- Text processing with grep, sed, awk
- Storage fundamentals

## Scripts
- `monitor.sh` — System health monitor (CPU, memory, disk, services)
- `cleanup_logs.sh` — Automated log cleanup for files older than 7 days

## Server Specs
- Hostname: olympus
- OS: Ubuntu 24.04.4 LTS
- CPU: Intel i7-9700K
- RAM: 32GB
- GPU: RTX 2060
