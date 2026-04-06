# User Management

## Overview
Linux is a multi-user system — every process and file is owned by a user.
Users are created, modified, and removed with `adduser`, `usermod`, and
`deluser`. Groups control shared access. Key user data lives in
`/etc/passwd`, `/etc/shadow`, and `/etc/group`.

---

## Commands Reference

| Command | What It Does |
|---|---|
| `sudo adduser <user>` | Create a new user with home directory and password prompt |
| `cat /etc/passwd` | View all user accounts on the system |
| `sudo usermod -aG <group> <user>` | Add a user to a group without removing existing groups |
| `groups <user>` | List all groups a user belongs to |
| `su - <user>` | Switch to another user with their full login environment |
| `sudo whoami` | Verify sudo access — should return `root` |
| `sudo usermod -L <user>` | Lock a user account (disables password login) |
| `sudo usermod -U <user>` | Unlock a user account |
| `sudo deluser --remove-home <user>` | Delete a user and their home directory |

---

## Commands

### `adduser`
```bash
sudo adduser devuser
```
`adduser` is the friendlier wrapper on Ubuntu — it creates the home
directory, prompts for a password, and sets up the user in one shot.
`useradd` is the lower-level command that requires manual flags to do the
same thing. On Ubuntu, always use `adduser`.

---

### Reading `/etc/passwd`
```bash
cat /etc/passwd | grep devuser
```
Stores user account information. Each line is one user in the format:

```
username:x:UID:GID:comment:home:shell
```

The `x` means the password hash is stored in `/etc/shadow` instead.
Every user on the system has an entry here.

---

### `usermod -aG`
```bash
sudo usermod -aG sudo devuser
```
Modifies an existing user. `-aG` means append to group — the `-a` flag
is critical. Without it, `-G` would **replace** all the user's existing
groups instead of adding to them. This is a common mistake that locks
people out of sudo. Always use `-aG` together, never `-G` alone.

---

### `groups`
```bash
groups devuser
```
Lists all groups a user belongs to. Use this to verify changes after
running `usermod -aG`. If `sudo` doesn't appear in the output, the
change didn't take.

---

### `su`
```bash
su - devuser
```
Switches to another user. The `-` flag loads a full login shell with
that user's environment variables and home directory. Without `-` you
switch users but keep your current environment, which causes subtle
issues with paths and permissions.

---

### `sudo whoami`
```bash
sudo whoami
```
Runs `whoami` as root. If sudo is configured correctly it returns
`root`. Standard way to verify a user has working sudo access without
doing anything destructive.

---

### `usermod -L` / `-U`
```bash
sudo usermod -L devuser   # lock
sudo usermod -U devuser   # unlock
```
`-L` locks the account by prepending a `!` to the password hash in
`/etc/shadow`, making it impossible to log in with a password. `-U`
removes it. This is how you disable a user without deleting them —
standard practice in production when offboarding someone.

---

### `deluser`
```bash
sudo deluser --remove-home devuser
```
Deletes the user. `--remove-home` also deletes their home directory and
mail spool. Without that flag the home directory stays on disk, which
is sometimes intentional for auditing purposes.

---

## Key Files

| File | What It Contains |
|---|---|
| `/etc/passwd` | User accounts — username, UID, GID, home directory, default shell |
| `/etc/shadow` | Password hashes — readable by root only |
| `/etc/group` | Group definitions and memberships |
| `/etc/sudoers` | Who can run sudo — always edit with `visudo` |

---

## Key Definitions

- **UID:** User ID — a unique number identifying a user (root = 0, regular users start at 1000)
- **GID:** Group ID — a unique number identifying a group
- **Home Directory:** The user's personal folder, usually `/home/username`
- **Login Shell:** The shell started when a user logs in (e.g., `/bin/bash`)
- **sudoers:** Controls sudo access — never edit directly, always use `visudo` to prevent syntax errors that could lock you out
- **Account Lock:** Disabling login by corrupting the password hash with `!` — safer than deleting in production

---

## Skills Demonstrated
- Linux user lifecycle management
- Group membership and sudo access control
- Account security hardening
- Production offboarding practices
- Key system file interpretation
