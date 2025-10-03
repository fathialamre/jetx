# JetX Refactor Quick Reference Guide

## 🎯 Quick Navigation

- [File Deletion Commands](#file-deletion-commands)
- [Rename Commands](#rename-commands)
- [Search and Replace Patterns](#search-and-replace-patterns)
- [Test Commands](#test-commands)
- [Verification Commands](#verification-commands)
- [Common Issues & Solutions](#common-issues--solutions)

---

## 📁 File Deletion Commands

### Phase 1: Safe Deletions

```bash
cd /Users/alamre/dev/2030/jetx

# 1. Remove multi-language README files
rm README-ar.md README-bn.md README-es.md README-fr.md README-hi.md \
   README-vi.md README.id-ID.md README.ja-JP.md README.ko-kr.md \
   README.pl.md README.pt-br.md README.ru.md README.tr-TR.md \
   README.ur-PK.md README.zh-cn.md

# 2. Remove multi-language documentation (keep only en_US)
rm -rf documentation/ar_EG documentation/es_ES documentation/fr_FR \
       documentation/id_ID documentation/ja_JP documentation/kr_KO \
       documentation/pt_BR documentation/ru_RU documentation/tr_TR \
       documentation/vi_VI documentation/zh_CN

# 3. Remove Jekyll config
rm _config.yml

# 4. Remove example_nav2 (CAUTION: Review lib/ folder first!)
# First, extract any unique examples:
# cp -r example_nav2/lib/app/unique_example example/lib/
# Then remove:
rm -rf example_nav2

# 5. Commit phase 1 changes
git add -A
git commit -m "Phase 1: Remove unused documentation and example scaffolding"
```

### Optional: Remove GetConnect Module

```bash
# ONLY if decided to remove GetConnect
rm -rf lib/get_connect
rm lib/get_connect.dart

# Update exports in lib/get.dart (remove GetConnect export line)

git add -A
git commit -m "Remove GetConnect module"
```

---

## 🔄 Rename Commands

### Phase 2: Directory Renaming

```bash
cd /Users/alamre/dev/2030/jetx

# Rename all get_* directories to jet_*
mv lib/get_animations lib/jet_animations
mv lib/get_common lib/jet_common
mv lib/get_core lib/jet_core
mv lib/get_instance lib/jet_instance
mv lib/get_navigation lib/jet_navigation
mv lib/get_rx lib/jet_rx
mv lib/get_state_manager lib/jet_state_manager
mv lib/get_utils lib/jet_utils

# Rename main library file
mv lib/get.dart lib/jet.dart

# If keeping GetConnect:
mv lib/get_connect lib/jet_connect
mv lib/get_connect.dart lib/jet_connect.dart

# Commit
git add -A
git commit -m "Phase 2: Rename directories from get_* to jet_*"
```

---

## 🔍 Search and Replace Patterns

### Phase 2: Update Internal Imports

**IMPORTANT**: Review each change manually or in batches!

```bash
# Update import statements in Dart files
# Replace: import 'package:get/ → import 'package:jetx/
find lib -type f -name "*.dart" -exec sed -i '' "s/package:get\//package:jetx\//g" {} +

# Update directory references in imports
# get_core → jet_core
find lib -type f -name "*.dart" -exec sed -i '' "s/get_core/jet_core/g" {} +

# get_rx → jet_rx
find lib -type f -name "*.dart" -exec sed -i '' "s/get_rx/jet_rx/g" {} +

# get_state_manager → jet_state_manager
find lib -type f -name "*.dart" -exec sed -i '' "s/get_state_manager/jet_state_manager/g" {} +

# get_instance → jet_instance
find lib -type f -name "*.dart" -exec sed -i '' "s/get_instance/jet_instance/g" {} +

# get_navigation → jet_navigation
find lib -type f -name "*.dart" -exec sed -i '' "s/get_navigation/jet_navigation/g" {} +

# get_utils → jet_utils
find lib -type f -name "*.dart" -exec sed -i '' "s/get_utils/jet_utils/g" {} +

# get_common → jet_common
find lib -type f -name "*.dart" -exec sed -i '' "s/get_common/jet_common/g" {} +

# get_animations → jet_animations (if keeping)
find lib -type f -name "*.dart" -exec sed -i '' "s/get_animations/jet_animations/g" {} +

# get_connect → jet_connect (if keeping)
find lib -type f -name "*.dart" -exec sed -i '' "s/get_connect/jet_connect/g" {} +

# Commit after testing
flutter test
git add -A
git commit -m "Phase 2: Update all import statements"
```

---

### Phase 3: Class and API Renaming

**⚠️ CAUTION**: These are high-impact changes. Test thoroughly!

#### Strategy 1: Manual (Recommended)
Use VS Code or Android Studio's "Rename Symbol" feature for each class.

#### Strategy 2: Scripted (Use with extreme caution)
```bash
# Create a backup first!
git checkout -b refactor-backup
git checkout main

# Main API class: Get → Jet
# This is the most critical change
find lib -type f -name "*.dart" -exec sed -i '' 's/\bGet\b/Jet/g' {} +

# Note: This will also rename GetBuilder, GetxController, etc.
# So we need to be more precise:

# Undo the above if needed:
git checkout lib

# More precise approach (use Perl for word boundaries):
# Get.to( → Jet.to(
find lib -type f -name "*.dart" -exec perl -pi -e 's/\bGet\./Jet./g' {} +

# Get.find< → Jet.find<
# (Already covered above)

# Test after each batch
flutter test
```

#### Class Renames (Manual recommended)

```
FIND                    REPLACE WITH           PRIORITY
-----------------------------------------------------------
GetMaterialApp          JetMaterialApp         High
GetCupertinoApp         JetCupertinoApp        High
GetxController          JetController          High
GetBuilder              JetBuilder             High
GetX                    JetX                   High (widget name)
GetView                 JetView                High
GetWidget               JetWidget              Medium
GetxService             JetService             Medium
GetPage                 JetPage                High
GetMiddleware           JetMiddleware          Medium
GetPlatform             JetPlatform            Medium
GetUtils                JetUtils               Low (rarely used directly)
GetConnect              JetConnect             Medium (if keeping)
GetResponsiveView       JetResponsiveView      Low
GetObserver             JetObserver            Low
GetRoute                JetRoute               Low
GetPageRoute            JetPageRoute           Low
```

---

## 🧪 Test Commands

### After Every Major Change

```bash
# 1. Run all tests
flutter test

# 2. Run tests with coverage
flutter test --coverage

# 3. View coverage (requires genhtml)
genhtml coverage/lcov.info -o coverage/html
open coverage/html/index.html  # macOS
# xdg-open coverage/html/index.html  # Linux

# 4. Run analyzer
flutter analyze

# 5. Check for lints
dart analyze

# 6. Run example app
cd example
flutter run -d chrome  # or macos, etc.
cd ..

# 7. Dry run publish (checks package structure)
flutter pub publish --dry-run
```

---

## ✅ Verification Commands

### Check Import Consistency

```bash
# Find any remaining 'package:get/' imports (should be 'package:jetx/')
grep -r "package:get/" lib/

# Find any remaining 'get_' directory references
grep -r "get_core\|get_rx\|get_state" lib/

# Find remaining 'Get' class references (be careful, will find GetBuilder etc.)
grep -rn "\bGet\." lib/ | grep -v "JetBuilder\|JetView"
```

### Verify Exports

```bash
# Check main export file
cat lib/jet.dart

# Should export:
# - jet_animations/index.dart
# - jet_common/...
# - jet_core/...
# - jet_instance/...
# - jet_navigation/...
# - jet_rx/...
# - jet_state_manager/...
# - jet_utils/...
```

### Check Example App

```bash
cd example

# Should import jetx, not get
grep -r "package:get/" lib/
# (Should return nothing)

grep -r "package:jetx/" lib/
# (Should find all imports)

# Check for old class names
grep -r "GetMaterialApp\|GetBuilder\|GetxController" lib/
# (Should return nothing if fully migrated)

cd ..
```

---

## 🔧 Common Issues & Solutions

### Issue 1: Import Errors After Renaming

**Error**: `Target of URI doesn't exist: 'package:get/get.dart'`

**Solution**:
```bash
# Update pubspec.yaml in example/
cd example
# Change: get: in dependencies
# To:     jetx: 
#           path: ../

flutter pub get
cd ..
```

### Issue 2: Class Not Found

**Error**: `Undefined class 'GetBuilder'`

**Solution**:
- Search for old class name: `grep -r "GetBuilder" lib/`
- Replace with new name: `JetBuilder`
- Or ensure proper export in `lib/jet.dart`

### Issue 3: Circular Dependencies

**Error**: `Circular dependency between...`

**Solution**:
- Check import paths carefully
- Ensure relative imports are correct after directory rename
- Example: `import '../jet_core/...'` instead of `import '../get_core/...'`

### Issue 4: Tests Failing

**Error**: Tests fail after rename

**Solution**:
```bash
# Update test files
find test -type f -name "*.dart" -exec sed -i '' "s/package:get\//package:jetx\//g" {} +
find test -type f -name "*.dart" -exec sed -i '' "s/GetBuilder/JetBuilder/g" {} +
# ... etc for other classes

# Run tests again
flutter test
```

### Issue 5: Analyzer Warnings

**Warning**: `Unused import`

**Solution**:
```bash
# Remove unused imports automatically
dart fix --apply

# Or manually review and remove
```

---

## 📋 Pre-Commit Checklist

Before committing each phase:

- [ ] All tests pass (`flutter test`)
- [ ] No analyzer errors (`flutter analyze`)
- [ ] Example app runs (`cd example && flutter run`)
- [ ] No import errors
- [ ] Code formatted (`dart format .`)
- [ ] Git status reviewed (`git status`)
- [ ] Changes reviewed (`git diff`)
- [ ] Commit message is clear

---

## 🚀 Quick Command Reference

### Full Refactor in One Go (⚠️ RISKY!)

**NOT RECOMMENDED**: Better to do phases separately

```bash
#!/bin/bash
# DANGER: This will make many changes at once!
# Only use if you know what you're doing and have backups!

set -e  # Exit on error

echo "⚠️  WARNING: This will modify many files!"
echo "Make sure you have committed all changes first."
read -p "Continue? (y/N) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    exit 1
fi

cd /Users/alamre/dev/2030/jetx

# Phase 1: Deletions
echo "Phase 1: Removing files..."
rm -f README-*.md _config.yml
rm -rf documentation/{ar_EG,es_ES,fr_FR,id_ID,ja_JP,kr_KO,pt_BR,ru_RU,tr_TR,vi_VI,zh_CN}
rm -rf example_nav2

git add -A
git commit -m "Phase 1: Remove unused files"

# Phase 2: Directory renames
echo "Phase 2: Renaming directories..."
for dir in animations common core instance navigation rx state_manager utils; do
    if [ -d "lib/get_$dir" ]; then
        mv "lib/get_$dir" "lib/jet_$dir"
    fi
done
mv lib/get.dart lib/jet.dart

# Update imports
echo "Updating imports..."
find lib -name "*.dart" -exec sed -i '' 's/get_/jet_/g' {} +
find lib -name "*.dart" -exec sed -i '' 's/package:get\//package:jetx\//g' {} +

git add -A
git commit -m "Phase 2: Rename directories and update imports"

# Run tests
echo "Running tests..."
flutter test

echo "✅ Phases 1-2 complete. Review changes before proceeding to Phase 3."
```

---

## 📞 Support Commands

### Generate File List

```bash
# List all Dart files
find lib -name "*.dart" > dart_files.txt

# Count files
find lib -name "*.dart" | wc -l

# List by directory
find lib -type d | while read dir; do
    count=$(find "$dir" -maxdepth 1 -name "*.dart" | wc -l)
    echo "$count files in $dir"
done
```

### Find Large Files

```bash
# Find largest Dart files
find lib -name "*.dart" -exec wc -l {} + | sort -rn | head -20
```

### Git Helpers

```bash
# Create checkpoint
git tag checkpoint-phase-1

# View changes since checkpoint  
git diff checkpoint-phase-1

# Revert to checkpoint (DANGER!)
git reset --hard checkpoint-phase-1

# Create branch for testing
git checkout -b test-refactor
# Do refactor changes
# If successful:
git checkout main
git merge test-refactor
# If failed:
git checkout main
git branch -D test-refactor
```

---

## 🎨 Editor Setup

### VS Code

**Recommended Extensions**:
- Dart
- Flutter
- Better Comments
- GitLens

**Settings** (`.vscode/settings.json`):
```json
{
  "dart.lineLength": 80,
  "editor.formatOnSave": true,
  "dart.renameFilesWithClasses": "always",
  "search.exclude": {
    "**/coverage": true,
    "**/.dart_tool": true
  }
}
```

### Mass Rename in VS Code:
1. Press `F2` on class name
2. Type new name
3. Press Enter
4. Review changes in diff view

---

## 📊 Progress Tracking

### Phase Progress Template

```markdown
## Refactor Progress

### Phase 1: Cleanup ✅ COMPLETE
- [x] Remove multi-language READMEs
- [x] Remove documentation folders
- [x] Remove _config.yml
- [x] Remove example_nav2
- [x] Tests passing

### Phase 2: Directory Rename ⏳ IN PROGRESS
- [x] Rename lib/get_core → lib/jet_core
- [x] Rename lib/get_rx → lib/jet_rx
- [ ] Rename lib/get_state_manager → lib/jet_state_manager
- [ ] Update all imports
- [ ] Tests passing

### Phase 3: Class Rename 📅 NOT STARTED
- [ ] Get → Jet
- [ ] GetBuilder → JetBuilder
- [ ] GetxController → JetController
- [ ] Tests passing

### Phase 4: Documentation 📅 NOT STARTED
- [ ] Update README.md
- [ ] Create MIGRATION.md
- [ ] Update CHANGELOG.md

### Phase 5: Publishing 📅 NOT STARTED
- [ ] Final tests
- [ ] Publish dry-run
- [ ] Tag v1.0.0
```

---

## 🆘 Emergency Rollback

If something goes terribly wrong:

```bash
# View recent commits
git log --oneline -10

# Revert last commit (keeps changes)
git reset --soft HEAD~1

# Revert last commit (discards changes) ⚠️ DANGER!
git reset --hard HEAD~1

# Revert multiple commits
git reset --hard HEAD~3

# If pushed to remote (creates new commit)
git revert HEAD

# Nuclear option: reset to origin
git fetch origin
git reset --hard origin/main
```

---

**Document Version**: 1.0  
**Last Updated**: 2024  
**Quick Reference**: Always keep this handy during refactor!

