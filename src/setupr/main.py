"""Main entry point for the Setupr package manager."""

import sys
import argparse
from setupr.ui.app import SetuprApp


def parse_arguments():
    """Parse command line arguments."""
    parser = argparse.ArgumentParser(description="Setupr - Modern Terminal Package Manager")
    parser.add_argument("--dev", action="store_true", help="Run in development mode")
    return parser.parse_args()


def run():
    """Run the Setupr application."""
    args = parse_arguments()
    
    try:
        app = SetuprApp()
        app.run()
    except KeyboardInterrupt:
        print("Setupr was terminated by the user.")
        sys.exit(0)
    except Exception as e:
        print(f"Error: {e}")
        if args.dev:
            import traceback
            traceback.print_exc()
        sys.exit(1)


if __name__ == "__main__":
    run()
