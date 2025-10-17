# Changelog

All notable changes to the JetX project will be documented in this file.

## [0.1.0-alpha] - 2025-01-27

### 🚀 Initial Alpha Release
First public release of JetX framework - a modern, actively maintained fork of GetX with enhanced reactive programming capabilities.

### ✨ Core Features
- **High-Performance State Management**: Reactive programming with automatic dependency tracking
- **Intelligent Dependency Injection**: Smart lifecycle management and automatic disposal
- **Comprehensive Navigation**: Advanced routing system with middleware support
- **HTTP & WebSocket Support**: Full-featured networking with JetConnect
- **Animation System**: Smooth transitions and custom animations
- **Internationalization**: Built-in i18n support with locale management
- **Theme Management**: Dynamic theming and responsive design utilities

### 🔧 Advanced Reactive Features
- **Computed Values**: Automatic derived state with `computed()` function that watches dependencies and recalculates when they change
- **Reactive Operators**: Functional operators including `map()`, `where()`, `distinct()`, `scan()`, and combine operators
- **Stream Integration**: Seamless binding of Dart Streams to reactive values with `listenToStream()`, `fromStream()`, and helper methods
- **RxList Reactivity**: Enhanced list reactivity with proper change propagation

### 🐛 Critical Bug Fixes
- **Computed Values**: Fixed critical bug where computed values were not updating when dependencies changed. The `_recompute()` method now properly updates the internal value using `super.value = newValue` instead of just adding to the stream.
- **JetListenable Stream Registration**: Fixed stream listener registration in `JetListenable` to properly trigger when `refresh()` is called. The `_streamListener` is now registered immediately when the stream controller is created.
- **RxList Reactivity**: RxList changes now properly propagate through computed values and reactive workers.

### 🎨 Complete Rebranding
- **Framework Identity**: Complete rebranding from "GetX" to "JetX" throughout the codebase
  - `Get*` classes renamed to `Jet*` (e.g., `GetNavigator` → `JetNavigator`)
  - `Get` global instance renamed to `Jet`
  - Log prefix changed from 'GETX' to 'JETX'
  - HTTP user-agent updated to 'jetx-client'

### 📚 Comprehensive Documentation
- **Advanced Features Guide**: Detailed documentation for reactive programming and advanced patterns
- **Quick Reference Guide**: Fast lookup for common operations and APIs
- **Working Examples**: Practical examples including `reactive_example.dart` demonstrating reactive features
- **Updated README**: Modern documentation with reactive features section
- **Code Examples**: All examples updated to use JetX naming conventions

### 🧪 Testing & Quality
- **Comprehensive Test Suite**: 100+ test cases covering all major functionality
- **Benchmarks**: Performance testing utilities
- **Code Quality**: Flutter lints integration and effective Dart practices

### 🔄 Migration Notes
- **BindingsBuilder**: Uncommented and made functional for easier dependency binding
- **Class Renames**: All major classes have been renamed for consistency:
  - `GetListenable` → `JetListenable`
  - `GetStatus` → `JetStatus`
  - `GetAnimatedBuilder` → `JetAnimatedBuilder`
  - `GetHttpClient` → `JetHttpClient`
  - `GetHttpException` → `JetHttpException`

## [Unreleased]

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
