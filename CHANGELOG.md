# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [2.0.0] - 2024-01-06

### Added
- Support for MyMLH API v4
- Refresh token support via `offline_access` scope
- Expandable fields support in API requests
- Enhanced error handling with detailed error messages
- New granular scopes:
  - `user:read:profile`
  - `user:read:email`
  - `user:read:demographics`
  - `user:read:education`
  - `user:read:employment`

### Changed
- **BREAKING**: Minimum Ruby version requirement increased to 3.2.0
- **BREAKING**: Updated scope format to match v4 API (e.g., `user:read:profile` instead of `default`)
- **BREAKING**: Changed user data endpoint from `/api/v3/user.json` to `/v4/users/me`
- **BREAKING**: Updated user data structure to match v4 API response format
- Updated development dependencies to latest stable versions
- Enhanced test coverage for v4 API features

### Removed
- **BREAKING**: Removed support for v3 API scopes
- **BREAKING**: Removed support for Ruby versions below 3.2.0

### Fixed
- Improved error handling for API request failures
- Updated documentation to reflect v4 API changes

### Security
- Updated minimum Ruby version to ensure security patches
- Updated all dependencies to their latest secure versions

[2.0.0]: https://github.com/MLH/omniauth-mlh/compare/v1.0.1...v2.0.0
