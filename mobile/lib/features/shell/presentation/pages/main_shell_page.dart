import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../home/presentation/pages/home_page.dart';
import '../../../medications/presentation/pages/medications_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../widgets/app_bottom_nav.dart';

/// Contenedor principal post-login: 3 pestanas con menu inferior flotante.
class MainShellPage extends ConsumerStatefulWidget {
  const MainShellPage({super.key});

  @override
  ConsumerState<MainShellPage> createState() => _MainShellPageState();
}

class _MainShellPageState extends ConsumerState<MainShellPage> {
  int _currentIndex = 0;

  static const List<Widget> _pages = <Widget>[
    HomePage(),
    MedicationsPage(),
    SettingsPage(),
  ];

  static const List<AppBottomNavItem> _navItems = <AppBottomNavItem>[
    AppBottomNavItem(
      icon: Icons.emergency_outlined,
      activeIcon: Icons.emergency_rounded,
      label: 'Emergencias',
    ),
    AppBottomNavItem(
      icon: Icons.medication_outlined,
      activeIcon: Icons.medication_rounded,
      label: 'Medicamento',
    ),
    AppBottomNavItem(
      icon: Icons.settings_outlined,
      activeIcon: Icons.settings_rounded,
      label: 'Ajustes',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // IndexedStack conserva el estado de cada pestana al cambiar de tab.
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _currentIndex,
        onChanged: (int index) => setState(() => _currentIndex = index),
        items: _navItems,
      ),
    );
  }
}
