# Changelog

All notable changes to the JetX project will be documented in this file.

## [Unreleased]

### Fixed
- **Computed Values**: Fixed critical bug where computed values were not updating when dependencies changed. The `_recompute()` method now properly updates the internal value using `super.value = newValue` instead of just adding to the stream.
- **JetListenable Stream Registration**: Fixed stream listener registration in `JetListenable` to properly trigger when `refresh()` is called. The `_streamListener` is now registered immediately when the stream controller is created.
- **RxList Reactivity**: RxList changes now properly propagate through computed values and reactive workers.

### Added
- **Computed Values**: Automatic derived state with `computed()` function that watches dependencies and recalculates when they change
- **Reactive Operators**: Functional operators including `map()`, `where()`, `distinct()`, `scan()`, and combine operators
- **Stream Integration**: Seamless binding of Dart Streams to reactive values with `listenToStream()`, `fromStream()`, and helper methods
- **Comprehensive Documentation**: Added detailed guides for advanced features, quick reference, and best practices
- **Working Examples**: Added `reactive_example.dart` demonstrating reactive features

### Changed
- **Branding**: Complete rebranding from "GetX" to "JetX" throughout the codebase
  - `Get*` classes renamed to `Jet*` (e.g., `GetNavigator` → `JetNavigator`)
  - `Get` global instance renamed to `Jet`
  - Log prefix changed from 'GETX' to 'JETX'
  - HTTP user-agent updated to 'jetx-client'
- **Class Renames**: 
  - `GetListenable` → `JetListenable`
  - `GetStatus` → `JetStatus`
  - `GetAnimatedBuilder` → `JetAnimatedBuilder`
  - `GetHttpClient` → `JetHttpClient`
  - `GetHttpException` → `JetHttpException`
  - And many more for consistent branding
- **BindingsBuilder**: Uncommented and made functional for easier dependency binding

### Documentation
- Updated README.md with modern reactive features section
- Added comprehensive Advanced Features Guide
- Added Quick Reference Guide
- Updated all code examples to use JetX naming
- Added practical notes and tips throughout documentation

## [1.0.0] - Initial Release

Initial release of JetX as a maintained fork of GetX with enhanced features and modern Flutter practices.

### Core Features
- High-performance state management
- Intelligent dependency injection  
- Intuitive route management
- Internationalization support
- Theme management
- HTTP & WebSocket support (JetConnect)
- Middleware system
- Local state widgets
- Full lifecycle management
- Testing utilities

---

**Legend:**
- `Added` - New features
- `Changed` - Changes in existing functionality
- `Deprecated` - Soon-to-be removed features
- `Removed` - Removed features
- `Fixed` - Bug fixes
- `Security` - Security improvements
