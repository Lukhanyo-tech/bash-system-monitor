#!/bin/bash

# Log file location
LOG_FILE=~/system_monitor/system_monitor.log

# Function to check CPU usage
check_cpu_usage() {
    echo "Checking CPU usage..." >> "$LOG_FILE"
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    echo "CPU Usage: $CPU_USAGE%" >> "$LOG_FILE"
    
    # Send alert if usage is above threshold (e.g., 80%)
    if (( $(echo "$CPU_USAGE > 80" | bc -l) )); then
        echo "High CPU usage detected: $CPU_USAGE%" >> "$LOG_FILE"
        echo "CPU Alert: $CPU_USAGE%" | mail -s "CPU Alert" nik24ster@gmail.com
    fi
}

# Function to check memory usage
check_memory_usage() {
    echo "Checking memory usage..." >> "$LOG_FILE"
    MEMORY_USAGE=$(free | grep Mem | awk '{print $3/$2 * 100.0}')
    echo "Memory Usage: $MEMORY_USAGE%" >> "$LOG_FILE"
    
    # Send alert if usage is above threshold (e.g., 80%)
    if (( $(echo "$MEMORY_USAGE > 80" | bc -l) )); then
        echo "High Memory usage detected: $MEMORY_USAGE%" >> "$LOG_FILE"
        echo "Memory Alert: $MEMORY_USAGE%" | mail -s "Memory Alert" nik24ster@gmail.com
    fi
}

# Function to check disk space usage
check_disk_usage() {
    echo "Checking disk space usage..." >> "$LOG_FILE"
    DISK_USAGE=$(df / | grep / | awk '{ print $5 }' | sed 's/%//g')
    echo "Disk Usage: $DISK_USAGE%" >> "$LOG_FILE"
    
    # Send alert if usage is above threshold (e.g., 80%)
    if [ "$DISK_USAGE" -gt 80 ]; then
        echo "High Disk usage detected: $DISK_USAGE%" >> "$LOG_FILE"
        echo "Disk Alert: $DISK_USAGE%" | mail -s "Disk Alert" nik24ster@gmail.com
    fi
}

# Function to check network connectivity
check_network() {
    echo "Checking network connectivity..." >> "$LOG_FILE"
    if ping -c 1 8.8.8.8 &> /dev/null; then
        echo "Network is up." >> "$LOG_FILE"
    else
        echo "Network is down!" >> "$LOG_FILE"
        echo "Network Alert: Network is down!" | mail -s "Network Alert" nik24ster@gmail.com
    fi
}

# Main monitoring loop
echo "Script started at $(date)" >> "$LOG_FILE"
while true; do
    echo "Starting monitoring cycle..." >> "$LOG_FILE"
    check_cpu_usage
    check_memory_usage
    check_disk_usage
    check_network
    sleep 300  # Check every 5 minutes
done

