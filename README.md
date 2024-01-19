# ByteCopyShield Backup Script


## Overview

ByteCopyShield is a simple yet powerful shell script designed to facilitate easy and customizable backups on Unix-based systems. This script prompts the user to select files and folders for backup, choose the backup destination, and decide whether to store the backup as a ZIP archive or individual files.

## Features

- **User-Friendly Interaction:** ByteCopyShield engages users through a series of prompts, ensuring a seamless and interactive backup experience.

- **Flexible Backup Selection:** Users can choose specific files and folders for backup, allowing for a customized and efficient backup process.

- **Backup Type Options:** Users have the choice to store backups either as ZIP archives or individual files based on their preferences.

- **Destination Selection:** ByteCopyShield enables users to choose where the backup should be stored, whether in the default home directory or another specified folder.

## Prerequisites

- The script relies on a tool called `gum` for user interaction. Ensure it is installed and available in your system's PATH.

## Usage

1. **Run the Script:**
   ```bash
   ./byteCopyShield.sh
   ```

2. **Follow the Prompts:**
    - Confirm if you want to create a backup.
    - Select files and folders for backup.
    - Optionally choose particular files or folders.
    - Specify whether to store the backup as a ZIP archive or individual files.
    - Choose the destination for the backup.

3. **View Backup Information:**
    - The script will display the size of the ZIP archive if that option is chosen.

4. **Complete:**
    - The backup will be created and stored according to your selections.

## Tips

- Ensure you have the necessary permissions to read and copy the selected files and write to the chosen backup destination.

- Regularly check and update the script for the latest features and improvements.

## Notes

- The temporary folder for backup is named `.byteCopyShield` and is created in the user's home directory.

- The script uses the system date to create a folder with the format `YYYY-MM-DD-backup` within the temporary folder.

- For ZIP archives, the script calculates and displays the size in both kilobytes and megabytes.

## Contributors

- Vlad Pavlovski ([@vladpavlovski]

Feel free to contribute by submitting bug reports, feature requests, or pull requests.

---

Thank you for choosing ByteCopyShield for your backup needs! 🚀
