# File Permissions

## Overview
Every file and directory on Linux has an owner (user), a group, and a set
of permissions. Permissions are split into three layers: owner, group, and
world (everyone else). Each layer has three bits: read (r=4), write (w=2),
execute (x=1). Wrong ownership or wrong octal value accounts for nearly
every permission problem you'll hit in DevOps.

---

## Commands Reference

| Command | What It Does |
|---|---|
| `ls -la <path>` | List files in long format including hidden files |
| `touch <file>` | Create an empty file or update timestamp of existing one |
| `chmod <octal> <file>` | Set file permissions using octal value |
| `chown <user> <file>` | Change the owner of a file |
| `chown <user>:<group> <file>` | Change both owner and group in one command |
| `chgrp <group> <file>` | Change the group of a file |
| `mkdir <dir>` | Create a directory |
| `mkdir -p <path>` | Create directory and all missing parent directories |
| `rm <file>` | Delete a file (no confirmation, no trash) |
| `rmdir <dir>` | Delete an empty directory |
| `rm -rf <dir>` | ⚠️ Recursively delete a directory and all contents — no confirmation |

---

## Commands

### `ls -la`
```bash
ls -la ~/
```
`-l` gives long format showing permissions, ownership, size, and date.
`-a` shows hidden files (those starting with `.`).

Permission string breakdown:
- Character 1: file type (`-` = file, `d` = directory, `l` = symlink)
- Characters 2–4: owner permissions (rwx)
- Characters 5–7: group permissions (rwx)
- Characters 8–10: world permissions (rwx)

`r` = read (4), `w` = write (2), `x` = execute (1). The octal number
is the sum of those values per triplet.

---

### `touch`
```bash
touch ~/permtest.txt
```
Creates an empty file if it doesn't exist. If the file already exists,
it updates the timestamp. Used constantly for creating test files and
placeholder files in scripts.

---

### `chmod`
```bash
chmod 000 ~/permtest.txt   # no permissions for anyone
chmod 400 ~/permtest.txt   # owner read only
chmod 644 ~/permtest.txt   # standard file
chmod 755 ~/permdir        # standard directory
```
Changes file permissions. The three digits map to owner / group / world.
Each digit is the sum of r(4) + w(2) + x(1):

| Octal | Binary | Meaning |
|---|---|---|
| 0 | 000 | No permissions |
| 4 | 100 | Read only |
| 5 | 101 | Read + execute |
| 6 | 110 | Read + write |
| 7 | 111 | Read + write + execute |

`644` = owner gets rw, group gets r, world gets r.
`755` = owner gets rwx, group gets rx, world gets rx.

---

### `chown`
```bash
sudo chown root ~/permtest.txt          # change owner to root
sudo chown $USER ~/permtest.txt         # change back to current user
sudo chown root:root ~/permtest.txt     # change both owner and group
```
Changes file ownership. `$USER` is an environment variable holding your
current username — cleaner than typing it manually. You need `sudo` to
give ownership to another user.

---

### `chgrp`
```bash
sudo chgrp root ~/permtest.txt     # change group to root
sudo chgrp $USER ~/permtest.txt    # change back
```
Changes group ownership only. In practice `chown owner:group` does the
same thing in one command — but worth knowing `chgrp` exists.

---

### `mkdir`
```bash
mkdir ~/permdir
mkdir -p ~/projects/phase1/scripts
```
Creates a directory. The `-p` flag creates the full path without
erroring out if part of it already exists — use this constantly in
scripts.

---

### `rm` / `rmdir`
```bash
rm ~/permtest.txt       # delete a file
rmdir ~/permdir         # delete an empty directory
rm -rf ~/permdir        # delete a directory and everything inside it
```
`rmdir` only works on empty directories. `rm -rf` removes everything
recursively with no confirmation — treat it with respect. There is no
undo.

---

## The Mental Model

Every file on Linux has three questions:

1. **Who owns it?** (user)
2. **What group owns it?** (group)
3. **What can each party do?** (rwx per owner / group / world)

Linux checks those three layers in order — owner first, then group,
then world — and applies the first match. Permission issues in DevOps
almost always come down to one of two things: wrong ownership or wrong
octal value.

---

## Key Definitions

- **Permission String:** The 10-character output of `ls -l` (e.g., `-rwxr-xr--`) showing file type and rwx for owner, group, and world
- **Octal Notation:** A three-digit number representing permissions — each digit is the sum of r(4) + w(2) + x(1) for owner, group, and world
- **Owner:** The user who owns a file — Linux checks their permissions first
- **Group:** A set of users that share access to a file — checked after owner
- **World:** Everyone else on the system — checked last
- **chmod:** Change mode — sets the permission bits on a file or directory
- **chown:** Change owner — transfers file ownership to another user
- **chgrp:** Change group — changes the group assigned to a file
- **$USER:** A shell environment variable containing the current user's username
- **`rm -rf`:** Recursive force delete — removes everything inside a path with no prompt and no undo

---

## Skills Demonstrated
- Linux permission model interpretation
- Octal notation and permission calculation
- File and directory ownership management
- Safe and unsafe deletion practices
- Environment variable usage in administration tasks
