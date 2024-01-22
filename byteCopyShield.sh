#!/bin/sh

install_tool() {
    local tool_name="$1"

    # Determine the appropriate package manager and installation command based on the operating system
    local package_manager=""
    local install_command=""

    if [[ "$OSTYPE" == "darwin"* ]]; then
        # macOS (Homebrew)
        package_manager="brew"
        install_command="$package_manager install $tool_name"
    elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
        # Linux (apt for Debian/Ubuntu, yum for Red Hat/Fedora, etc.)
        if command -v apt &> /dev/null; then
            package_manager="apt"
        elif command -v yum &> /dev/null; then
            package_manager="yum"
        else
            echo "Unsupported package manager. Please install $tool_name manually."
            exit 1
        fi
        install_command="sudo $package_manager install -y $tool_name"
    else
        echo "Unsupported operating system. Please install $tool_name manually."
        exit 1
    fi

    # Check if the tool is installed, and if not, install it
    if ! command -v "$tool_name" &> /dev/null; then
        echo "$tool_name not found."

        # Install the tool using the determined package manager and command
        if command -v "$package_manager" &> /dev/null; then
            echo "Installing $tool_name with $package_manager..."
            eval "$install_command"
        else
            echo "$package_manager not found. Please install it and run the script again."
            exit 1
        fi
    fi
}

install_tool "zip"
install_tool "gum"


welcome_and_confirm_backup() {
    local YES="Yes. Let's go!"
    local NO="No. Next time."

    local MAKE_BACKUP=$(gum confirm "Welcome to ByteCopyShield! Are you ready to create a backup?" && echo "$YES" || echo "$NO")

    if [ "$MAKE_BACKUP" = "$YES" ]; then
        echo "Let's go!"
    elif [ "$MAKE_BACKUP" = "$NO" ]; then
        exit 0
    fi
}

welcome_and_confirm_backup

