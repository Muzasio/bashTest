#!/bin/bash

# Script: system-info.sh
# Description: System information and file operations script

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display error messages
error_exit() {
    echo -e "${RED}[ERROR] $1${NC}" >&2
    exit 1
}

# Function to display success messages
success_msg() {
    echo -e "${GREEN}[SUCCESS] $1${NC}"
}

# Function to display warning messages
warning_msg() {
    echo -e "${YELLOW}[WARNING] $1${NC}"
}

# Check if script is run as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        warning_msg "This script is running as root"
    fi
}

# Get system information
system_info() {
    echo -e "\n${GREEN}=== System Information ===${NC}"
    echo "Hostname: $(hostname)"
    echo "Kernel: $(uname -r)"
    echo "Distribution: $(lsb_release -d 2>/dev/null | cut -f2 || cat /etc/*release 2>/dev/null | head -n1)"
    echo "Uptime: $(uptime -p)"
}

# Check disk usage
check_disk() {
    echo -e "\n${YELLOW}=== Disk Usage ===${NC}"
    df -h / | awk 'NR==2 {printf "Usage: %s (%s/%s)\n", $5, $3, $2}'
}

# Create backup directory
create_backup() {
    local backup_dir="/tmp/backup_$(date +%Y%m%d_%H%M%S)"
    echo -e "\nCreating backup directory: $backup_dir"
    
    if mkdir -p "$backup_dir"; then
        success_msg "Backup directory created successfully"
        echo "Backup location: $backup_dir"
    else
        error_exit "Failed to create backup directory"
    fi
}

# Main function with menu
main() {
    clear
    echo "System Information Script"
    echo "========================="
    
    check_root
    
    while true; do
        echo -e "\nOptions:"
        echo "1) Show system information"
        echo "2) Check disk usage"
        echo "3) Create backup directory"
        echo "4) Check network connectivity"
        echo "5) Exit"
        
        read -p "Select option [1-5]: " choice
        
        case $choice in
            1)
                system_info
                ;;
            2)
                check_disk
                ;;
            3)
                create_backup
                ;;
            4)
                echo -e "\nTesting network connectivity..."
                if ping -c 2 8.8.8.8 &> /dev/null; then
                    success_msg "Network is up"
                else
                    error_exit "Network is down"
                fi
                ;;
            5)
                success_msg "Goodbye!"
                exit 0
                ;;
            *)
                warning_msg "Invalid option. Please try again."
                ;;
        esac
    done
}

# Usage example function
usage_example() {
    echo "Usage: $0 {start|stop|status}"
    case "$1" in
        start)
            echo "Starting service..."
            ;;
        stop)
            echo "Stopping service..."
            ;;
        status)
            echo "Service status: Running"
            ;;
        *)
            error_exit "Invalid command"
            ;;
    esac
}

# Signal handlers
trap cleanup EXIT

cleanup() {
    echo -e "\nCleaning up temporary files..."
    rm -f /tmp/temp-file*
}

# Input validation example
validate_number() {
    local num=$1
    if ! [[ "$num" =~ ^[0-9]+$ ]]; then
        error_exit "Please enter a valid number"
    fi
}

# Check dependencies
check_dependencies() {
    local deps=("ping" "lsb_release" "df")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &> /dev/null; then
            error_exit "Missing dependency: $dep"
        fi
    done
}

# Initialize script
init() {
    case "${1:-}" in
        start|stop|status)
            usage_example "$1"
            ;;
        *)
            check_dependencies
            main
            ;;
    esac
}

# Start script
init "$@"
