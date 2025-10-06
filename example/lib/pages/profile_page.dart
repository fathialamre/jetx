import 'package:flutter/material.dart';
import 'package:jet/jet.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Get route arguments from current page configuration
    final currentPage = context.router.state.currentPage;
    final arguments = currentPage?.arguments;
    final parameters = currentPage?.parameters ?? {};

    // Extract data from arguments
    String? userName;
    String? userEmail;
    int? userId;

    if (arguments is Map<String, dynamic>) {
      userName = arguments['name'] as String?;
      userEmail = arguments['email'] as String?;
      userId = arguments['id'] as int?;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.person, size: 100, color: Colors.green),
              const SizedBox(height: 16),
              const Text(
                'Profile Page',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // Display parameters
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade200),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Route Parameters:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (userId != null)
                      _buildInfoRow('User ID', userId.toString()),
                    if (userName != null) _buildInfoRow('Name', userName),
                    if (userEmail != null) _buildInfoRow('Email', userEmail),

                    // Show path parameters if any
                    if (parameters.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      const Text(
                        'Path Parameters:',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...parameters.entries.map(
                        (entry) => _buildInfoRow(entry.key, entry.value),
                      ),
                    ],

                    // Show if no data was passed
                    if (userName == null &&
                        userEmail == null &&
                        userId == null &&
                        parameters.isEmpty)
                      const Text(
                        'No parameters passed\nTry passing parameters from the home page!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'This demonstrates Navigator 2.0 with transitions',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 14))),
        ],
      ),
    );
  }
}
