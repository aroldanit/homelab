# Networking — Command Review

## Overview
Core networking commands for Linux infrastructure work. These cover interface
inspection, routing, DNS, connectivity testing, firewall management, and
service verification. This sequence is used daily in real DevOps and SRE roles.

---

## Commands

### `ip a`
```bash
ip a
```
Shows all network interfaces and their IP addresses. Replaces the older
`ifconfig` command.

Key things to read:
- **Interface name** (`eth0`, `enpXsY`) — the physical or virtual network adapter
- `inet` = IPv4 address
- `inet6` = IPv6 address
- `UP` = interface is active
- `DOWN` = interface is inactive

> In DevOps you'll use this constantly to verify a server has the IP you
> expect, especially after provisioning cloud instances.

---

### `ip r`
```bash
ip r
```
Shows the routing table — how the system decides where to send network traffic.
The most important line is the default route:

```
default via 192.168.1.1 dev eth0
```

This means: send all traffic that doesn't match a more specific route to
`192.168.1.1` (your gateway). If this line is missing, the server can't reach
the internet.

---

### `ping`
```bash
ping -c 4 8.8.8.8
ping -c 4 google.com
```
Tests connectivity. Always test IP first, then DNS — this separation tells you
exactly where the problem is.

| Test | Result | Diagnosis |
|---|---|---|
| `ping 8.8.8.8` fails | No response | Network/routing problem |
| `ping 8.8.8.8` works, `ping google.com` fails | DNS broken | DNS problem |
| Both work | Fully connected | No issue |

---

### `dig` / `nslookup`
```bash
dig google.com
nslookup google.com
```
Both query DNS directly. `dig` is more detailed and preferred in production.

Key parts of `dig` output:
- **ANSWER SECTION** — the resolved IP addresses
- **Query time** — how long DNS took
- **SERVER** — which DNS server answered

Use these when you suspect DNS issues — slow resolution, wrong IP returned, or
no resolution at all.

---

### `cat /etc/resolv.conf`
```bash
cat /etc/resolv.conf
```
The DNS configuration file. Lists which DNS servers the system uses. On Ubuntu
24.04 it typically points to `127.0.0.53` — a local stub resolver managed by
`systemd-resolved`. Actual upstream DNS servers are configured separately via
netplan or systemd-resolved config.

---

### `cat /etc/hosts`
```bash
cat /etc/hosts
```
Local DNS override. Entries here are checked before any DNS query. Format is
`IP hostname`. Used heavily in containers and Kubernetes for internal service
discovery. Changes take immediate effect — no restart needed.

---

### `traceroute`
```bash
traceroute google.com
```
Maps every network hop between your server and the destination. Each line is
one router the packet passes through, with round-trip time.

- Used to diagnose where packets are being dropped or where latency spikes
- `* * *` on a line means that router isn't responding to probes — not
  necessarily a problem, many routers block traceroute traffic

---

### `curl -I`
```bash
curl -I https://google.com
```
Fetches HTTP headers only without downloading the body.

| Flag | Meaning |
|---|---|
| `-I` | Headers only |
| `-L` | Follow redirects |
| `-v` | Verbose — shows full request and response |
| `-o /dev/null` | Discard body, useful with `-w` for timing |
| `-w "%{http_code}"` | Print just the status code |

> In production you'll use `curl` to test if services are responding, check
> TLS certificates, verify redirects, and debug API endpoints — all without
> a browser.

---

### `ss`
```bash
ss -tlnp
ss -tunp
```
Shows network sockets. Replaced `netstat` as the modern standard.

| Flag | Meaning |
|---|---|
| `-t` | TCP |
| `-u` | UDP |
| `-l` | Listening only |
| `-n` | Numeric ports (don't resolve to service names) |
| `-p` | Show process using the socket |

> `ss -tlnp` is what you run to verify a service is listening on the expected
> port. If you start nginx and it's not showing on port 80, it didn't start
> correctly.

---

### `ufw`
```bash
sudo ufw status verbose
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw enable
```
Uncomplicated Firewall — the user-friendly interface to iptables on Ubuntu.

Current rule set on olympus:
- Default: deny all incoming
- Explicitly allowed: 22, 80, 443

> Always add rules before enabling ufw — never enable first or you risk
> locking yourself out.

---

### `sshd_config` Hardening
```bash
PasswordAuthentication no
PermitRootLogin no
```
Two non-negotiable settings for any production server:

- `PasswordAuthentication no` — forces key-based auth, eliminates brute force
  password attacks
- `PermitRootLogin no` — prevents direct root login, forces use of a sudo user
  for accountability

After any change to `sshd_config`:
```bash
sudo systemctl restart ssh
```
Always verify with `grep` immediately after — a typo in this file can lock
you out.

---

### `nmap`
```bash
nmap localhost
```
Port scanner. On your own server it confirms exactly what's externally
reachable. Only port 22 showing up confirms ufw is working correctly — 80 and
443 are allowed by the firewall but nothing is listening on them yet.

---

## The Diagnostic Flow

When a server can't reach something or something can't reach it, work through
this in order:

```
1. ip a            — does the interface have an IP?
2. ip r            — is there a default route?
3. ping 8.8.8.8    — can it reach the internet?
4. ping google.com — is DNS working?
5. ss -tlnp        — is the service actually listening?
6. sudo ufw status — is the firewall blocking it?
7. curl -I http://service — is the service responding correctly?
```

This sequence covers the majority of network issues you will encounter in real
infrastructure work.

---

## Skills Demonstrated
- Network interface inspection and interpretation
- Routing table analysis
- DNS resolution and troubleshooting
- Connectivity testing methodology
- Firewall configuration and hardening
- Service socket verification
- SSH hardening best practices
