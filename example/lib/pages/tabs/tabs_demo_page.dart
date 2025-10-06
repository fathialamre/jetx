import 'package:flutter/material.dart';
import 'package:jet/jet.dart';

/// Demo page showing route-controlled bottom navigation
class TabsDemoPage extends StatelessWidget {
  const TabsDemoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Define the tabs route
    final tabsRoute = TabsRoute(
      path: '/app',
      name: 'app_tabs',
      restorationId: 'app_tabs',
      tabs: [
        TabItem(
          name: 'home',
          path: 'home',
          label: 'Home',
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home),
          initial: true,
          restorationId: 'home_tab',
          routes: [
            JetPage(
              name: '/app/home',
              page: () => const HomeTabPage(),
            ),
            JetPage(
              name: '/app/home/details',
              page: () => const HomeDetailsPage(),
            ),
          ],
        ),
        TabItem(
          name: 'search',
          path: 'search',
          label: 'Search',
          icon: const Icon(Icons.search_outlined),
          selectedIcon: const Icon(Icons.search),
          restorationId: 'search_tab',
          routes: [
            JetPage(
              name: '/app/search',
              page: () => const SearchTabPage(),
            ),
            JetPage(
              name: '/app/search/results',
              page: () => const SearchResultsPage(),
            ),
          ],
        ),
        TabItem(
          name: 'profile',
          path: 'profile',
          label: 'Profile',
          icon: const Icon(Icons.person_outline),
          selectedIcon: const Icon(Icons.person),
          restorationId: 'profile_tab',
          routes: [
            JetPage(
              name: '/app/profile',
              page: () => const ProfileTabPage(),
            ),
            JetPage(
              name: '/app/profile/settings',
              page: () => const ProfileSettingsPage(),
            ),
          ],
        ),
      ],
    );

    return JetTabsShell(
      tabsRoute: tabsRoute,
      restorationId: 'tabs_shell',
      onTabChanged: (oldIndex, newIndex) {
        debugPrint('Tab changed from $oldIndex to $newIndex');
      },
    );
  }
}

/// Home tab page
class HomeTabPage extends StatelessWidget {
  const HomeTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Tab'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home Tab',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.router.pushNamed('/app/home/details');
              },
              child: const Text('Go to Home Details'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.router.switchTab(name: 'profile');
              },
              child: const Text('Switch to Profile Tab'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Home details page
class HomeDetailsPage extends StatelessWidget {
  const HomeDetailsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home Details'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Home Details Page',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('This is a detail page within the Home tab.'),
            const SizedBox(height: 10),
            const Text('Use the back button to go back to Home.'),
          ],
        ),
      ),
    );
  }
}

/// Search tab page
class SearchTabPage extends StatelessWidget {
  const SearchTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Tab'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Search Tab',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.router.pushNamed('/app/search/results');
              },
              child: const Text('View Search Results'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.router.switchTab(index: 0);
              },
              child: const Text('Switch to Home Tab'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Search results page
class SearchResultsPage extends StatelessWidget {
  const SearchResultsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Results'),
        backgroundColor: Colors.green,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Search Results',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Search results would appear here.'),
            const SizedBox(height: 10),
            const Text('Each tab maintains its own navigation stack.'),
          ],
        ),
      ),
    );
  }
}

/// Profile tab page
class ProfileTabPage extends StatelessWidget {
  const ProfileTabPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Tab'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profile Tab',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                context.router.pushNamed('/app/profile/settings');
              },
              child: const Text('Go to Profile Settings'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                context.router.switchTab(name: 'search');
              },
              child: const Text('Switch to Search Tab'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Profile settings page
class ProfileSettingsPage extends StatelessWidget {
  const ProfileSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile Settings'),
        backgroundColor: Colors.purple,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Profile Settings',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text('Settings page within Profile tab.'),
            const SizedBox(height: 10),
            const Text('Try switching tabs and coming back!'),
            const SizedBox(height: 10),
            const Text('Your navigation state is preserved.'),
          ],
        ),
      ),
    );
  }
}
