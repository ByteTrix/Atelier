"""Package data loading and processing functions."""

import json
import logging
import os
import random
from dataclasses import dataclass
from typing import List, Dict, Any, Optional

logger = logging.getLogger(__name__)

@dataclass
class PackageInfo:
    """Package information container."""
    name: str
    display_name: str
    description: str
    size: str
    status: str
    category: str
    version: str = ""
    homepage: str = ""
    install_command: str = ""

# Sample package categories
CATEGORIES = [
    "Development", "Languages", "Libraries", "Frameworks",
    "Databases", "Tools", "Cloud", "Other"
]

# Common development tools and packages
SAMPLE_PACKAGES = [
    {"name": "gcc", "display_name": "GCC", "category": "Development", 
     "description": "GNU Compiler Collection", "size": "15.2 MB"},
    {"name": "python3", "display_name": "Python 3", "category": "Languages", 
     "description": "Python programming language", "size": "5.8 MB"},
    {"name": "nodejs", "display_name": "Node.js", "category": "Languages", 
     "description": "JavaScript runtime environment", "size": "12.3 MB"},
    {"name": "docker", "display_name": "Docker", "category": "Tools", 
     "description": "Container platform", "size": "28.7 MB"},
    {"name": "postgresql", "display_name": "PostgreSQL", "category": "Databases", 
     "description": "Advanced object-relational database", "size": "18.4 MB"},
    {"name": "redis", "display_name": "Redis", "category": "Databases", 
     "description": "In-memory data structure store", "size": "2.1 MB"},
    {"name": "nginx", "display_name": "NGINX", "category": "Tools", 
     "description": "High-performance HTTP server", "size": "3.8 MB"},
    {"name": "git", "display_name": "Git", "category": "Development", 
     "description": "Distributed version control system", "size": "4.7 MB"},
    {"name": "rust", "display_name": "Rust", "category": "Languages", 
     "description": "Systems programming language", "size": "22.5 MB"},
    {"name": "go", "display_name": "Go", "category": "Languages", 
     "description": "Programming language designed at Google", "size": "11.8 MB"},
    {"name": "cmake", "display_name": "CMake", "category": "Development", 
     "description": "Cross-platform build system", "size": "7.2 MB"},
    {"name": "llvm", "display_name": "LLVM", "category": "Development", 
     "description": "Compiler infrastructure", "size": "35.9 MB"},
    {"name": "terraform", "display_name": "Terraform", "category": "Cloud", 
     "description": "Infrastructure as code software", "size": "19.3 MB"},
    {"name": "kubernetes", "display_name": "Kubernetes", "category": "Cloud", 
     "description": "Container orchestration system", "size": "26.8 MB"},
    {"name": "ansible", "display_name": "Ansible", "category": "Tools", 
     "description": "IT automation platform", "size": "4.2 MB"},
    {"name": "jenkins", "display_name": "Jenkins", "category": "Tools", 
     "description": "Open source automation server", "size": "16.7 MB"},
    {"name": "gradle", "display_name": "Gradle", "category": "Development", 
     "description": "Build automation tool", "size": "9.5 MB"},
    {"name": "maven", "display_name": "Maven", "category": "Development", 
     "description": "Build automation tool", "size": "8.2 MB"},
    {"name": "typescript", "display_name": "TypeScript", "category": "Languages", 
     "description": "Typed superset of JavaScript", "size": "3.1 MB"},
    {"name": "php", "display_name": "PHP", "category": "Languages", 
     "description": "Server-side scripting language", "size": "7.5 MB"},
    {"name": "ruby", "display_name": "Ruby", "category": "Languages", 
     "description": "Dynamic programming language", "size": "6.8 MB"},
    {"name": "django", "display_name": "Django", "category": "Frameworks", 
     "description": "Python web framework", "size": "5.3 MB"},
    {"name": "rails", "display_name": "Ruby on Rails", "category": "Frameworks", 
     "description": "Ruby web framework", "size": "8.9 MB"},
    {"name": "react", "display_name": "React", "category": "Libraries", 
     "description": "JavaScript library for building UIs", "size": "2.2 MB"},
    {"name": "vue", "display_name": "Vue.js", "category": "Libraries", 
     "description": "JavaScript framework for UIs", "size": "1.8 MB"},
    {"name": "angular", "display_name": "Angular", "category": "Frameworks", 
     "description": "TypeScript-based web application framework", "size": "4.5 MB"},
    {"name": "mongodb", "display_name": "MongoDB", "category": "Databases", 
     "description": "Document-oriented database", "size": "14.6 MB"},
    {"name": "mysql", "display_name": "MySQL", "category": "Databases", 
     "description": "Relational database management system", "size": "17.1 MB"},
    {"name": "sqlite", "display_name": "SQLite", "category": "Databases", 
     "description": "Self-contained, serverless SQL database", "size": "0.8 MB"},
    {"name": "aws-cli", "display_name": "AWS CLI", "category": "Cloud", 
     "description": "Amazon Web Services command-line interface", "size": "8.7 MB"},
    {"name": "heroku-cli", "display_name": "Heroku CLI", "category": "Cloud", 
     "description": "Heroku command-line interface", "size": "6.3 MB"},
    {"name": "docker-compose", "display_name": "Docker Compose", "category": "Tools", 
     "description": "Tool for defining multi-container Docker applications", "size": "3.4 MB"},
    {"name": "jupyter", "display_name": "Jupyter", "category": "Development", 
     "description": "Interactive computing notebook", "size": "7.8 MB"},
    {"name": "selenium", "display_name": "Selenium", "category": "Tools", 
     "description": "Browser automation framework", "size": "5.1 MB"},
    {"name": "kubernetes-cli", "display_name": "kubectl", "category": "Cloud", 
     "description": "Kubernetes command-line tool", "size": "4.9 MB"},
    {"name": "prometheus", "display_name": "Prometheus", "category": "Tools", 
     "description": "Monitoring system & time series database", "size": "13.2 MB"},
]

