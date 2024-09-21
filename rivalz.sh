#!/bin/bash

# Update and upgrade the system
sudo apt update && sudo apt upgrade -y

# Install Node.js and npm
curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
sudo apt install -y nodejs

# Install Rivalz CLI
npm i -g rivalz-node-cli

# Install screen and expect
sudo apt install -y screen expect

# Ethereum address (replace with your actual Ethereum address)
ETH_ADDRESS="your_eth_address_here"

# Create an expect script to handle the interactive prompts for Ethereum address and disk size
expect << EOF
spawn rivalz run
expect "? Enter wallet address (EVM):"
send "$ETH_ADDRESS\r"
send "\r"  # Send Enter key press (first)
send "\r"  # Send Enter key press (second)

# Expect the disk size prompt, capture the maximum value and calculate half of it
expect {
    -re {Enter Disk size of /dev/sda3 \(SSD\) you want to use \(GB, Max ([0-9]+) GB\):} {
        set max_disk_size \$expect_out(1,string)
        set half_disk_size [expr \$max_disk_size / 2]
        send "\$half_disk_size\r"
    }
}

# Send Enter to confirm the disk size and proceed
send "\r"

# Send Ctrl+C after data entry to stop the process
sleep 120 
send \003   # This sends Ctrl+C
expect eof
EOF

# Now start a screen session and run rivalz within it
screen -S rivalz -dm bash -c "rivalz run"
