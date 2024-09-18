#!/bin/bash

# File containing the list of retired clients
input_file="20240913-RetiredList.csv"

# Log file for the deletion process
log_file="client_deletion_log.txt"

# Function to delete a client
delete_client() {
    local client_name="$1"
    
    echo "Deleting client: $client_name" | tee -a "$log_file"
    mccli client delete --name="$client_name" --domain="/MC_RETIRED" >> "$log_file" 2>&1
    
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

# Process each client in the file
while IFS= read -r line; do
    # Extract client name up to the first space
    client=$(echo "$line" | cut -d' ' -f1)
    
    # Remove any leading/trailing whitespace
    client=$(echo "$client" | xargs)
    
    # Skip empty lines
    if [ -n "$client" ]; then
        delete_client "$client"
    fi
done < "$input_file"

echo "Client deletion process completed. Please check $log_file for details."
