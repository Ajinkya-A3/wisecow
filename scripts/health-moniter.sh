#!/usr/bin/env bash
# scripts/health-monitor.sh
# Requires: awk, grep, df, free, ps

LOGFILE="/tmp/sys_health_$(date +"%Y%m%d_%H%M%S").log"
CPU_THRESHOLD=80
MEM_THRESHOLD=80
DISK_THRESHOLD=85

timestamp() { date +"%Y-%m-%d %H:%M:%S"; }

echo "$(timestamp) - Starting system health check" >> "$LOGFILE"

# CPU (1-minute load average normalized to cpu cores)
CORES=$(nproc || echo 1)
LOAD1=$(cut -d ' ' -f1 /proc/loadavg)
# Convert load to percent: (load/cores)*100
CPU_PERCENT=$(awk -v l="$LOAD1" -v c="$CORES" 'BEGIN{printf("%.0f", (l/c)*100)}')

if [ "$CPU_PERCENT" -ge "$CPU_THRESHOLD" ]; then
  echo "$(timestamp) - ALERT: High CPU usage: ${CPU_PERCENT}% (threshold ${CPU_THRESHOLD}%)" | tee -a "$LOGFILE"
else
  echo "$(timestamp) - OK: CPU usage ${CPU_PERCENT}%" >> "$LOGFILE"
fi

# Memory
MEM_FREE=$(free -m | awk '/Mem:/ {print $4+$7}') # free + available fallback
MEM_TOTAL=$(free -m | awk '/Mem:/ {print $2}')
MEM_PERCENT=$(( ( (MEM_TOTAL - MEM_FREE) * 100 ) / MEM_TOTAL ))

if [ "$MEM_PERCENT" -ge "$MEM_THRESHOLD" ]; then
  echo "$(timestamp) - ALERT: High memory usage: ${MEM_PERCENT}% (threshold ${MEM_THRESHOLD}%)" | tee -a "$LOGFILE"
else
  echo "$(timestamp) - OK: Memory usage ${MEM_PERCENT}%" >> "$LOGFILE"
fi

# Disk root
DISK_PERCENT=$(df -h / | awk 'NR==2{gsub(/%/,"",$5); print $5}')

if [ "$DISK_PERCENT" -ge "$DISK_THRESHOLD" ]; then
  echo "$(timestamp) - ALERT: Low disk space on / : ${DISK_PERCENT}% used (threshold ${DISK_THRESHOLD}%)" | tee -a "$LOGFILE"
else
  echo "$(timestamp) - OK: Disk usage ${DISK_PERCENT}%" >> "$LOGFILE"
fi

# Running processes count (optional threshold)
PROC_COUNT=$(ps -eo pid= | wc -l)
echo "$(timestamp) - Info: Running processes: ${PROC_COUNT}" >> "$LOGFILE"

echo "$(timestamp) - Completed system health check" >> "$LOGFILE"
