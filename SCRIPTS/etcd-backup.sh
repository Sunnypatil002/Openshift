#!/bin/bash

# Variables
MASTER_NODE="core@master-1.ocp512.vcenterlocalhost.com"
BACKUP_SCRIPT="/usr/local/bin/cluster-backup.sh"
BACKUP_PATH="/home/core/assets/backup"
REMOTE_SERVER="root@172.40.20.200"
REMOTE_PATH="/root/backup/"
PRIVATE_KEY_PATH="/home/core/.ssh/authorized_keys.d/ignition"  # Private key path for SSH

# Step 1: SSH into the master node
echo "Starting SSH connection to $MASTER_NODE..."
ssh $MASTER_NODE << EOF
  # Switch to root user
  sudo su

  # Step 1.1: Check initial files in the backup directory before running the script
  echo "Checking initial files in $BACKUP_PATH..."
  initial_files=\$(ls -1 "$BACKUP_PATH")
  echo "\$initial_files"

  # Step 1.2: Run the backup script
  echo "Running backup script..."
  sh $BACKUP_SCRIPT $BACKUP_PATH
  if [ \$? -ne 0 ]; then
    echo "Backup script failed, exiting."
    exit 1
  fi
  echo "Backup completed successfully."

# Step 3: Check if new files have been added to the backup directory
  echo "Checking backup files in $BACKUP_PATH..."
  new_files=\$(ls -1 "$BACKUP_PATH")
  echo "\$new_files"

  # Store new files that were added
  for file in \$new_files; do
    if ! echo "\$initial_files" | grep -q "\$file"; then
      new_file_list="\$new_file_list \$file"
    fi
  done
  echo "New files"
  echo "\$new_file_list"

# Step 4: SCP new files to the bastion node one at a time
  if [ -n "\$new_file_list" ]; then
    echo "Transferring new files to $REMOTE_SERVER one at a time..."
    for new_file in \$new_file_list; do
      echo "Transferring file: \$new_file"
      echo "$BACKUP_PATH/\$new_file"
      echo "$PRIVATE_KEY_PATH"
      scp -i $PRIVATE_KEY_PATH "$BACKUP_PATH/\$new_file" $REMOTE_SERVER:$REMOTE_PATH

      if [ \$? -ne 0 ]; then
        echo "SCP failed for \$new_file, exiting."
        exit 1
      else
        echo "SCP succeeded for \$new_file"
      fi
    done
    echo "Files transferred successfully."
  else
    echo "No new files were added to the backup directory."
  fi


EOF

# Continue with other steps after SSH if needed
