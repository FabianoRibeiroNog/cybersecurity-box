# Cybersecurity Box - Agent Instructions

## Project Goal

Build a modular cybersecurity hardware platform.

Current phase:

ESP32 Wi-Fi Network Monitor using MicroPython.

Long-term direction:

ESP32 modules -> monitoring -> data collection -> Raspberry Pi Cybersecurity Box.

## Current Hardware

- ESP32 WROOM-32
- 30 pins
- USB-C
- MicroPython 1.28.0
- ESP32_GENERIC firmware

Development environment:

- Windows
- VS Code
- Git
- GitHub
- MicroPython
- Python

## Primary Language

Prefer Python and MicroPython.

Do not replace MicroPython code with C or C++ unless there is a clear
technical reason and the user explicitly agrees.

## Current Architecture

firmware/esp32/main.py

- Application entry point
- Main monitoring loop
- Coordinates project modules

firmware/esp32/wifi_monitor.py

- Wi-Fi scanning
- SSID processing
- BSSID formatting
- RSSI classification
- Security interpretation
- Hidden-network identification

firmware/esp32/time_sync.py

- Internet connection for clock synchronization
- NTP synchronization

## Development Principles

- Make small incremental changes.
- Preserve existing working behavior.
- Prefer readable code over clever code.
- Avoid unnecessary abstractions.
- Keep ESP32 memory limitations in mind.
- Do not assume CPython libraries are available in MicroPython.
- Reuse existing functions instead of duplicating logic.
- Explain significant architectural changes before implementing them.

## Git Workflow

Before editing:

1. Run git status.
2. Inspect the relevant files.

Before committing:

1. Run git diff.
2. Test the change.
3. Run git add only for relevant files.
4. Run git diff --staged.
5. Review the staged changes.

Commit prefixes:

- feat:
- fix:
- refactor:
- docs:
- test:
- chore:

Do not:

- force push
- rewrite Git history
- delete branches
- create tags
- create releases
- push directly to main

unless explicitly requested.

## Security Rules

Never commit:

- Wi-Fi passwords
- API keys
- access tokens
- private keys
- credentials
- secrets

Do not print credentials in logs.

Network functionality should default to passive observation.

Do not implement active attacks against third-party systems.

## Hardware Rules

Do not perform destructive hardware operations without explicit approval.

This includes:

- erase flash
- reinstall firmware
- reformat filesystem
- destructive storage operations

Normal source file upload and soft reset are allowed when testing
an explicitly requested firmware change.

## Definition of Done

A firmware change is complete when:

1. Code is syntactically valid.
2. MicroPython compatibility was considered.
3. No credentials or secrets were introduced.
4. Relevant documentation was updated when necessary.
5. The change was tested on the ESP32 when hardware verification is required.

If hardware verification was not performed, explicitly state:

Not verified on hardware.
