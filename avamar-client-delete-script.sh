#!/bin/bash

# File containing the list of retired clients
input_file="YOUR_FILENAME_HERE"

# Log file for the deletion process
log_file="client_deletion_log.txt"

# Function to delete a client
delete_client() {
    local client_name="$1"
    local domain="$2"
    
    echo "Deleting client: $client_name" | tee -a "$log_file"
    mccli client delete --name="$client_name" --domain="$domain" >> "$log_file" 2>&1
    
    if [ $? -eq 0 ]; then
        echo "Successfully deleted client: $client_name" | tee -a "$log_file"
    else
        echo "Failed to delete client: $client_name" | tee -a "$log_file"
    fi
    echo "----------------------------------------" >> "$log_file"
}

# Main script
echo "Starting client deletion process..." | tee "$log_file"
echo "----------------------------------------" >> "$log_file"

# Skip the header line and process each client
tail -n +2 "$input_file" | while IFS=',' read -r client domain client_type; do
    # Remove any leading/trailing whitespace
    client=$(echo "$client" | xargs)
    domain=$(echo "$domain" | xargs)
    
    # Check if the domain is empty or /, use / as the default
    if [ -z "$domain" ] || [ "$domain" = "/" ]; then
        domain="/"
    fi
    
    delete_client "$client" "$domain"
done

echo "Client deletion process completed. Please check $log_file for details."
