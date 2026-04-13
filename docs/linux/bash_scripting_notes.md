# Bash Scripting — Full Reference Notes
**Phase 1 — DevOps Transition Roadmap**

---

## The Shebang Line
```bash
#!/bin/bash
```
The first line of every bash script. Tells the operating system which interpreter to use to run the file. Without it the system may try to run the script with the wrong shell and produce unexpected behavior. Always include it, always make it the first line, never put anything above it.

---

## Making Scripts Executable
```bash
chmod +x script.sh
./script.sh
```
A script file is just a text file until you give it execute permission. `chmod +x` adds the execute bit for the owner. The `./` prefix tells the shell to look in the current directory — without it the shell searches your `$PATH` and won't find your local script.

---

## The Production Header — Always Use This
```bash
#!/bin/bash
set -euo pipefail
```
These three flags go at the top of every script you write in a production or professional context:

| Flag | What It Does | Why It Matters |
|---|---|---|
| `-e` | Exit immediately if any command fails | Prevents scripts from silently continuing after errors |
| `-u` | Treat undefined variables as errors | Catches typos in variable names before they cause damage |
| `-o pipefail` | Catch failures inside pipes | Without this, `failing_command | grep foo` would succeed |

Without these flags bash will happily continue running after errors, use empty strings for undefined variables, and ignore failures inside pipes — all of which can cause serious damage in production scripts.

---

## Variables
```bash
NAME="Alberto"
ROLE="DevOps Engineer"
echo "Name: $NAME"
echo "Current user: $USER"
echo "Home directory: $HOME"
echo "Hostname: $HOSTNAME"
```

**Rules for variables:**
- No spaces around the `=` sign. `NAME = "Alberto"` will fail.
- Reference variables with `$VARIABLE` or `${VARIABLE}`
- Use `${VARIABLE}` when the variable name is adjacent to other text: `${NAME}script`
- Use uppercase for your own variables by convention
- Built-in environment variables are also uppercase: `$USER`, `$HOME`, `$PATH`, `$HOSTNAME`

**Command substitution:**
```bash
DATE=$(date)
FILES=$(ls ~/scripts)
echo "Date is: $DATE"
```
`$()` runs a command and captures its output as a string. This is how you use command output as a variable value.

**Local variables inside functions:**
```bash
my_function() {
    local NAME="Alberto"
    echo $NAME
}
```
Always use `local` inside functions. Without it the variable leaks into the global script scope and can cause subtle bugs.

---

## Conditionals
```bash
if [ condition ]; then
    # do something
elif [ other_condition ]; then
    # do something else
else
    # fallback
fi
```

**Common test operators:**

File tests:
| Operator | Meaning |
|---|---|
| `-f "$FILE"` | Is a regular file |
| `-d "$FILE"` | Is a directory |
| `-e "$FILE"` | Exists (file or directory) |
| `-r "$FILE"` | Is readable |
| `-w "$FILE"` | Is writable |
| `-x "$FILE"` | Is executable |

String tests:
| Operator | Meaning |
|---|---|
| `-z "$STR"` | String is empty |
| `-n "$STR"` | String is not empty |
| `"$A" = "$B"` | Strings are equal |
| `"$A" != "$B"` | Strings are not equal |

Number comparisons:
| Operator | Meaning |
|---|---|
| `$A -eq $B` | Equal |
| `$A -ne $B` | Not equal |
| `$A -gt $B` | Greater than |
| `$A -lt $B` | Less than |
| `$A -ge $B` | Greater than or equal |
| `$A -le $B` | Less than or equal |

**Always quote your variables inside conditionals.** `[ -z $FILE ]` breaks if `$FILE` contains spaces. `[ -z "$FILE" ]` is always safe.

---

## Arguments
```bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
```

| Variable | Meaning |
|---|---|
| `$0` | The script name itself |
| `$1`, `$2`... | Positional arguments |
| `$@` | All arguments as separate items |
| `$*` | All arguments as one string |
| `$#` | Count of arguments passed |
| `$?` | Exit code of the last command |

