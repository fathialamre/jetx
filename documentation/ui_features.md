# UI Features

JetX provides powerful UI utilities for theming, dialogs, snackbars, bottom sheets, and context extensions. All without requiring context - use them from anywhere in your app!

---

## Table of Contents

- [Theming](#theming)
- [Dialogs](#dialogs)
- [Snackbars](#snackbars)
- [Bottom Sheets](#bottom-sheets)
- [Context Extensions](#context-extensions)
- [Complete Examples](#complete-examples)

---

## Theming

Switch themes dynamically without boilerplate. Perfect for dark mode, custom themes, and user preferences.

### Change Theme Dynamically

```dart
// Change to dark theme
Jet.changeTheme(ThemeData.dark());

// Change to light theme
Jet.changeTheme(ThemeData.light());

// Toggle between themes
Jet.changeTheme(Jet.isDarkMode ? ThemeData.light() : ThemeData.dark());

// Custom theme
Jet.changeTheme(ThemeData(
  primarySwatch: Colors.blue,
  brightness: Brightness.dark,
  // ... other theme properties
));
```

### Dark Mode Support

```dart
// Check if dark mode is active
if (Jet.isDarkMode) {
  // Dark mode is active
  print('Dark mode enabled');
}

// Toggle dark mode
void toggleDarkMode() {
  Jet.changeTheme(Jet.isDarkMode ? ThemeData.light() : ThemeData.dark());
}

// Reactive dark mode toggle
class ThemeController extends JetxController {
  final isDarkMode = false.obs;
  
  void toggleTheme() {
    isDarkMode.value = !isDarkMode.value;
    Jet.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
  }
}
```

### Access Current Theme

```dart
// Get current theme
final currentTheme = Jet.theme;

// Check theme properties
if (Jet.theme.brightness == Brightness.dark) {
  // Dark theme is active
}

// Use theme in widgets
class ThemedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Jet.theme.primaryColor,
      child: Text(
        'Themed Text',
        style: Jet.theme.textTheme.headline6,
      ),
    );
  }
}
```

### Complete Theming Example

```dart
class ThemeController extends JetxController {
  final isDarkMode = false.obs;
  
  @override
  void onInit() {
    super.onInit();
    // Load saved theme preference
    _loadThemePreference();
  }
  
  void _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final savedTheme = prefs.getBool('isDarkMode') ?? false;
    isDarkMode.value = savedTheme;
    Jet.changeTheme(savedTheme ? ThemeData.dark() : ThemeData.light());
  }
  
  void toggleTheme() async {
    isDarkMode.value = !isDarkMode.value;
    Jet.changeTheme(isDarkMode.value ? ThemeData.dark() : ThemeData.light());
    
    // Save preference
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDarkMode.value);
  }
}

// Usage in app
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      home: HomeScreen(),
    );
  }
}
```

---

## Dialogs

Show dialogs without context. Perfect for confirmations, alerts, and custom modals.

### Default Dialog

```dart
// Simple dialog
Jet.defaultDialog(
  title: 'Confirmation',
  middleText: 'Are you sure you want to delete this item?',
  onConfirm: () {
    // Handle confirmation
    Jet.back();
  },
  onCancel: () {
    // Handle cancellation
    Jet.back();
  },
);

// Dialog with custom button text
Jet.defaultDialog(
  title: 'Success',
  middleText: 'Operation completed successfully!',
  textConfirm: 'OK',
  textCancel: 'Cancel',
  onConfirm: () => Jet.back(),
);
```

### Custom Dialog

```dart
// Custom dialog widget
Jet.dialog(
  AlertDialog(
    title: Text('Custom Dialog'),
    content: Text('This is a custom dialog with your own widget.'),
    actions: [
      TextButton(
        onPressed: () => Jet.back(),
        child: Text('Close'),
      ),
    ],
  ),
);

// Dialog with form
Jet.dialog(
  AlertDialog(
    title: Text('Enter Name'),
    content: TextField(
      decoration: InputDecoration(hintText: 'Your name'),
    ),
    actions: [
      TextButton(
        onPressed: () => Jet.back(),
        child: Text('Cancel'),
      ),
      TextButton(
        onPressed: () {
          // Handle form submission
          Jet.back();
        },
        child: Text('Save'),
      ),
    ],
  ),
);
```

### Dialog with Results

```dart
// Show dialog and get result
final result = await Jet.dialog(
  AlertDialog(
    title: Text('Choose Option'),
    content: Text('What would you like to do?'),
    actions: [
      TextButton(
        onPressed: () => Jet.back(result: 'option1'),
        child: Text('Option 1'),
      ),
      TextButton(
        onPressed: () => Jet.back(result: 'option2'),
        child: Text('Option 2'),
      ),
    ],
  ),
);

// Handle result
if (result == 'option1') {
  print('User chose option 1');
} else if (result == 'option2') {
  print('User chose option 2');
}
```

### Complete Dialog Example

```dart
class DialogController extends JetxController {
  final name = ''.obs;
  final email = ''.obs;
  
  Future<void> showUserDialog() async {
    final result = await Jet.dialog(
      AlertDialog(
        title: Text('Add User'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              decoration: InputDecoration(
                labelText: 'Name',
                hintText: 'Enter name',
              ),
              onChanged: (value) => name.value = value,
            ),
            SizedBox(height: 16),
            TextField(
              decoration: InputDecoration(
                labelText: 'Email',
                hintText: 'Enter email',
              ),
              onChanged: (value) => email.value = value,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Jet.back(),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (name.value.isNotEmpty && email.value.isNotEmpty) {
                Jet.back(result: {'name': name.value, 'email': email.value});
              }
            },
            child: Text('Save'),
          ),
        ],
      ),
    );
    
    if (result != null) {
      print('User added: $result');
    }
  }
}
```

---

## Snackbars

Show snackbars without context. Great for notifications, feedback, and temporary messages.

### Basic Snackbar

```dart
// Simple snackbar
Jet.snackbar('Success', 'Operation completed successfully!');

// Snackbar with action
Jet.snackbar(
  'File Downloaded',
  'Your file has been downloaded successfully.',
  snackPosition: SnackPosition.BOTTOM,
  duration: Duration(seconds: 3),
  mainButton: TextButton(
    onPressed: () {
      // Handle action
    },
    child: Text('OPEN'),
  ),
);
```

### Customization Options

```dart
// Fully customized snackbar
Jet.snackbar(
  'Custom Snackbar',
  'This is a fully customized snackbar with all options.',
  icon: Icon(Icons.info, color: Colors.white),
  shouldIconPulse: true,
  barBlur: 20,
  backgroundColor: Colors.blue,
  colorText: Colors.white,
  duration: Duration(seconds: 4),
  snackPosition: SnackPosition.TOP,
  margin: EdgeInsets.all(16),
  borderRadius: 12,
  isDismissible: true,
  dismissDirection: DismissDirection.horizontal,
  forwardAnimationCurve: Curves.easeOutBack,
  reverseAnimationCurve: Curves.easeInBack,
  animationDuration: Duration(milliseconds: 600),
  onTap: (snack) {
    // Handle tap
  },
);
```

### Positioning

```dart
// Top snackbar
Jet.snackbar(
  'Top Message',
  'This appears at the top',
  snackPosition: SnackPosition.TOP,
);

// Bottom snackbar (default)
Jet.snackbar(
  'Bottom Message',
  'This appears at the bottom',
  snackPosition: SnackPosition.BOTTOM,
);
```

### Complete Snackbar Example

```dart
class NotificationController extends JetxController {
  void showSuccess(String message) {
    Jet.snackbar(
      'Success',
      message,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      icon: Icon(Icons.check_circle, color: Colors.white),
      snackPosition: SnackPosition.TOP,
    );
  }
  
  void showError(String message) {
    Jet.snackbar(
      'Error',
      message,
      backgroundColor: Colors.red,
      colorText: Colors.white,
      icon: Icon(Icons.error, color: Colors.white),
      snackPosition: SnackPosition.TOP,
      duration: Duration(seconds: 5),
    );
  }
  
  void showInfo(String message) {
    Jet.snackbar(
      'Info',
      message,
      backgroundColor: Colors.blue,
      colorText: Colors.white,
      icon: Icon(Icons.info, color: Colors.white),
    );
  }
  
  void showWarning(String message) {
    Jet.snackbar(
      'Warning',
      message,
      backgroundColor: Colors.orange,
      colorText: Colors.white,
      icon: Icon(Icons.warning, color: Colors.white),
    );
  }
}
```

---

## Bottom Sheets

Show bottom sheets without context. Perfect for menus, forms, and additional content.

### Basic Bottom Sheet

```dart
// Simple bottom sheet
Jet.bottomSheet(
  Container(
    padding: EdgeInsets.all(20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('Bottom Sheet Content'),
        SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => Jet.back(),
          child: Text('Close'),
        ),
      ],
    ),
  ),
);
```

### Customization

```dart
// Customized bottom sheet
Jet.bottomSheet(
  Container(
    padding: EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 40,
          height: 4,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        SizedBox(height: 20),
        Text(
          'Custom Bottom Sheet',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 20),
        Text('This is a customized bottom sheet with rounded corners.'),
        SizedBox(height: 20),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () => Jet.back(),
                child: Text('Cancel'),
              ),
            ),
            SizedBox(width: 10),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Handle action
                  Jet.back();
                },
                child: Text('Confirm'),
              ),
            ),
          ],
        ),
      ],
    ),
  ),
  backgroundColor: Colors.transparent,
  isScrollControlled: true,
  ignoreSafeArea: false,
);
```

### Complete Bottom Sheet Example

```dart
class MenuController extends JetxController {
  void showMenu() {
    Jet.bottomSheet(
      Container(
        padding: EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.home),
              title: Text('Home'),
              onTap: () {
                Jet.back();
                Jet.toNamed('/home');
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Jet.back();
                Jet.toNamed('/profile');
              },
            ),
            ListTile(
              leading: Icon(Icons.settings),
              title: Text('Settings'),
              onTap: () {
                Jet.back();
                Jet.toNamed('/settings');
              },
            ),
            ListTile(
              leading: Icon(Icons.help),
              title: Text('Help'),
              onTap: () {
                Jet.back();
                Jet.toNamed('/help');
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout, color: Colors.red),
              title: Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: () {
                Jet.back();
                _showLogoutConfirmation();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  void _showLogoutConfirmation() {
    Jet.defaultDialog(
      title: 'Logout',
      middleText: 'Are you sure you want to logout?',
      onConfirm: () {
        Jet.back();
        // Handle logout
      },
    );
  }
}
```

---

## Context Extensions

JetX provides powerful context extensions for screen dimensions, theme access, and responsive design.

### Screen Dimensions

```dart
class ResponsiveWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: context.width * 0.8,  // 80% of screen width
      height: context.height * 0.5, // 50% of screen height
      child: Text('Responsive Container'),
    );
  }
}

// Get specific dimensions
final screenWidth = context.width;
final screenHeight = context.height;
final statusBarHeight = context.statusBarHeight;
final bottomBarHeight = context.bottomBarHeight;
```

### Theme Access

```dart
class ThemedWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: context.theme.primaryColor,
      child: Text(
        'Themed Text',
        style: context.theme.textTheme.headline6?.copyWith(
          color: context.isDarkMode ? Colors.white : Colors.black,
        ),
      ),
    );
  }
}

// Check theme properties
if (context.isDarkMode) {
  // Dark mode is active
}

// Access theme data
final primaryColor = context.theme.primaryColor;
final textTheme = context.theme.textTheme;
```

### Responsive Values

```dart
class ResponsiveLayout extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Responsive text size
        Text(
          'Responsive Text',
          style: TextStyle(
            fontSize: context.responsiveValue<double>(
              mobile: 16,
              tablet: 20,
              desktop: 24,
            ),
          ),
        ),
        
        // Responsive padding
        Padding(
          padding: EdgeInsets.all(
            context.responsiveValue<double>(
              mobile: 16,
              tablet: 24,
              desktop: 32,
            ),
          ),
          child: Text('Responsive Padding'),
        ),
        
        // Responsive grid columns
        GridView.count(
          crossAxisCount: context.responsiveValue<int>(
            mobile: 2,
            tablet: 3,
            desktop: 4,
          ),
          children: List.generate(8, (index) => Container()),
        ),
      ],
    );
  }
}
```

### Platform Detection

```dart
class PlatformWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (JetPlatform.isMobile)
          Text('Mobile Layout'),
        
        if (JetPlatform.isTablet)
          Text('Tablet Layout'),
        
        if (JetPlatform.isDesktop)
          Text('Desktop Layout'),
        
        if (JetPlatform.isWeb)
          Text('Web Layout'),
        
        if (JetPlatform.isAndroid)
          Text('Android Specific'),
        
        if (JetPlatform.isIOS)
          Text('iOS Specific'),
      ],
    );
  }
}
```

### Complete Context Extensions Example

```dart
class ResponsiveController extends JetxController {
  void showResponsiveDialog() {
    Jet.dialog(
      AlertDialog(
        title: Text('Responsive Dialog'),
        content: Container(
          width: context.width * 0.8,
          height: context.height * 0.3,
          child: Column(
            children: [
              Text('This dialog adapts to screen size'),
              SizedBox(height: 20),
              Text(
                'Screen: ${context.width.toInt()}x${context.height.toInt()}',
                style: context.theme.textTheme.caption,
              ),
              Text(
                'Platform: ${JetPlatform.isMobile ? 'Mobile' : 'Desktop'}',
                style: context.theme.textTheme.caption,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Jet.back(),
            child: Text('Close'),
          ),
        ],
      ),
    );
  }
}
```

---

## Complete Examples

### Theme Toggle App

```dart
class ThemeToggleApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return JetMaterialApp(
      home: ThemeToggleScreen(),
    );
  }
}

class ThemeToggleScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.put(ThemeController());
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Theme Toggle'),
        actions: [
          Obx(() => IconButton(
            icon: Icon(controller.isDarkMode.value 
              ? Icons.light_mode 
              : Icons.dark_mode),
            onPressed: controller.toggleTheme,
          )),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Theme',
              style: context.theme.textTheme.headline4,
            ),
            SizedBox(height: 20),
            Obx(() => Text(
              controller.isDarkMode.value ? 'Dark Mode' : 'Light Mode',
              style: context.theme.textTheme.headline6,
            )),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: controller.toggleTheme,
              child: Text('Toggle Theme'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Notification System

```dart
class NotificationSystem extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final controller = Jet.put(NotificationController());
    
    return Scaffold(
      appBar: AppBar(title: Text('Notifications')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => controller.showSuccess('Operation successful!'),
              child: Text('Show Success'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.showError('Something went wrong!'),
              child: Text('Show Error'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.showInfo('Here is some information'),
              child: Text('Show Info'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => controller.showWarning('Please be careful'),
              child: Text('Show Warning'),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## Learn More

- **[State Management](./state_management.md)** - Reactive state management
- **[Route Management](./route_management.md)** - Navigation without context
- **[Quick Reference](./quick_reference.md)** - Fast lookup for all features
- **[What's New in JetX](./whats_new_in_jetx.md)** - New features and improvements

---

**Ready to build beautiful UIs with JetX?** [Get started →](../README.md#quick-start)
