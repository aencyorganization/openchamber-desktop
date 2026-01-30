# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-01-29

### Added
- Initial release
- Auto-detection of OpenChamber installation
- Smart port detection from process output
- Cross-platform support (Linux, macOS, Windows)
- Minimal black loading screen with elegant spinner
- Auto-cleanup of processes on exit
- AppImage build support for Linux
- Secure iframe container for OpenChamber
- Error handling with English messages

### Features
- Automatically starts OpenChamber if not running
- Detects port from stdout/stderr or by scanning common ports
- Kills all OpenChamber processes when app closes
- Works with OpenChamber installed via Bun, npm, or system package managers

## [Unreleased]

### Planned
- System tray integration
- Configurable port range
- Auto-update mechanism
- Better error reporting