**Validating arguments — always do this:**
```bash
if [ -z "$1" ]; then
    echo "Error: No argument provided"
    echo "Usage: $0 <filename>"
    exit 1
fi
```
Never assume the user passed the right arguments. Check first, exit with a clear message if not.

---

## Loops

**For loop over a list:**
```bash
for COLOR in red green blue; do
    echo "Color: $COLOR"
done
```

**For loop over files:**
```bash
for FILE in ./*.sh; do
    echo "Found: $FILE"
done
```

**For loop over a range:**
```bash
for i in {1..10}; do
    echo "Number: $i"
done
```

**While loop with counter:**
```bash
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    COUNT=$((COUNT + 1))
done
```

**While loop reading a file line by line:**
```bash
while IFS= read -r LINE; do
    echo "$LINE"
done < /etc/hosts
```
This pattern is how you process log files, config files, and command output line by line. `IFS=` prevents stripping leading whitespace. `-r` prevents backslash interpretation.

---

## Functions
```bash
greet_user() {
    local USERNAME=$1
    echo "Hello, $USERNAME"
}

greet_user "Alberto"
```

**Function rules:**
- Define before calling — bash reads top to bottom
- Always use `local` for variables inside functions
- Functions can return exit codes with `return N` (0 = success, 1–255 = error)
- Functions cannot return strings — use `echo` and capture with `$()`

**Returning a value from a function:**
```bash
get_disk_usage() {
    df / | awk 'NR==2 {print $5}' | tr -d '%'
}

USAGE=$(get_disk_usage)
echo "Disk usage: ${USAGE}%"
```

---

## Error Handling
```bash
#!/bin/bash
set -euo pipefail

if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "ERROR: No network connectivity"
    exit 1
fi
```

**Exit codes:**
- `0` = success
- Any non-zero = failure
- `exit 1` = exit script with failure code
- `$?` = exit code of the last command run

**The `!` operator:**
```bash
if ! command; then
    echo "command failed"
fi
```
`!` inverts the exit code — so `if ! ping` means "if ping fails".

**Redirecting output:**
```bash
command &>/dev/null     # suppress all output (stdout + stderr)
command 2>/dev/null     # suppress errors only
command >> logfile.log  # append stdout to a log file
command 2>&1            # redirect stderr to stdout
```

**Trap — cleanup on exit:**
```bash
cleanup() {
    echo "Cleaning up temp files..."
    rm -f /tmp/myscript_*
}
trap cleanup EXIT
```
`trap` runs a function when the script exits — even if it crashes. Use it to clean up temp files, release locks, or log that the script ended.

---

## The Scripts We Wrote — Detailed Breakdown

---

### hello.sh
```bash
#!/bin/bash
echo "Hello from olympus"
echo "Current user: $USER"
echo "Current date: $(date)"
```
**Purpose:** Introduces the shebang, echo, environment variables, and command substitution. `$USER` is a built-in environment variable. `$(date)` runs the date command and inserts its output inline.

---

### variables.sh
```bash
#!/bin/bash
NAME="Alberto"
ROLE="DevOps Engineer"
echo "Name: $NAME"
echo "Role: $ROLE"
echo "Home directory: $HOME"
echo "Hostname: $HOSTNAME"
```
**Purpose:** Demonstrates user-defined variables vs built-in environment variables. Shows that variables are just named storage for strings and that environment variables like `$HOME` and `$HOSTNAME` are always available without defining them.

---

### check_file.sh
```bash
#!/bin/bash
FILE="$1"

if [ -z "$FILE" ]; then
    echo "Error: No filename provided"
    echo "Usage: ./check_file.sh <filename>"
    exit 1
fi

if [ -f "$FILE" ]; then
    echo "File exists: $FILE"
elif [ -d "$FILE" ]; then
    echo "That is a directory, not a file: $FILE"
else
    echo "File does not exist: $FILE"
fi
```
**Purpose:** Introduces conditionals, argument handling, and input validation. The first block validates that an argument was passed before doing anything else — this is the pattern every real script should follow. The `-f` and `-d` tests show how to check filesystem objects. `exit 1` signals failure to the calling shell.

