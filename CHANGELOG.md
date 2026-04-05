# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- CI pipeline using Forgejo Actions
- Edge case tests for multiple honeypots, corrupted sessions, and invalid
  signals
- Security documentation for session handling, timing checks, and CSRF
  compatibility

### Fixed

- Integer division in human rating calculation returning 0 instead of a float
- Signal parse failures silently dispatching to the wrong method override due
  to Int/Float type mismatch
- Unsafe `to_i64` call on session values that could raise on corrupted data

## [0.6.0] - 2026-03-23

### Added

- Focus signal detection (`focusin` event)

## [0.5.0] - 2026-02-06

### Changed

- Signal JSON keys made more readable

## [0.4.0] - 2026-01-13

### Added

- Signals input name configuration option
- Signals object with JSON serialization
- Signals pipe for automatic evaluation
- Signals tags with custom name and attributes
- `human_rating` class method on `Signals`

## [0.3.0] - 2025-12-15

### Added

- Configurable submission delay (`default_delay` setting)
- Option to disable delay entirely (`disable_delay` setting)

## [0.2.0] - 2025-11-28

### Fixed

- Bug with successive honeypot rejection attempts not resetting timestamp

## [0.1.0] - 2025-11-20

### Added

- Invisible honeypot input tag with configurable attributes
- Timing-based bot detection using session timestamps
- Custom HTTP response handling via block
- Support for multiple honeypots per action

[Unreleased]: https://codeberg.org/fluck/lucky_honeypot/compare/v0.6.0...HEAD
[0.6.0]: https://codeberg.org/fluck/lucky_honeypot/compare/v0.5.0...v0.6.0
[0.5.0]: https://codeberg.org/fluck/lucky_honeypot/compare/v0.4.0...v0.5.0
[0.4.0]: https://codeberg.org/fluck/lucky_honeypot/compare/v0.3.0...v0.4.0
[0.3.0]: https://codeberg.org/fluck/lucky_honeypot/compare/v0.2.0...v0.3.0
[0.2.0]: https://codeberg.org/fluck/lucky_honeypot/compare/v0.1.0...v0.2.0
[0.1.0]: https://codeberg.org/fluck/lucky_honeypot/releases/tag/v0.1.0
