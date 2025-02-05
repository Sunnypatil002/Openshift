#!/bin/bash

# Variables
MASTER_NODE="core@master-1.ocp512.vcenterlocalhost.com"
BACKUP_SCRIPT="/usr/local/bin/cluster-backup.sh"
BACKUP_PATH="/home/core/assets/backup"
REMOTE_SERVER="root@172.40.20.200"
REMOTE_PATH="/root/backup/"  # Updated remote path
PRIVATE_KEY_PATH="/home/core/.ssh/id_rsa"  # Private key path for SSH

# Step 1: SSH into the master node
echo "Starting SSH connection to $MASTER_NODE..."
ssh $MASTER_NODE << EOF
  # Step 1.1: Once inside, navigate to the appropriate directory
#  echo "Changing directory to /usr/local/bin..."
  sudo su
#  cd /usr/local/bin
  ls /home/core/assets/backup/
# Step 1: Check initial files in the backup directory before running the script
  echo "Checking initial files in $BACKUP_PATH..."
  initial_files=$(ls "$BACKUP_PATH")
echo "$initial_files"
EOF
  Step 1.2: Run the backup script
 echo "Running backup script..."
 sh $BACKUP_SCRIPT $BACKUP_PATH
 if [ $? -ne 0 ]; then
   echo "Backup script failed, exiting."
   exit 1
 fi
 echo "Backup completed successfully."
EOF

Step 3: Check if new files have been added to the backup directory
echo "Checking backup files in $BACKUP_PATH..."

Store the new files list after the backup script runs
new_files=$(ls -1 "$BACKUP_PATH")
echo "$new_files"
Compare the initial and new file lists to see if new files were added
if [ "$initial_files" != "$new_files" ]; then
 echo "New files detected in the backup directory."
