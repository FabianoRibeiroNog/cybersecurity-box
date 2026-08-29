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