---

### loops.sh
```bash
#!/bin/bash

for COLOR in red green blue; do
    echo "Color: $COLOR"
done

echo "---"
for FILE in ./*.sh; do
    echo "Script found: $FILE"
done

echo "---"
COUNT=1
while [ $COUNT -le 5 ]; do
    echo "Count: $COUNT"
    COUNT=$((COUNT + 1))
done
```
**Purpose:** Shows three loop patterns in one script. The glob pattern `./*.sh` is how you iterate over files matching a pattern — used constantly in scripts that process batches of files. `$(())` is arithmetic expansion — the correct way to do math in bash.

---

### functions.sh
```bash
#!/bin/bash

greet_user() {
    local USERNAME=$1
    echo "Hello, $USERNAME. Welcome to olympus."
}

check_disk() {
    local THRESHOLD=$1
    local USAGE=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
    if [ "$USAGE" -gt "$THRESHOLD" ]; then
        echo "WARNING: Disk usage is at ${USAGE}%"
    else
        echo "OK: Disk usage is at ${USAGE}%"
    fi
}

greet_user "Alberto"
check_disk 80
```
**Purpose:** Introduces functions with arguments, local variables, and a real-world use case. `check_disk` is the foundation of the Phase 1 deliverable monitoring script. The pipeline `df / | awk 'NR==2 {print $5}' | tr -d '%'` is a preview of text processing — `df` gets disk info, `awk` extracts the fifth column of the second row, `tr -d '%'` strips the percent sign so you can do numeric comparison.

---

### error_handling.sh
```bash
#!/bin/bash
set -euo pipefail

echo "Step 1: Starting script"

if ! ping -c 1 8.8.8.8 &>/dev/null; then
    echo "ERROR: No network connectivity"
    exit 1
fi

echo "Step 2: Network is up"
echo "Step 3: Script completed successfully"
```
**Purpose:** Introduces `set -euo pipefail`, output suppression with `&>/dev/null`, and the `!` operator for checking command failure. This is the closest script to production-quality code in the set. The pattern of checking prerequisites before doing work (network up, files exist, services running) is something you will use in every real automation script.

---

### arguments.sh
```bash
#!/bin/bash
echo "Script name: $0"
echo "First argument: $1"
echo "Second argument: $2"
echo "All arguments: $@"
echo "Number of arguments: $#"
```
**Purpose:** Maps out all the special argument variables in one place. Simple but important reference — knowing `$@` vs `$#` vs `$0` is foundational for writing scripts that accept input.

---

## How to Write Bash Scripts — The Right Way

**Structure every script like this:**
```bash
#!/bin/bash
set -euo pipefail

# ── Constants ────────────────────────────────
LOGFILE="/var/log/myscript.log"
THRESHOLD=80

# ── Functions ────────────────────────────────
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOGFILE"
}

check_requirements() {
    if ! command -v curl &>/dev/null; then
        log "ERROR: curl is not installed"
        exit 1
    fi
}

# ── Main ─────────────────────────────────────
main() {
    log "Script started"
    check_requirements
    log "Script completed"
}

main "$@"
```

**The principles behind this structure:**

1. **Shebang + set flags first** — always, no exceptions
2. **Constants at the top** — never hardcode values inside functions
3. **Functions before main logic** — bash reads top to bottom, functions must be defined before they are called
4. **A logging function** — timestamped output that goes to both terminal and a log file
5. **A requirements check** — verify tools your script depends on exist before doing any work
6. **A main() function** — keeps the top-level logic clean and readable
7. **Call main at the bottom** — `main "$@"` passes all script arguments into main

**Additional rules for production scripts:**
- Always quote variables: `"$VAR"` not `$VAR`
- Always validate arguments before using them
- Use `local` for all function variables
- Write one function per task — keep functions small and focused
- Add comments for anything non-obvious — not for everything
- Test with bad input, missing files, and no arguments — not just the happy path
- Run every script through ShellCheck (shellcheck.net) before committing
