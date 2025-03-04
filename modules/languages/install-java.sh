#!/usr/bin/env bash
#
# Java Installation
# ---------------
# Installs Java Development Kit and related tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[java] Installing Java Development Kit..."

# Check if Java is already installed
if ! command -v java &> /dev/null; then
    # Add Eclipse Temurin repository
    log_info "[java] Adding Eclipse Temurin repository..."
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
    echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

    # Install Java and build tools
    log_info "[java] Installing JDK and build tools..."
    sudo apt-get update
    sudo apt-get install -y temurin-17-jdk maven gradle

    # Set JAVA_HOME
    JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    echo "export JAVA_HOME=$JAVA_HOME" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> "$HOME/.bashrc"

    log_success "[java] Java Development Kit installed successfully!"
else
    log_warn "[java] Java is already installed"
fi

# Verify installation
log_info "[java] Version information:"
echo "Java version:"
java -version
echo -e "\nMaven version:"
mvn --version
echo -e "\nGradle version:"
gradle --version