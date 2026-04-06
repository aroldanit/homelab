# Processes & Services

## Overview
Every running program on Linux is a process with a unique PID assigned by
the kernel. `systemd` is PID 1 — the init system that manages all services
on modern Ubuntu. `systemctl` controls services; `journalctl` reads their
logs. These two are your primary production tools.

---

## Commands Reference

| Command | What It Does |
|---|---|
| `ps aux` | Snapshot all running processes from all users |
| `ps aux \| grep <name>` | Filter process list to find a specific process |
| `top` | Live process monitor — refreshes every 3 seconds |
| `htop` | Friendlier live monitor with per-core CPU bars (requires install) |
| `pgrep <name>` | Return only the PID of matching processes |
| `sleep 300 &` | Run a command in the background |
| `jobs` | List background jobs in the current shell session |
| `fg <n>` | Bring background job number n to the foreground |
| `kill <PID>` | Send SIGTERM (graceful shutdown) to a process |
| `kill -9 <PID>` | Send SIGKILL (force kill) to a process |
| `sudo systemctl status <service>` | Show whether a service is running and its recent logs |
| `sudo systemctl start <service>` | Start a service now |
| `sudo systemctl stop <service>` | Stop a service now |
| `sudo systemctl restart <service>` | Stop then start a service |
| `sudo systemctl enable <service>` | Make a service start automatically on boot |
| `sudo systemctl disable <service>` | Remove a service from boot startup |
| `sudo systemctl daemon-reload` | Reload systemd after editing a unit file |
| `sudo journalctl -u <service>` | View logs for a specific service |
| `sudo journalctl -u <service> -n 50` | View the last 50 lines of a service's logs |
| `sudo journalctl -u <service> -f` | Follow a service's log output live |
| `ss -tlnp` | Show all listening TCP ports and which process owns them |

---

## Commands

### `ps aux`
```bash
ps aux
```
Snapshots every running process at that moment. The three flags together
are the standard combination:

- `a` = show processes from all users, not just yours
- `u` = user-oriented output (shows username, CPU%, MEM%)
- `x` = include processes with no controlling terminal (daemons, services)

Key columns to read:

| Column | Meaning |
|---|---|
| PID | Process ID — unique number assigned by the kernel |
| %CPU | CPU usage at snapshot time |
| %MEM | RAM usage as percentage of total |
| STAT | Process state (S=sleeping, R=running, Z=zombie) |
| COMMAND | The actual command that launched the process |

---

### `grep` with `ps`
```bash
ps aux | grep ssh
```
The pipe `|` takes the output of `ps aux` and feeds it as input to
`grep`. This pattern — `command | grep pattern` — is one of the most
used patterns in Linux administration. Use it constantly to find
specific processes, filter log output, and search command results.

---

### `top`
```bash
top
```
Live view that refreshes every 3 seconds. Load average is the key
number — it represents average CPU demand over 1, 5, and 15 minutes.
On an 8-core machine, a load average under 8.0 means the system is
not overloaded.

---

### `htop`
```bash
htop
```
A friendlier version of `top` with color-coded CPU and memory bars per
core. Not installed by default:

```bash
sudo apt install htop
```

In real environments htop may not be present — always be comfortable
with plain `top` as a fallback.

---

### `pgrep`
```bash
pgrep sshd
```
Returns just the PID of matching processes. Cleaner than parsing
`ps aux | grep` when you only need the PID. Useful in scripts:

```bash
if pgrep nginx > /dev/null; then
    echo "nginx is running"
fi
```

---

### Background Jobs: `&`, `jobs`, `fg`
```bash
sleep 300 &    # run in background
jobs           # list background jobs
fg 1           # bring job 1 to foreground
```
The `&` operator detaches a process from your terminal so it keeps
running while you do other things. `jobs` is session-scoped — it only
shows jobs started in your current shell session. This is the
foundation for understanding how daemons and background services work.

---

### `kill`
```bash
kill %1         # kill by job number
kill <PID>      # send SIGTERM (graceful)
kill -9 <PID>   # send SIGKILL (force)
```
`kill` sends a signal to a process. By default it sends `SIGTERM`
(signal 15) — a polite request to shut down gracefully. `kill -9`
sends `SIGKILL` — the kernel terminates it immediately with no cleanup.
Always try a regular kill first. Use `-9` only when the process is
unresponsive.

