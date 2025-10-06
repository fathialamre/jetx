import 'package:flutter/material.dart';
import 'package:jet/jet.dart';

/// Main layout page with tabs - Todos App
class TodosApp extends StatelessWidget {
  const TodosApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the tabs route for the todos app
    final tabsRoute = TabsRoute(
      path: '/app',
      name: 'main_layout',
      tabs: [
        // First Tab: Todos
        TabItem(
          name: 'todos',
          path: 'todos',
          label: 'Todos',
          icon: const Icon(Icons.list_outlined),
          selectedIcon: const Icon(Icons.list),
          initial: true,
          routes: [
            JetPage(name: '/app/todos', page: () => const TodosTabPage()),
            JetPage(
              name: '/app/todos/create',
              page: () => const CreateTodoPage(),
            ),
          ],
        ),
        // Second Tab: Settings
        TabItem(
          name: 'settings',
          path: 'settings',
          label: 'Settings',
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings),
          routes: [
            JetPage(name: '/app/settings', page: () => const SettingsTabPage()),
          ],
        ),
      ],
    );

    return JetTabsShell(
      tabsRoute: tabsRoute,
      onTabChanged: (oldIndex, newIndex) {
        debugPrint('Tab changed from $oldIndex to $newIndex');
      },
    );
  }
}

// ============================================================================
// Todos Tab (First Tab)
// ============================================================================

/// Todos tab page - displays list of todos
class TodosTabPage extends StatelessWidget {
  const TodosTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Todos'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.list_alt, size: 100, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Todos List',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Placeholder for todos list',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                context.router.pushNamed('/app/todos/create');
              },
              icon: const Icon(Icons.add),
              label: const Text('Create New Todo'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () {
                context.router.switchTab(name: 'settings');
              },
              icon: const Icon(Icons.settings),
              label: const Text('Go to Settings Tab'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Create Todo Page (Sub-page of Todos Tab)
// ============================================================================

/// Create todo page - form to create a new todo
class CreateTodoPage extends StatelessWidget {
  const CreateTodoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Todo'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.note_add, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text(
              'Create New Todo',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 32),

            // Placeholder for form fields
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Title', style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(height: 8),
                  Text('[ Input field placeholder ]'),
                  SizedBox(height: 16),
                  Text(
                    'Description',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text('[ Textarea placeholder ]'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            ElevatedButton(
              onPressed: () {
                // Navigate back to todos list
                Navigator.of(context).pop();
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Save Todo'),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Cancel'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================================
// Settings Tab (Second Tab)
// ============================================================================

/// Settings tab page - app settings
class SettingsTabPage extends StatelessWidget {
  const SettingsTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.settings, size: 100, color: Colors.deepPurple),
            const SizedBox(height: 24),
            const Text(
              'Settings',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Placeholder for settings options',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.symmetric(horizontal: 32),
              decoration: BoxDecoration(
                color: Colors.deepPurple.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.deepPurple.shade200),
              ),
              child: const Column(
                children: [
                  Text(
                    'Settings Options:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 12),
                  Text('• Theme'),
                  Text('• Notifications'),
                  Text('• Language'),
                  Text('• Privacy'),
                ],
              ),
            ),
            const SizedBox(height: 32),
            OutlinedButton.icon(
              onPressed: () {
                context.router.switchTab(name: 'todos');
              },
              icon: const Icon(Icons.list),
              label: const Text('Go to Todos Tab'),
            ),
          ],
        ),
      ),
    );
  }
}
