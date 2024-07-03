#!/bin/bash

# Script to create users and groups from a file, generate passwords, and log actions

INPUT_FILE=$1
LOG_FILE="/var/log/user_management.log"
PASSWORD_FILE="/var/secure/user_passwords.txt"
DATE=$(date "+%Y-%m-%d %H:%M:%S")

# Ensure the log and password directories exist
sudo mkdir -p /var/log
sudo mkdir -p /var/secure
sudo touch $LOG_FILE
sudo touch $PASSWORD_FILE

# Function to log actions
log_action() {
    echo "$DATE - $1" | sudo tee -a $LOG_FILE > /dev/null
}

# Function to generate a random password
generate_password() {
    tr -dc A-Za-z0-9 </dev/urandom | head -c 12 ; echo ''
}

# Ensure input file is provided
if [[ -z "$INPUT_FILE" ]]; then
    echo "Usage: $0 <input_file>"
    log_action "ERROR: No input file provided"
    exit 1
fi

# Read the input file line by line
while IFS=';' read -r username groups; do
    # Trim whitespace
    username=$(echo "$username" | xargs)
    groups=$(echo "$groups" | xargs)

    # Ignore empty lines
    if [[ -z "$username" ]]; then
        continue
    fi

    # Check if user already exists
    if id "$username" &>/dev/null; then
        log_action "User $username already exists"
        continue
    fi

    # Create the user with their own personal group
    user_group=$username
    if ! getent group "$user_group" > /dev/null; then
        sudo groupadd "$user_group"
        log_action "Created group $user_group"
    fi

    sudo useradd -m -g "$user_group" -s /bin/bash "$username"
    log_action "Created user $username with group $user_group"

    # Generate a random password
    password=$(generate_password)
    echo "$username:$password" | sudo chpasswd
    log_action "Set password for user $username"

    # Store the password securely
    echo "$username,$password" | sudo tee -a $PASSWORD_FILE > /dev/null

    # Handle additional groups
    IFS=',' read -ra ADD_GROUPS <<< "$groups"
    for group in "${ADD_GROUPS[@]}"; do
        group=$(echo "$group" | xargs)
        if ! getent group "$group" > /dev/null; then
            sudo groupadd "$group"
            log_action "Created group $group"
        fi
        sudo usermod -aG "$group" "$username"
        log_action "Added user $username to group $group"
    done

    # Set appropriate permissions and ownership for the home directory
    sudo chown -R "$username:$user_group" "/home/$username"
    sudo chmod 700 "/home/$username"
    log_action "Set permissions for home directory of user $username"

done < "$INPUT_FILE"

log_action "User creation process completed"

