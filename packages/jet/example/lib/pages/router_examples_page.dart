import 'package:flutter/material.dart';
import 'package:jet/jet_router.dart';

class RouterExamplesPage extends StatelessWidget {
  const RouterExamplesPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jet Router Examples'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Jet Router Navigation Examples',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Explore different navigation patterns and features',
                style: TextStyle(fontSize: 16, color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              _buildExampleCard(
                context,
                title: '1. Normal Push Navigation',
                description: 'Basic push navigation with back button',
                icon: Icons.navigation,
                onTap: () => context.router.push('/push-example'),
              ),
              const SizedBox(height: 16),
              _buildExampleCard(
                context,
                title: '2. Path Parameters',
                description: 'Navigate with path parameters (e.g., /user/:id)',
                icon: Icons.link,
                onTap: () => context.router.push('/params-example'),
              ),
              const SizedBox(height: 16),
              _buildExampleCard(
                context,
                title: '3. Query Parameters & Arguments',
                description: 'Pass data via query params and arguments',
                icon: Icons.data_object,
                onTap: () =>
                    context.router.push('/params-example?name=John&age=25'),
              ),
              const SizedBox(height: 16),
              _buildExampleCard(
                context,
                title: '4. Replace Navigation',
                description: 'Replace current route instead of pushing',
                icon: Icons.swap_horiz,
                onTap: () => context.router.push('/replace-example'),
              ),
              const SizedBox(height: 16),
              _buildExampleCard(
                context,
                title: '5. Return Results',
                description: 'Push routes and await results (like go_router)',
                icon: Icons.assignment_return,
                onTap: () => context.router.push('/result-example'),
                highlighted: true,
              ),
              const SizedBox(height: 16),
              _buildExampleCard(
                context,
                title: '6. Route Guards',
                description: 'Protected routes with authentication guards',
                icon: Icons.security,
                onTap: () => context.router.push('/protected'),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info, color: Colors.blue.shade700),
                        const SizedBox(width: 8),
                        Text(
                          'Navigation Stack Info',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue.shade700,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Current stack depth: ${_getStackDepth(context)}',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                    Text(
                      'Can pop: ${context.router.canPop()}',
                      style: TextStyle(color: Colors.blue.shade600),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExampleCard(
    BuildContext context, {
    required String title,
    required String description,
    required IconData icon,
    required VoidCallback onTap,
    bool highlighted = false,
  }) {
    return Card(
      elevation: highlighted ? 4 : 2,
      color: highlighted ? Colors.green.shade50 : null,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: highlighted
                      ? Colors.green.shade100
                      : Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: highlighted
                      ? Colors.green.shade700
                      : Theme.of(context).colorScheme.onPrimaryContainer,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        if (highlighted)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'NEW',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }

  int _getStackDepth(BuildContext context) {
    // This is a simplified way to show stack depth
    // In a real app, you might want to track this more accurately
    return 1; // We're on the home page
  }
}
