import 'package:flutter/material.dart';
import 'package:jet/jet_router.dart';

/// Example page demonstrating route result handling
class ResultExamplePage extends StatefulWidget {
  const ResultExamplePage({super.key});

  @override
  State<ResultExamplePage> createState() => _ResultExamplePageState();
}

class _ResultExamplePageState extends State<ResultExamplePage> {
  String? _lastResult;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Return Results Example'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Route Result Handling',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Like go_router and auto_route, you can await results from routes.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),

            // Display last result
            if (_lastResult != null) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.green),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.green),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Last result: $_lastResult',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
            ],

            // Example 1: String result
            Card(
              child: ListTile(
                leading: const Icon(Icons.text_fields, color: Colors.blue),
                title: const Text('String Result'),
                subtitle: const Text('Navigate and return a string'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final result = await context.router.push<String>(
                    '/result-dialog?type=string',
                  );
                  if (result != null && mounted) {
                    setState(() => _lastResult = result);
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Example 2: Boolean result (confirmation)
            Card(
              child: ListTile(
                leading: const Icon(Icons.check_box, color: Colors.orange),
                title: const Text('Boolean Result'),
                subtitle: const Text('Confirmation dialog'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final confirmed = await context.router.push<bool>(
                    '/result-dialog?type=bool',
                  );
                  if (mounted) {
                    setState(() {
                      _lastResult = confirmed == true
                          ? 'Confirmed!'
                          : 'Cancelled';
                    });
                  }
                },
              ),
            ),
            const SizedBox(height: 12),

            // Example 3: Complex object result
            Card(
              child: ListTile(
                leading: const Icon(Icons.data_object, color: Colors.purple),
                title: const Text('Complex Object'),
                subtitle: const Text('Return a Map with data'),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () async {
                  final result = await context.router
                      .push<Map<String, dynamic>>('/result-dialog?type=map');
                  if (result != null && mounted) {
                    setState(() => _lastResult = result.toString());
                  }
                },
              ),
            ),
            const SizedBox(height: 32),

            // Code example
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Example Code:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'final result = await context.router.push<String>(\'/page\');\n'
                    'if (result != null) {\n'
                    '  print(\'Got: \$result\');\n'
                    '}\n\n'
                    '// In the pushed route:\n'
                    'context.router.pop(\'my_result\');',
                    style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Dialog page that returns different types of results
class ResultDialogPage extends StatelessWidget {
  const ResultDialogPage({super.key});

  @override
  Widget build(BuildContext context) {
    final type = context.router.queryParam('type') ?? 'string';

    return Scaffold(
      appBar: AppBar(
        title: Text('Return ${type.toUpperCase()}'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getIconForType(type),
              size: 64,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 24),
            Text(
              'Choose a value to return',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 32),

            if (type == 'string') ...[
              _buildButton(
                context,
                'Return "Success"',
                () => context.router.pop('Success'),
              ),
              const SizedBox(height: 12),
              _buildButton(
                context,
                'Return "User Updated"',
                () => context.router.pop('User Updated'),
              ),
              const SizedBox(height: 12),
              _buildButton(
                context,
                'Return "Hello World"',
                () => context.router.pop('Hello World'),
              ),
            ] else if (type == 'bool') ...[
              _buildButton(
                context,
                'Confirm (true)',
                () => context.router.pop(true),
                color: Colors.green,
              ),
              const SizedBox(height: 12),
              _buildButton(
                context,
                'Cancel (false)',
                () => context.router.pop(false),
                color: Colors.red,
              ),
            ] else if (type == 'map') ...[
              _buildButton(
                context,
                'Return User Data',
                () => context.router.pop({
                  'name': 'John Doe',
                  'age': 30,
                  'email': 'john@example.com',
                }),
              ),
              const SizedBox(height: 12),
              _buildButton(
                context,
                'Return Settings',
                () => context.router.pop({
                  'darkMode': true,
                  'notifications': false,
                  'language': 'en',
                }),
              ),
            ],

            const SizedBox(height: 24),
            OutlinedButton(
              onPressed: () => context.router.pop(),
              child: const Text('Cancel (return null)'),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'string':
        return Icons.text_fields;
      case 'bool':
        return Icons.check_box;
      case 'map':
        return Icons.data_object;
      default:
        return Icons.help;
    }
  }

  Widget _buildButton(
    BuildContext context,
    String label,
    VoidCallback onPressed, {
    Color? color,
  }) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          padding: const EdgeInsets.all(16),
        ),
        child: Text(label),
      ),
    );
  }
}
