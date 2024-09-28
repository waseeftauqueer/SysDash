#!/bin/bash

# ANSI color codes
GREEN='\033[0;32m'
RESET='\033[0m'
BOLD='\033[1m'
RED='\033[31m'
YELLOW='\033[33m'

# Title and Author Information
AUTHOR="waseeftauqueer"
YEAR="$(date +'%Y')"

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install ifstat
install_ifstat() {
    if command_exists apt; then
        sudo apt-get install -y ifstat
    elif command_exists yum; then
        sudo yum install -y ifstat
    elif command_exists dnf; then
        sudo dnf install -y ifstat
    elif command_exists brew; then
        brew install ifstat
    else
        echo -e "${RED}Package manager not found. Please install ifstat manually.${RESET}"
        exit 1
    fi
}

# Check for required commands and install ifstat if it's missing
if ! command_exists ifstat; then
    echo -e "${YELLOW}ifstat not found. Installing...${RESET}"
    install_ifstat
fi

# Title and dashboard functions
display_title() {
    echo -e "${GREEN}${BOLD}============================${RESET}"
    echo -e "${GREEN}${BOLD}        S Y S D A S H      ${RESET}"
    echo -e "${GREEN}${BOLD}============================${RESET}"
}

print_title() {
    local title="$1"
    local length=${#title}
    local padding=$(( (26 - length) / 2 ))
    local spaces=$(printf "%-${padding}s" " ")
    echo -e "${GREEN}${BOLD}============================${RESET}"
    echo -e "${GREEN}${BOLD}${spaces}${title}${RESET}"
    echo -e "${GREEN}${BOLD}============================${RESET}"
}

get_system_load() {
    print_title "System Load"
    echo -e "Load Average: $(uptime | awk -F 'load average:' '{ print $2 }')"
}

get_memory_usage() {
    print_title "Memory Usage"
    free -h | awk '/^Mem/ {print "Used: "$3 " / Total: "$2}'
}

get_disk_usage() {
    print_title "Disk Usage"
    df -h | grep '^/dev/' | awk '{print $1 ": " $3 " used of " $2 " (" $5 " full)"}'
}

get_network_monitoring() {
    print_title "Network Monitoring"
    ifstat -t 1 1 | awk 'NR==3 {print "RX: "$1" KB/s | TX: "$2" KB/s"}'
}

monitor_top_applications() {
    print_title "Top Applications by CPU"
    ps -eo pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -6
}

process_monitoring() {
    print_title "Process Monitoring"
    ps -eo user,pid,ppid,cmd,%mem,%cpu --sort=-%cpu | head -10
}

service_monitoring() {
    print_title "Active Services"
    systemctl list-units --type=service --state=active | head -10
}

custom_dashboard() {
    echo -e "${GREEN}${BOLD}SysDash${RESET}"
    echo -e "${GREEN}${BOLD}System Date and Time: $(date)${RESET}"
    echo -e "${GREEN}${BOLD}Hostname: $(hostname)${RESET}"
}

display_dashboard() {
    clear
    display_title
    get_system_load
    echo
    get_memory_usage
    echo
    get_disk_usage
    echo
    get_network_monitoring
    echo
    monitor_top_applications
    echo
    process_monitoring
    echo
    service_monitoring
    echo
    custom_dashboard
    echo -e "\n${YELLOW}Thanks for using SysDash!${RESET}"
    echo -e "${YELLOW}GitHub: https://github.com/${AUTHOR}${RESET}"
    echo -e "${RED}© ${YEAR} ${AUTHOR}. All rights reserved.${RESET}"
}

while true; do
    display_dashboard
    sleep 5
done
