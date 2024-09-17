#!/bin/bash

# Output file
output_file="retired_clients_report.txt"

# Debug log file
debug_log="debug_log.txt"

# Function to log debug messages
debug_log() {
    echo "$(date): $1" >> "$debug_log"
}

debug_log "Script started"

# Clear the output file if it exists
> $output_file
debug_log "Output file cleared"

# Get list of clients in MC_RETIRED domain
debug_log "Attempting to get list of clients"
client_output=$(mccli client show --domain=MC_RETIRED)
debug_log "Raw output of client show command obtained"

# Parse clients
clients=$(echo "$client_output" | awk 'NR>3 {print $1}')

if [[ -z "$clients" ]]; then
    debug_log "No clients found in MC_RETIRED domain after parsing"
    echo "No clients found in MC_RETIRED domain" >> $output_file
    exit 1
fi

debug_log "Clients found. Processing each client..."

while IFS= read -r client; do
    debug_log "Processing client: $client"
    echo "Client: $client" >> $output_file
    
    # Check for backups
    debug_log "Checking backups for client: $client"
    backups=$(mccli backup show --domain=MC_RETIRED --client="$client")
    
    if [[ -n "$backups" ]]; then
        debug_log "Backups found for client: $client"
        echo "Backups exist:" >> $output_file
        
        # Extract backup information
        echo "$backups" | grep -E "Backup:|Expiration:" >> $output_file
        
        # Try to get total size
        size=$(echo "$backups" | grep "Total size:" | awk '{print $3, $4}')
        if [[ -n "$size" ]]; then
            echo "Total size: $size" >> $output_file
        else
            echo "Total size: Not available" >> $output_file
        fi
    else
        debug_log "No backups found for client: $client"
        echo "No backups found" >> $output_file
    fi
    
    echo "" >> $output_file
done <<< "$clients"

debug_log "Script completed"
