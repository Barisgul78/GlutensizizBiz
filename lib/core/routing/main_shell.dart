import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../../features/home/presentation/screens/home_screen.dart';
import '../../features/search/presentation/screens/search_screen.dart';
import '../../features/venues/presentation/screens/venues_screen.dart';
import '../../features/favorites/presentation/screens/favorites_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/search/data/models/product.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _selectedIndex = 0;

  void _dummySelect(Product p) {}

  late final List<Widget> _pages;

  void _navigateToTab(int index) => setState(() => _selectedIndex = index);

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeScreen(onTabChange: _navigateToTab),
      const SearchScreen(),
      const VenuesScreen(),
      FavoritesScreen(onProductSelect: _dummySelect),
      const ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackground,
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) => setState(() => _selectedIndex = index),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Anasayfa',
          ),
          NavigationDestination(
            icon: Icon(Icons.search_outlined),
            selectedIcon: Icon(Icons.search),
            label: 'Ara',
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: 'Mekanlar',
          ),
          NavigationDestination(
            icon: Icon(Icons.favorite_outline),
            selectedIcon: Icon(Icons.favorite),
            label: 'Favoriler',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}
