## [0.1.0-alpha.5] - Unreleased

### 🐛 Bug Fixes

#### Critical Navigation Fixes
- **Fixed `closeAllDialogsAndBottomSheets()` logic bug**: Changed AND operator to OR operator, preventing dialogs and bottom sheets from getting stuck open
- **Added null-safety checks to `back()` method**: Prevents crashes when navigator state is null
- **Improved `closeOverlay()` validation**: Now properly validates navigator state and checks if pop is possible before attempting to close

#### Memory Leak Fixes
- **Enhanced ScrollMixin disposal**: Added disposal tracking flag and safe guards against accessing disposed scroll controllers
- **Strengthened JetLifeCycleMixin**: Added assertions to prevent double-initialization and double-disposal, with error handling for cleanup failures
- **Refactored `delete()` method complexity**: Simplified isDirty/lateRemove logic into clear, maintainable helper methods with better error messages

### ⚡ Performance Improvements

#### Reactive System Optimization
- **Added custom equality comparator to Rx**: New optional `equals` function allows custom value comparison for complex objects
- **Optimized firstRebuild logic**: Clarified and improved the first rebuild behavior for better performance
- **Made `_firstRebuild` flag private**: Better encapsulation and fixed reference in trigger method

### 🧪 Testing

- **Added comprehensive memory leak tests**: 15+ test cases covering controller lifecycle, disposal, services, permanent instances, tagged instances, and bulk operations
- **Added extensive navigation tests**: 20+ test cases covering basic navigation, dialogs, bottom sheets, mixed overlays, navigation safety, and named routes

### 📚 Documentation

- **Massively expanded SmartManagement documentation**: Added 270+ lines of comprehensive documentation including:
  - Detailed explanation of all three modes (full, onlyBuilder, keepFactory)
  - Real-world examples for each mode
  - Comparison table
  - Common patterns and best practices
  - Troubleshooting guide
  - Clear when-to-use guidance

### 🔧 Code Quality

- **Improved error messages**: Better error messages in delete operations with actionable guidance
- **Added lifecycle error handling**: Cleanup errors are now caught and logged instead of blocking disposal
- **Better code organization**: Split complex methods into focused, single-responsibility functions

---

## [0.1.0-alpha.4]

- Initial alpha release of JetX
- JetX is a fork from GetX
- High-performance state management
- Intelligent dependency injection
- Route management
- Reactive programming with .obs
- Context-free navigation
- Smart memory management
- Cross-platform support (Android, iOS, Web, Mac, Linux, Windows)