#!/usr/bin/env bash
#
# Java Installation
# ---------------
# Installs Java Development Kit and related tools
#
# Author: Atelier Team
# License: MIT

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

# Check for required commands
required_commands=("wget" "sudo" "apt-get" "lsb_release")
for cmd in "${required_commands[@]}"; do
    if ! command -v "$cmd" &> /dev/null; then
        log_error "[java] Required command not found: $cmd"
        return 1
    fi
done

log_info "[java] Installing Java Development Kit..."

# Check if Java is already installed
if ! command -v java &> /dev/null; then
    # Add Eclipse Temurin repository
    log_info "[java] Adding Eclipse Temurin repository..."
    if ! wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -; then
        log_error "[java] Failed to add Temurin GPG key"
        return 1
    fi

    if ! echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list; then
        log_error "[java] Failed to add Temurin repository"
        return 1
    fi

    # Install Java and build tools
    log_info "[java] Installing JDK and build tools..."
    if ! sudo apt-get update; then
        log_error "[java] Failed to update package list"
        return 1
    fi

    if ! sudo apt-get install -y temurin-17-jdk maven gradle; then
        log_error "[java] Failed to install Java and build tools"
        return 1
    fi

    # Set JAVA_HOME
    if ! JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::"); then
        log_error "[java] Failed to determine JAVA_HOME"
        return 1
    fi

    if ! echo "export JAVA_HOME=$JAVA_HOME" >> "$HOME/.bashrc"; then
        log_error "[java] Failed to set JAVA_HOME in .bashrc"
        return 1
    fi

    if ! echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> "$HOME/.bashrc"; then
        log_error "[java] Failed to update PATH in .bashrc"
        return 1
    fi

    log_success "[java] Java Development Kit installed successfully!"
else
    log_warn "[java] Java is already installed"
fi

# Verify installation
log_info "[java] Version information:"

echo "Java version:"
if ! java -version; then
    log_error "[java] Failed to verify Java installation"
    return 1
fi

echo -e "\nMaven version:"
if ! mvn --version; then
    log_error "[java] Failed to verify Maven installation"
    return 1
fi

echo -e "\nGradle version:"
if ! gradle --version; then
    log_error "[java] Failed to verify Gradle installation"
    return 1
fi

# Display help information
log_info "[java] Quick start guide:"
echo "
Java Development Environment:
- JDK Location: $JAVA_HOME
- Maven: mvn
- Gradle: gradle

Common Commands:
- Compile: javac YourFile.java
- Run: java YourFile
- Build with Maven: mvn clean install
- Build with Gradle: gradle build

Note: Restart your terminal or run 'source ~/.bashrc' to update environment variables
"