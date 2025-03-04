#!/usr/bin/env bash
#
# Kotlin Installation
# -----------------
# Installs Kotlin and related tools
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[kotlin] Installing Kotlin..."

# Check if Kotlin is already installed
if ! command -v kotlin &> /dev/null; then
    # First ensure Java is installed
    if ! command -v java &> /dev/null; then
        log_info "[kotlin] Java is required. Installing OpenJDK..."
        sudo apt-get update
        sudo apt-get install -y openjdk-17-jdk
    fi

    # Install SDKMAN! if not already installed
    if ! command -v sdk &> /dev/null; then
        log_info "[kotlin] Installing SDKMAN!..."
        curl -s "https://get.sdkman.io" | bash
        source "$HOME/.sdkman/bin/sdkman-init.sh"
    fi

    # Install Kotlin using SDKMAN!
    log_info "[kotlin] Installing Kotlin using SDKMAN!..."
    sdk install kotlin

    # Create Kotlin project directory
    KOTLIN_HOME="$HOME/kotlin-projects"
    mkdir -p "$KOTLIN_HOME"

    # Create example Kotlin script
    log_info "[kotlin] Creating example Kotlin script..."
    cat > "$KOTLIN_HOME/hello.kt" << 'EOF'
fun main() {
    println("Hello from Kotlin!")
}
EOF

    # Create basic build.gradle.kts template
    cat > "$KOTLIN_HOME/build.gradle.kts.template" << 'EOF'
plugins {
    kotlin("jvm") version "1.9.0"
    application
}

group = "com.example"
version = "1.0-SNAPSHOT"

repositories {
    mavenCentral()
}

dependencies {
    implementation(kotlin("stdlib"))
    testImplementation(kotlin("test"))
}

tasks.test {
    useJUnitPlatform()
}

kotlin {
    jvmToolchain(17)
}

application {
    mainClass.set("MainKt")
}
EOF

    log_success "[kotlin] Kotlin installed successfully!"
    
    # Display help information
    log_info "[kotlin] Quick start guide:"
    echo "
    Kotlin:
    - Check version: kotlin -version
    - Run Kotlin file: kotlinc hello.kt -include-runtime -d hello.jar && java -jar hello.jar
    - Start REPL: kotlinc-jvm
    
    Project Setup:
    - Create new Gradle project:
      1. mkdir my-project && cd my-project
      2. cp $KOTLIN_HOME/build.gradle.kts.template build.gradle.kts
      3. mkdir -p src/main/kotlin src/test/kotlin
    
    Gradle Commands:
    - Build project: ./gradlew build
    - Run tests: ./gradlew test
    - Run application: ./gradlew run
    
    Development:
    - Source files go in: src/main/kotlin/
    - Test files go in: src/test/kotlin/
    - Example project directory: $KOTLIN_HOME
    
    IDE Integration:
    - IntelliJ IDEA is recommended for Kotlin development
    - Android Studio for Android development
    
    Environment:
    - Kotlin is installed via SDKMAN!
    - Project templates in: $KOTLIN_HOME
    - Run 'source ~/.sdkman/bin/sdkman-init.sh' to update PATH
    "

    # Note about Android development
    log_info "[kotlin] Note: For Android development, install Android Studio for a complete Kotlin+Android environment."
else
    log_warn "[kotlin] Kotlin is already installed."
fi

# Verify installation
log_info "[kotlin] Verifying installation..."
kotlin -version