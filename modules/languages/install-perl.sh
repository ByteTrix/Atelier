#!/usr/bin/env bash
#
# Perl Installation
# ---------------
# Installs Perl, common modules, and CPAN configuration
#
# Author: Atelier Team
# License: MIT

set -euo pipefail

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
source "${SCRIPT_DIR}/../../lib/utils.sh"

log_info "[perl] Installing Perl and related tools..."

# Check if Perl is already installed (it usually is on Ubuntu)
if ! command -v perl &> /dev/null; then
    log_info "[perl] Installing Perl..."
    sudo apt-get update
    sudo apt-get install -y perl
fi

# Install essential build tools and libraries
log_info "[perl] Installing build dependencies..."
sudo apt-get install -y \
    build-essential \
    cpanminus \
    liblocal-lib-perl \
    perl-doc \
    libperl-dev \
    libssl-dev \
    zlib1g-dev

# Set up local::lib
log_info "[perl] Setting up local::lib..."
echo 'eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"' >> "$HOME/.bashrc"
eval "$(perl -I$HOME/perl5/lib/perl5 -Mlocal::lib)"

# Configure CPAN
log_info "[perl] Configuring CPAN..."
mkdir -p "$HOME/.cpan/CPAN"
cat > "$HOME/.cpan/CPAN/MyConfig.pm" << 'EOF'
$CPAN::Config = {
  'auto_commit' => 1,
  'build_cache' => 100,
  'build_dir' => "$ENV{HOME}/.cpan/build",
  'cache_metadata' => 1,
  'commandnumber_in_prompt' => 1,
  'connect_to_internet_ok' => 1,
  'cpan_home' => "$ENV{HOME}/.cpan",
  'ftp_passive' => 1,
  'ftp_proxy' => undef,
  'http_proxy' => undef,
  'https_proxy' => undef,
  'prerequisites_policy' => "follow",
  'show_upload_date' => 1,
  'term_is_latin' => 1,
  'term_ornaments' => 1,
  'urllist' => [qw(
    https://cpan.metacpan.org
    https://mirrors.kernel.org/cpan/
  )],
  'use_sqlite' => 1,
};
1;
EOF

# Install common Perl modules
log_info "[perl] Installing common Perl modules..."
cpanm --notest \
    Modern::Perl \
    Moose \
    DateTime \
    DBI \
    DBD::SQLite \
    JSON \
    YAML \
    XML::LibXML \
    LWP::UserAgent \
    HTTP::Tiny \
    Template \
    Plack \
    Mojolicious \
    Data::Dumper \
    Try::Tiny \
    Path::Tiny \
    File::Spec \
    Test::More \
    Test::Deep

# Create directory for local Perl scripts
mkdir -p "$HOME/perl/bin"
echo 'export PATH="$HOME/perl/bin:$PATH"' >> "$HOME/.bashrc"

log_success "[perl] Perl and common modules installed successfully!"

# Display help information
log_info "[perl] Quick start guide:"
echo "
Perl:
- Check version: perl -v
- Run Perl script: perl script.pl
- Start Perl REPL: perl -de1
- Check installed modules: perldoc perllocal

CPAN:
- Install module: cpanm Module::Name
- Update all modules: cpan -u
- Search modules: cpan -s Module::Name
- Documentation: perldoc Module::Name

Environment:
- Perl modules are installed in: $HOME/perl5
- Local scripts directory: $HOME/perl/bin
- CPAN configuration: $HOME/.cpan/CPAN/MyConfig.pm

Common installed modules:
- Modern::Perl - Enable all modern features
- Moose - Modern object system
- DateTime - Date and time handling
- DBI - Database interface
- JSON/YAML - Data serialization
- Plack - Web application toolkit
- Mojolicious - Web framework
- Try::Tiny - Exception handling
"

# Verify installation
log_info "[perl] Verifying installation..."
echo "Perl version:"
perl -v
echo -e "\nCPAN version:"
cpan -v