Write-Host ""
Write-Host "========================================="
Write-Host " Cybersecurity Box - Project Setup"
Write-Host "========================================="
Write-Host ""

# ------------------------------------------------------------
# 1. Criar diretorios
# ------------------------------------------------------------

$directories = @(
    "firmware\esp32",
    "docs",
    "docs\decisions",
    "scripts",
    "tests",
    ".vscode",
    ".agents",
    ".agents\rules",
    ".agents\agents",
    ".agents\agents\embedded-dev",
    ".agents\agents\reviewer"
)

foreach ($directory in $directories) {
    if (-not (Test-Path $directory)) {
        New-Item -ItemType Directory -Path $directory -Force | Out-Null
        Write-Host "[CRIADO] $directory"
    }
    else {
        Write-Host "[EXISTE] $directory"
    }
}


# ------------------------------------------------------------
# 2. Mover arquivos atuais do projeto
# ------------------------------------------------------------

function Move-ProjectFile {
    param (
        [string]$Source,
        [string]$Destination
    )

    if ((Test-Path $Source) -and (-not (Test-Path $Destination))) {
        Move-Item -Path $Source -Destination $Destination
        Write-Host "[MOVIDO] $Source -> $Destination"
    }
    elseif (Test-Path $Destination) {
        Write-Host "[IGNORADO] $Destination ja existe"
    }
}

Move-ProjectFile "main.py" "firmware\esp32\main.py"
Move-ProjectFile "wifi_monitor.py" "firmware\esp32\wifi_monitor.py"
Move-ProjectFile "time_sync.py" "firmware\esp32\time_sync.py"
Move-ProjectFile "project.txt" "docs\PROJECT_NOTES.md"


# ------------------------------------------------------------
# 3. AGENTS.md
# ------------------------------------------------------------

@'
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
'@ | Set-Content "AGENTS.md" -Encoding UTF8


# ------------------------------------------------------------
# 4. README.md
# ------------------------------------------------------------

@'
# Cybersecurity Box

A modular cybersecurity hardware project built incrementally using
ESP32, MicroPython, Python and eventually Raspberry Pi.

## Current Phase

ESP32 Wi-Fi Network Monitor.

## Current Capabilities

- Wi-Fi network scanning
- SSID detection
- BSSID detection
- Wi-Fi channel detection
- RSSI measurement
- Signal-strength classification
- Wi-Fi security identification
- Hidden-network identification
- Continuous monitoring
- Detection of newly observed access points
- Timestamp development in progress

## Project Structure

- firmware/esp32/ - ESP32 MicroPython source code
- docs/ - Architecture and development documentation
- scripts/ - Development and ESP32 automation scripts
- tests/ - Automated tests
- AGENTS.md - Instructions for AI coding agents

## Main Technologies

- ESP32 WROOM-32
- MicroPython
- Python
- Git
- GitHub
- VS Code
'@ | Set-Content "README.md" -Encoding UTF8


# ------------------------------------------------------------
# 5. ROADMAP.md
# ------------------------------------------------------------

@'
# Cybersecurity Box Roadmap

## v0.1.0 - Initial Wi-Fi Scanner

Completed:

- ESP32 setup
- MicroPython installation
- Automatic main.py execution
- Wi-Fi scanning
- SSID detection
- Channel detection
- RSSI measurement
- Git repository
- GitHub repository

## v0.2.0 - Wi-Fi Network Monitor

Completed or in progress:

- BSSID detection
- Wi-Fi security information
- Hidden-network detection
- Signal classification
- Modular Python structure
- Continuous monitoring
- Detection of newly observed access points
- Scan timestamps
- NTP synchronization

## Future Phases

- Structured logging
- Persistent event storage
- Better event detection
- Configuration management
- Automated tests
- Dashboard
- ESP32 to host communication
- Raspberry Pi integration
- Central Cybersecurity Box service
'@ | Set-Content "ROADMAP.md" -Encoding UTF8


# ------------------------------------------------------------
# 6. ARCHITECTURE.md
# ------------------------------------------------------------

@'
# Architecture

## Overview

The Cybersecurity Box is designed as a modular hardware cybersecurity
platform.

The current implementation runs on an ESP32 using MicroPython.

## ESP32 Firmware

### main.py

Main application entry point.

Responsibilities:

- Initialize the application
- Coordinate monitoring
- Maintain the monitoring loop
- Track known networks
- Trigger network events

### wifi_monitor.py

Wi-Fi monitoring module.

Responsibilities:

- Scan nearby Wi-Fi networks
- Format BSSID values
- Interpret security values
- Classify RSSI signal strength
- Display network information

### time_sync.py

Time synchronization module.

Responsibilities:

- Connect to an authorized Wi-Fi network
- Synchronize system time using NTP

## Future Architecture

ESP32 sensors and monitors will eventually communicate with a
Raspberry Pi acting as the central Cybersecurity Box controller.
'@ | Set-Content "docs\ARCHITECTURE.md" -Encoding UTF8


# ------------------------------------------------------------
# 7. DEVELOPMENT.md
# ------------------------------------------------------------

@'
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
'@ | Set-Content "docs\DEVELOPMENT.md" -Encoding UTF8


# ------------------------------------------------------------
# 8. SECURITY.md
# ------------------------------------------------------------

@'
# Project Security Rules

## Secrets

Never commit:

- Wi-Fi passwords
- API keys
- tokens
- private keys
- credentials

Real secret files must remain outside version control.

## Network Monitoring

The ESP32 Network Monitor defaults to passive Wi-Fi observation.

Features that actively interfere with networks must not be introduced
without explicit authorization and a controlled lab scope.

## Git

Always inspect changes before committing:

git diff

and after staging:

git diff --staged
'@ | Set-Content "docs\SECURITY.md" -Encoding UTF8


# ------------------------------------------------------------
# 9. Exemplo de credenciais
# ------------------------------------------------------------

@'
WIFI_SSID = "your_wifi_name"
WIFI_PASSWORD = "your_wifi_password"
'@ | Set-Content "firmware\esp32\wifi_secrets.example.py" -Encoding UTF8


# ------------------------------------------------------------
# 10. Regra para agentes
# ------------------------------------------------------------

@'
# Cybersecurity Box Project Rules

The canonical instructions for this repository are defined in:

AGENTS.md

Read AGENTS.md before modifying the project.

Also review:

- README.md
- ROADMAP.md
- docs/ARCHITECTURE.md
- docs/DEVELOPMENT.md
- docs/SECURITY.md

before making architectural changes.
'@ | Set-Content ".agents\rules\project.md" -Encoding UTF8


# ------------------------------------------------------------
# 11. Agente Embedded Developer
# ------------------------------------------------------------

@'
---
name: embedded-dev
description: Develops and maintains the ESP32 MicroPython firmware.
---

# Embedded Developer

Read AGENTS.md before doing any work.

Primary responsibilities:

- ESP32 MicroPython development
- Wi-Fi monitoring
- Device communication
- Logging
- Hardware-aware code

Before changing code:

1. Run git status.
2. Read relevant source files.
3. Understand the existing behavior.

Prefer small changes.

Do not perform destructive ESP32 operations without explicit approval.

After implementation:

1. Review git diff.
2. Explain what changed.
3. State whether hardware verification is required.
'@ | Set-Content ".agents\agents\embedded-dev\agent.md" -Encoding UTF8


# ------------------------------------------------------------
# 12. Agente Reviewer
# ------------------------------------------------------------

@'
---
name: reviewer
description: Reviews ESP32 MicroPython changes for correctness, security and maintainability.
---

# Code Reviewer

Read AGENTS.md before reviewing.

Review the current Git diff.

Focus on:

- MicroPython compatibility
- ESP32 memory limitations
- infinite loops
- blocking behavior
- error handling
- accidental credential exposure
- duplicated code
- regressions
- readability
- unnecessary complexity

Do not modify files unless explicitly requested.

Return:

1. Critical issues
2. Important issues
3. Suggestions
4. Whether the change is ready for hardware testing
'@ | Set-Content ".agents\agents\reviewer\agent.md" -Encoding UTF8


# ------------------------------------------------------------
# 13. Atualizar .gitignore
# ------------------------------------------------------------

$gitIgnoreRules = @(
    ".venv/",
    ".idea/",
    "**/__pycache__/",
    "*.pyc",
    ".mpy_cache/",
    "wifi_secrets.py",
    "**/wifi_secrets.py"
)

if (-not (Test-Path ".gitignore")) {
    New-Item -ItemType File ".gitignore" | Out-Null
}

$currentGitIgnore = Get-Content ".gitignore" -ErrorAction SilentlyContinue

foreach ($rule in $gitIgnoreRules) {
    if ($currentGitIgnore -notcontains $rule) {
        Add-Content ".gitignore" $rule
    }
}


# ------------------------------------------------------------
# Final
# ------------------------------------------------------------

Write-Host ""
Write-Host "========================================="
Write-Host " Estrutura criada com sucesso"
Write-Host "========================================="
Write-Host ""
Write-Host "Proximos comandos:"
Write-Host ""
Write-Host "git status"
Write-Host "git diff --stat"
Write-Host "git diff"
Write-Host ""
Write-Host "NAO faca commit antes de revisar as alteracoes."
Write-Host ""