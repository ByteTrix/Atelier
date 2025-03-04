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
    # Add adoptium repository for Eclipse Temurin JDK
    log_info "[java] Adding Eclipse Temurin repository..."
    wget -O - https://packages.adoptium.net/artifactory/api/gpg/key/public | sudo apt-key add -
    echo "deb https://packages.adoptium.net/artifactory/deb $(lsb_release -cs) main" | sudo tee /etc/apt/sources.list.d/adoptium.list

    # Update package lists
    sudo apt-get update

    # Install latest LTS version of Eclipse Temurin JDK
    log_info "[java] Installing Eclipse Temurin JDK..."
    sudo apt-get install -y temurin-17-jdk

    # Install additional Java development tools
    log_info "[java] Installing additional Java tools..."
    sudo apt-get install -y maven gradle

    # Set up JAVA_HOME environment variable
    JAVA_HOME=$(readlink -f /usr/bin/java | sed "s:/bin/java::")
    echo "export JAVA_HOME=$JAVA_HOME" >> "$HOME/.bashrc"
    echo "export PATH=\$PATH:\$JAVA_HOME/bin" >> "$HOME/.bashrc"

    # Create Maven settings directory
    mkdir -p "$HOME/.m2"

    # Create basic Maven settings
    cat > "$HOME/.m2/settings.xml" << 'EOF'
<settings xmlns="http://maven.apache.org/SETTINGS/1.0.0"
          xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
          xsi:schemaLocation="http://maven.apache.org/SETTINGS/1.0.0
                             http://maven.apache.org/xsd/settings-1.0.0.xsd">
    <localRepository>${user.home}/.m2/repository</localRepository>
    <interactiveMode>true</interactiveMode>
    <offline>false</offline>
    <mirrors>
        <mirror>
            <id>central</id>
            <name>Central Repository</name>
            <url>https://repo.maven.apache.org/maven2</url>
            <mirrorOf>central</mirrorOf>
        </mirror>
    </mirrors>
</settings>
EOF

    # Create Gradle properties directory
    mkdir -p "$HOME/.gradle"

    # Create basic Gradle properties
    cat > "$HOME/.gradle/gradle.properties" << 'EOF'
org.gradle.daemon=true
org.gradle.parallel=true
org.gradle.caching=true
org.gradle.jvmargs=-Xmx2048m -XX:MaxPermSize=512m -XX:+HeapDumpOnOutOfMemoryError
EOF

    log_success "[java] Java Development Kit and tools installed successfully!"
    
    # Display help information
    log_info "[java] Quick start guide:"
    echo "
    Java Development Kit:
    - Check Java version: java -version
    - Compile Java file: javac File.java
    - Run Java program: java File
    
    Maven:
    - Create new project: mvn archetype:generate
    - Build project: mvn clean install
    - Run tests: mvn test
    
    Gradle:
    - Create new project: gradle init
    - Build project: ./gradlew build
    - Run tests: ./gradlew test
    
    Environment:
    - JAVA_HOME is set to: $JAVA_HOME
    - Restart your terminal or run 'source ~/.bashrc' to apply PATH changes
    "
else
    log_warn "[java] Java is already installed."
    java -version
fi

# Verify installations
log_info "[java] Verifying installations..."
echo "Java version:"
java -version
echo -e "\nMaven version:"
mvn --version
echo -e "\nGradle version:"
gradle --version