#!/bin/bash

# Define colors and text styles
RESET='\033[0m'
BOLD='\033[1m'
UNDERLINE='\033[4m'
BLINK='\033[5m'
INVERT='\033[7m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
WHITE='\033[1;37m'

# Function to print a title with figlet
title() {
  printf "\n$BOLD$WHITE"
  figlet "$1"
  printf "$RESET\n"
}

# Function to print a horizontal line
breakLine() {
  printf "\n$BOLD$BLUE"
  printf '%*s' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -
  printf "$RESET\n"
  sleep 0.5
}

# Function to display a notification
notify() {
  printf "\n";
  printf "\033[1;46m %s \033[0m" "$1";
  printf "\n";
}

# Function to print an informational message
info() {
  printf "$BOLD$CYAN%s$RESET\n" "INFO: $1"
}

# Function to print a warning message
warn() {
  printf "$BOLD$YELLOW%s$RESET\n" "WARNING: $1"
}

# Function to print an error message
error() {
  printf "$BOLD$RED%s$RESET\n" "ERROR: $1"
}

# Function to print a success message
success() {
  printf "$BOLD$GREEN%s$RESET\n" "SUCCESS: $1"
}

# Function to print a section header
sectionHeader() {
  printf "$BOLD$INVERT$WHITE%s$RESET\n" "$1"
}

clear

title toolsup
echo "unium's shitty tools installer"
breakLine

# Function to ask for sudo password
function askPassword {
    if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
        sudo -S echo authenticated > /dev/null && echo
    fi
    if [ $(sudo -n uptime 2>&1 | grep "load" | wc -l) != "1" ]; then
        error "Incorrect or no password provided"
        askPassword
    fi
}

# Function to check if Flatpak is installed
function checkFlatpak {
    if ! command -v flatpak &> /dev/null; then
        read -p "Flatpak isn't installed! Do you want to install Flatpak? [Y/n] " install_flatpak
        if [ "$install_flatpak" == "Y" ] || [ "$install_flatpak" == "y" ] || [ -z "$install_flatpak" ]; then
            sudo apt-get install flatpak -y
            success "Flatpak installed successfully!"
        else
            warn "Skipping Flatpak installation. You will not be able to install :"
        fi
    fi
}

# Ask for sudo password
askPassword

# Check if Flatpak is installed
checkFlatpak

# Define categories
categories=("IDEs/Text Editors" "Programming Languages" "Tools" "Utilities" "Development Libraries" "Version Control Systems" "Databases")

# Display category selection menu
sectionHeader "Select categories to install:"
select category in "${categories[@]}"; do
    case $category in
        "IDEs/Text Editors")
            # List of IDEs/Text Editors to install
            software=("code" "nano" "vim" "emacs")
            break
            ;;
        "Programming Languages")
            # List of Programming Languages to install
            software=("nodejs" "npm" "gcc" "g++" "python3" "ruby" "java" "rust" "golang")
            break
            ;;
        "Tools")
            # List of Tools to install
            software=("xdotool" "brave-browser" "git" "docker.io" "htop" "curl" "wget" "tree" "tmux" "htop" "ncdu" "tldr" "jq" "htop" "ffmpeg")
            break
            ;;
        "Utilities")
            # List of Utilities to install
            software=("gparted" "htop" "tree" "ncdu" "tldr")
            break
            ;;
        "Development Libraries")
            # List of Development Libraries to install
            software=("libssl-dev" "libreadline-dev" "libsqlite3-dev" "libxml2-dev" "libxslt1-dev" "libbz2-dev" "libncurses5-dev" "libffi-dev")
            break
            ;;
        "Version Control Systems")
            # List of Version Control Systems to install
            software=("git" "subversion" "mercurial")
            break
            ;;
        "Databases")
            # List of Database Systems to install
            software=("mysql-server" "postgresql" "sqlite3")
            break
            ;;
        *)
            warn "Invalid option, please try again."
            ;;
    esac
done

# Display the list of software to be installed
echo
sectionHeader "You are about to install the following:"
for tool in "${software[@]}"; do
    echo "- $tool"
done

# Ask for installation type
echo
sectionHeader "Select installation type:"
select install_type in "Single Tool" "Every Tool in category : \"$category\""; do
    case $install_type in
        "Single Tool")
            # Ask for the specific tool to install
            read -p "Enter the tool to install: " specific_tool
            software=("$specific_tool")
            break
            ;;
        "Every Tool in category : \"$category\"")
            # Nothing to change, using the selected category
            break
            ;;
        *)
            warn "Invalid option, please try again."
            ;;
    esac
done

# Install selected software
for tool in "${software[@]}"; do
    case $tool in
        "java")
            echo
            info "# Installing Java..."
            sudo apt-get install default-jdk -y > /dev/null
            ;;
        "rust")
            echo
            info "# Installing Rust..."
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
            ;;
        *)
            echo
            info "# Installing $tool..."
            sudo apt-get install $tool -y > /dev/null
            ;;
    esac
done

# Clean up
sudo apt-get install -f > /dev/null
sudo apt-get autoremove -y > /dev/null

# Display success message
success "All selected tools have been installed!"
