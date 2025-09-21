#!/usr/bin/env bash

LOGFILE="$1"

if [ -z "$LOGFILE" ] || [ ! -f "$LOGFILE" ]; then
  echo "Usage: $0 /path/to/access.log"
  exit 1
fi


OUTFILE="/tmp/log_analysis_$(date +"%Y%m%d_%H%M%S").log"
{
echo "===== Log Analysis Report ====="
echo "Log file: $LOGFILE"
echo

# Number of 404 errors
echo "Number of 404 errors:"
grep ' 404 ' "$LOGFILE" | wc -l
echo

# Most requested pages (top 10)
echo "Top 10 requested pages:"
awk '{print $7}' "$LOGFILE" | sort | uniq -c | sort -nr | head -10
echo

# IP addresses with the most requests (top 10)
echo "Top 10 IP addresses:"
awk '{print $1}' "$LOGFILE" | sort | uniq -c | sort -nr | head -10
echo "================================"
} | tee "$OUTFILE"