# Function to select files and folders for backup
select_files_and_folders_for_backup() {
  # List of files and folders in home directory
  HOME_DIR_LIST=$(ls -a $HOME)
  # Remove first two items from list (dot and double dot)
  HOME_DIR_LIST=${HOME_DIR_LIST[@]:5}

  SELECTION_FOR_BACKUP=$(gum choose $HOME_DIR_LIST --height=30 --no-limit --header="📁 Please select files and folders for backup...")
  # Check if user selected anything
  if [ ${#SELECTION_FOR_BACKUP} -eq 0 ]; then
      gum confirm "You didn't select anything. Do you want to continue?" && select_files_and_folders_for_backup || exit 0
  fi

  # add file path to each item in list and save it to variable
  for item in $SELECTION_FOR_BACKUP; do
      item="$HOME/$item"
      SELECTION_FOR_BACKUP_WITH_PATH="$SELECTION_FOR_BACKUP_WITH_PATH $item"
  done
}
select_files_and_folders_for_backup


# Function to select particular file or folder for backup
select_particular_file_or_folder_for_backup() {
    gum confirm "Do you want to select particular file or folder for backup?" && echo "" || return 1
    echo "📁 Please select particular file or folder for backup..."
    PARTICULAR_FILE_OR_FOLDER_FOR_BACKUP=$(gum file $HOME)
    # Add file path to SELECTION_FOR_BACKUP_WITH_PATH
    SELECTION_FOR_BACKUP_WITH_PATH="$SELECTION_FOR_BACKUP_WITH_PATH $PARTICULAR_FILE_OR_FOLDER_FOR_BACKUP"
    # Check if user want to repeat selection
    gum confirm "Do you want to select another particular file or folder for backup?" && select_particular_file_or_folder_for_backup || return 1
}

select_particular_file_or_folder_for_backup

# Function to ask user if he wants to store backup as files or archive
ask_user_if_he_wants_to_store_backup_as_files_or_archive() {
    ZIP_ARCHIVE_TITLE='ZIP archive'
    FILES_TITLE="Files"
    BACKUP_TYPE=$(gum choose "$ZIP_ARCHIVE_TITLE" "$FILES_TITLE"  --header="Do you want to store backup as files or archive?")
}

ask_user_if_he_wants_to_store_backup_as_files_or_archive

# Function to create a temporary folder for backup .byteCopyShield at home directory. If exists do nothing
create_temporary_folder_for_backup() {
  TEMPORARY_FOLDER_NAME=".byteCopyShield"
    if [ -d "$HOME/$TEMPORARY_FOLDER_NAME" ]; then
        echo "Folder $TEMPORARY_FOLDER_NAME already exists"
    else
        mkdir "$HOME/$TEMPORARY_FOLDER_NAME"
    fi
    TEMPORARY_FOLDER_FOR_BACKUP="$HOME/$TEMPORARY_FOLDER_NAME"
}

create_temporary_folder_for_backup

# Function to copy selected files and folders to temporary folder for backup .byteCopyShield. create new folder with name of today date in format YYYY-MM-DD-backup
copy_selected_files_and_folders_to_temporary_folder_for_backup() {
    TODAY_DATE=$(date +%Y-%m-%d)

    mkdir "$TEMPORARY_FOLDER_FOR_BACKUP/$TODAY_DATE-backup"

    # take each path of the item in list and copy file or folder of this path to temporary folder for backup
    for item in $SELECTION_FOR_BACKUP_WITH_PATH; do
        cp -r "$item" "$TEMPORARY_FOLDER_FOR_BACKUP/$TODAY_DATE-backup"
    done
}

copy_selected_files_and_folders_to_temporary_folder_for_backup

# Function to select destination folder for backup
select_destination_folder_for_backup() {
  DEFAULT_HOME_DIRECTORY_TITLE="Default home directory"
  ANOTHER_FOLDER_TITLE="Another folder"
  # Choose where to store backup. default home directory or select another folder
  WHERE_STORE_BACKUP=$(gum choose "$DEFAULT_HOME_DIRECTORY_TITLE" "$ANOTHER_FOLDER_TITLE" --header="Where to store backup?")
  if [ "$WHERE_STORE_BACKUP" = "$DEFAULT_HOME_DIRECTORY_TITLE" ]; then
    DESTINATION_FOLDER_FOR_BACKUP="$HOME"
  elif [ "$WHERE_STORE_BACKUP" = "$ANOTHER_FOLDER_TITLE" ]; then
    DESTINATION_FOLDER_FOR_BACKUP="$HOME/$(gum choose $HOME_DIR_LIST --height=30 --no-limit --header="📁 Please select destination folder for backup...")"
    # Check if user selected anything
    if [ ${#DESTINATION_FOLDER_FOR_BACKUP} -eq 0 ]; then
        gum confirm "You didn't select anything. Do you want to continue?" && select_destination_folder_for_backup || exit 0
    fi
  fi
}

select_destination_folder_for_backup

# Function to create a zip archive or folder with files based on $BACKUP_TYPE of temporary folder for backup .byteCopyShield and move it to destination folder for backup
create_zip_archive_or_folder_with_files_based_on_backup_type() {
    source_folder="$TEMPORARY_FOLDER_FOR_BACKUP"
    destination_folder="$DESTINATION_FOLDER_FOR_BACKUP"
    current_folder=$(pwd)
    if [ "$BACKUP_TYPE" = "$ZIP_ARCHIVE_TITLE" ]; then
        echo "Navigate to the parent directory"
        cd $source_folder || return  # Navigate to the parent directory
        zip -r "$destination_folder/$TODAY_DATE-backup.zip" "$TODAY_DATE-backup"
        echo "Return to the original directory"
        cd $current_folder  || return # Return to the original directory
    elif [ "$BACKUP_TYPE" = $FILES_TITLE ]; then
        mv "$source_folder/$TODAY_DATE-backup" "$destination_folder"
    fi
}

create_zip_archive_or_folder_with_files_based_on_backup_type

# Function to delete temporary folder for backup created at current folder
delete_temporary_folder_for_backup() {
    if [ -d "$TEMPORARY_FOLDER_FOR_BACKUP/$TODAY_DATE-backup" ]; then

        rm -rf "$TEMPORARY_FOLDER_FOR_BACKUP/$TODAY_DATE-backup"
    else
        echo "Folder .byteCopyShield doesn't exist"
    fi
}

delete_temporary_folder_for_backup

# Function to calculate and print the size of the zip archive
get_zip_archive_size() {
  if [ "$BACKUP_TYPE" = "$ZIP_ARCHIVE_TITLE" ]; then
    zip_file="$DESTINATION_FOLDER_FOR_BACKUP/$TODAY_DATE-backup.zip"
    if [ -f "$zip_file" ]; then
        size_in_bytes=$(du -s "$zip_file" | cut -f1)
        if [ "$size_in_bytes" -lt 1024 ]; then
            echo "Size of the zip archive: ${size_in_bytes} KB"
        else
            size_in_mb=$(echo "scale=2; $size_in_bytes / 1024" | bc)
            echo "Size of the zip archive: ${size_in_mb} MB"
        fi
    else
        echo "Zip file not found: $zip_file"
    fi
  fi
}

get_zip_archive_size

exit 0