def _generate_package_list() -> List[PackageInfo]:
    """Generate a list of sample packages for demo purposes."""
    packages = []
    
    for pkg_data in SAMPLE_PACKAGES:
        status = random.choice(["not_installed", "installed", "updateable"])
        
        # Create package info
        pkg = PackageInfo(
            name=pkg_data["name"],
            display_name=pkg_data["display_name"],
            description=pkg_data["description"],
            size=pkg_data["size"],
            status=status,
            category=pkg_data["category"],
            version=f"{random.randint(1, 5)}.{random.randint(0, 9)}.{random.randint(0, 9)}",
            homepage=f"https://{pkg_data['name']}.org",
            install_command=f"apt install {pkg_data['name']}"
        )
        packages.append(pkg)
        
    # Generate additional packages
    for i in range 30):
        name = f"pkg-{i}"
        display_name = f"Package {i}"
        category = random.choice(CATEGORIES)
        status = random.choice(["not_installed", "installed", "updateable"])
        size = f"{random.randint(1, 50)}.{random.randint(1, 9)} MB"
        
        pkg = PackageInfo(
            name=name,
            display_name=display_name,
            description=f"This is a generated package for demo purposes ({i})",
            size=size,
            status=status,
            category=category,
            version=f"{random.randint(0, 5)}.{random.randint(0, 9)}.{random.randint(0, 9)}",
            homepage=f"https://example.com/{name}",
            install_command=f"apt install {name}"
        )
        packages.append(pkg)
        
    return packages

def get_all_packages() -> List[PackageInfo]:
    """Get a list of all available packages."""
    logger.info("Fetching package list")
    
    try:
        # In a real application, this would query the system's package manager
        # For demo purposes, we'll use sample data
        packages = _generate_package_list()
        logger.info(f"Found {len(packages)} packages")
        return packages
    
    except Exception as e:
        logger.error(f"Error fetching package list: {e}")
        raise
