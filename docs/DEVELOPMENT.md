# Development Guide

## Environment

Development currently uses:

- Windows
- VS Code
- Python
- MicroPython
- Git
- GitHub

## Firmware Location

ESP32 firmware is stored in:

firmware/esp32/

## Development Workflow

Recommended workflow:

1. Check repository state with git status.
2. Make a small change.
3. Review changes with git diff.
4. Upload and test on ESP32 when required.
5. Stage relevant files with git add.
6. Review staged changes with git diff --staged.
7. Commit.
8. Push after verification.

## ESP32 Communication

Device automation will use mpremote.

Automation scripts will live inside:

scripts/
