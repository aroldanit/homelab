#!/bin/bash
set -euo pipefail
#!/bin/bash
set -euo pipefail

LOGDIR="/tmp"
DAYS=7

echo "[$(date '+%Y-%m-%d %H:%M:%S')] Running log cleanup"
find "$LOGDIR" -name "*.log" -mtime +$DAYS -delete
echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleanup complete"
~
