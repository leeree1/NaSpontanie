import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import 'home_screen/home_screen.dart';
import 'map_screen/map_screen.dart';
import 'passport_screen/passport_screen.dart';
import 'profile_screen/profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  var _mapOpened = false;

  void _navigateToMapWithFilter(String filterKey) {
    Provider.of<AppProvider>(context, listen: false).setMapFilter(filterKey);
    setState(() {
      _currentIndex = 1;
      _mapOpened = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: [
          HomeScreen(
            onSelectCategory: _navigateToMapWithFilter,
            onOpenMap: () => setState(() {
              _currentIndex = 1;
              _mapOpened = true;
            }),
          ),
          _mapOpened ? const MapScreen() : const SizedBox.shrink(),
          const PassportScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _currentIndex,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textMuted,
        backgroundColor: Colors.white,
        elevation: 12,
        onTap: (index) {
          setState(() {
            if (index == 1) _mapOpened = true;
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_filled),
            label: 'Start',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.map_rounded),
            label: 'Mapa Live',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user_rounded),
            label: 'Paszport',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded),
            label: 'Profil',
          ),
        ],
      ),
    );
  }
}