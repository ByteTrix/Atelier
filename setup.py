from setuptools import setup, find_packages

setup(
    name="setupr",
    version="0.1.0",
    packages=find_packages(where="src"),
    package_dir={"": "src"},
    install_requires=[
        "textual>=0.47.1",
        "distro>=1.9.0",
        "pkginfo>=1.9.6",
    ],
    python_requires=">=3.7",
    entry_points={
        "console_scripts": [
            "setupr=setupr.main:run",
        ],
    },
    package_data={
        "setupr": ["main.css"],
    },
)