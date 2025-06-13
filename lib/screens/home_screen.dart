import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:weather_app_riverpod/screens/current_location_weather.dart';

import 'search_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentPageIndex = 0;
  final _screens = [
     CurrentLocationWeatherScreen(),
    SearchScreen(),
    SettingScreen()
  ];
  @override
  Widget build(BuildContext context) {
    final _destinations =  [
      NavigationDestination(
        icon: Icon(Icons.home_outlined, color: Theme.of(context).colorScheme.secondary),
        selectedIcon: Icon(Icons.home, color: Theme.of(context).colorScheme.secondary),
        label: '',
      ),
      NavigationDestination(
        icon: Icon(Icons.search_outlined, color: Theme.of(context).colorScheme.secondary),
        selectedIcon: Icon(Icons.search, color: Theme.of(context).colorScheme.secondary),
        label: '',
      ),
      NavigationDestination(
        icon: Icon(Icons.settings_outlined, color: Theme.of(context).colorScheme.secondary),
        selectedIcon: Icon(Icons.settings, color: Theme.of(context).colorScheme.secondary),
        label: '',
      ),
    ];

    return Scaffold(
      body: _screens[_currentPageIndex],

      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(backgroundColor: Theme.of(context).primaryColor),
        child: NavigationBar(
          destinations: _destinations,
          labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
          selectedIndex: _currentPageIndex,
          indicatorColor: Colors.transparent,
          onDestinationSelected: (index) {
            setState(() {
              _currentPageIndex = index;
            });
          },
        ),
      ),
    );
  }
}
