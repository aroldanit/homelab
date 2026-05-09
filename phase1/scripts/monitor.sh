#!/bin/bash

#----Configuration---------------------------
LOGFILE="/var/log/monitor.log"
DISK_THRESHOLD=80
CPU_THRESHOLD=80
SERVICES=("ssh" "cron" "ufw")

#----Logging function-----------------------
log() { 
	echo "[$date '+%Y-%m-%d %H:%M:%S')] $1" | sudo tee -a "$LOGFILE"
}

#----CPU check------------------------------
check_cpu() {
    local CPU_IDLE
    CPU_IDLE=$(top -bn1 | grep "Cpu(s)" | awk '{print $8}' | tr -d '%')
    local CPU_USED
    CPU_USED=$(echo "100 - $CPU_IDLE" | bc)
    if (( $(echo "$CPU_USED > $CPU_THRESHOLD" | bc -l) )); then
        log "WARNING: CPU usage is at ${CPU_USED}%"
    else
        log "OK: CPU usage is at ${CPU_USED}%"
    fi
}

#---Memory check-----------------------
check_memory() {
	local MEM_TOTAL
	MEM_TOTAL=$(free -m | awk 'NR==2 {print $2}')
	local MEM_USED
	MEM_USED=$(free -m | awk 'NR==2 {print $3}')
	local MEM_PCT
	MEM_PCT=$(echo "scale=1; $MEM_USED * 100 / $MEM_TOTAL" | bc)
	log "OK: Memory usage is ${MEM_PCT}% (${MEM_USED}MB / ${MEM_TOTAL}MB)"
}

#----Disk check-------------------------
check_disk() {
	local DISK_USED
	DISK_USED=$(df / | awk 'NR==2 {print $5}' | tr -d '%')
	if [ "$DISK_USED" -gt "$DISK_THRESHOLD" ]; then
		log "WARNING: Disk usage is at at ${DISK_USED}%"
	else
		log "OK: Disk usage is at ${DISK_USED}%"
	fi
}

#----Service check---------------------
check_services() {
	for SERVICE in "${SERVICES[@]}"; do
		if systemctl is-active --quiet "$SERVICE"; then
			log "OK: Service $SERVICE in running"
		else
			log "WARNING: Service $SERVICE is NOT running"
		fi
	done
}

#----Main----------------------------
main() {
	log "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
	log "System monitor started on $(hostname)"
	check_cpu
	check_memory
	check_disk
	check_services
	log "Monitor complete"
	}
main "$@"