---

### `systemctl`
```bash
sudo systemctl status ssh
sudo systemctl start ssh
sudo systemctl stop ssh
sudo systemctl restart ssh
sudo systemctl enable ssh
sudo systemctl disable ssh
sudo systemctl daemon-reload    # required after editing any unit file
```
systemd is PID 1 — the first process the kernel starts and the parent
of everything else. The distinction between start/stop and
enable/disable is critical:

| Command | What It Does |
|---|---|
| `start` | Runs the service right now |
| `stop` | Stops the service right now |
| `enable` | Makes it start automatically on boot |
| `disable` | Removes it from boot startup |
| `restart` | Stop then start |
| `reload` | Reload config without full restart (if service supports it) |

> A service can be started but not enabled (runs now, gone after
> reboot) or enabled but not started (starts next boot, not running
> now). In production you almost always want both.

---

### `journalctl`
```bash
sudo journalctl -u ssh
sudo journalctl -u ssh -n 50
sudo journalctl -u ssh -f
```
The log viewer for systemd. Every service managed by systemd writes
to the journal.

| Flag | Meaning |
|---|---|
| `-u` | Filter by service unit name |
| `-n 50` | Show last N lines |
| `-f` | Follow live output |
| `-b` | Show logs from current boot only |
| `--since "1 hour ago"` | Time-based filtering |

> Always check `journalctl -u servicename -n 100` first when something
> isn't working. This is your primary debugging tool.

---

### `ss`
```bash
ss -tlnp
```
Shows network sockets and listening ports. Replaced `netstat` as the
modern standard.

| Flag | Meaning |
|---|---|
| `-t` | TCP only |
| `-l` | Listening sockets only |
| `-n` | Show port numbers, not service names |
| `-p` | Show which process owns the socket |

---

### systemd Unit File
```ini
[Unit]
Description=Hello World Service
After=network.target

[Service]
ExecStart=/bin/bash -c 'while true; do echo "hello" >> /tmp/hello.log; sleep 10; done'
Restart=always

[Install]
WantedBy=multi-user.target
```

Every unit file has three sections:

| Section | Purpose |
|---|---|
| `[Unit]` | Metadata and dependencies |
| `[Service]` | How to run it — command, restart behavior, user |
| `[Install]` | When to start it — `multi-user.target` = normal boot |

`Restart=always` means systemd restarts the service if it crashes —
the production standard for any service you want to stay up. After
editing any unit file always run `sudo systemctl daemon-reload`.

---

## The Diagnostic Flow

When a service isn't working, run this in order:

```
1. systemctl status servicename     — is it running? did it crash?
2. journalctl -u servicename -n 100 — what did it log before dying?
3. ps aux | grep servicename        — is the process actually there?
4. ss -tlnp                         — is it listening on the right port?
```

That four-step sequence will diagnose 80% of service issues you'll
encounter.

---

## Key Definitions

- **Process:** A running instance of a program — every process has a unique PID
- **PID:** Process ID — a number assigned by the kernel to identify a running process
- **Daemon:** A background process with no controlling terminal (e.g., sshd, nginx)
- **SIGTERM:** Signal 15 — a polite request to shut down; the process can catch it and clean up
- **SIGKILL:** Signal 9 — immediate forced termination by the kernel; cannot be caught or ignored
- **systemd:** The init system on modern Linux — PID 1, manages all services and dependencies
- **Unit File:** A configuration file that tells systemd how to run and manage a service (stored in `/etc/systemd/system/`)
- **Load Average:** Average number of processes competing for CPU time over 1, 5, and 15 minutes — should stay below the number of CPU cores
- **Zombie Process:** A process that has finished but whose entry hasn't been cleaned up by its parent — shows as `Z` in STAT column
- **Socket:** A communication endpoint — `ss -tlnp` shows which services are listening and on what port

---

## Skills Demonstrated
- Process inspection and management
- Signal-based process termination
- systemd service lifecycle management
- Log analysis with journalctl
- Unit file creation and configuration
- Production service debugging methodology
