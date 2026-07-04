import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
import 'add_transaction_screen.dart';
import 'summary_screen.dart';

class MainNavigationHolder extends StatefulWidget {
  const MainNavigationHolder({super.key});

  @override
  State<MainNavigationHolder> createState() => _MainNavigationHolderState();
}

class _MainNavigationHolderState extends State<MainNavigationHolder> {
  int _currentIndex = 0;

  // List of screens to display for each tab
  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = [
      DashboardScreen(
        showFAB: false, // Hide FAB since we have a dedicated Tab for recording
        onAddTransactionPressed: () {
          // Switch to Record Tab
          setState(() {
            _currentIndex = 1;
          });
        },
      ),
      AddTransactionScreen(
        isTab: true,
        onSaveSuccess: () {
          // Switch back to Dashboard Tab when save is successful
          setState(() {
            _currentIndex = 0;
          });
        },
      ),
      const SummaryScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final navBgColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final navIndicatorColor = Theme.of(context).colorScheme.primary.withValues(alpha: 0.15);
    final unselectedIconColor = isDark ? const Color(0xFF94A3B8) : const Color(0xFF64748B);
    final activeIconColor = Theme.of(context).colorScheme.primary;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black.withValues(alpha: 0.3) : Colors.black.withValues(alpha: 0.08),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _currentIndex = index;
            });
          },
          backgroundColor: navBgColor,
          indicatorColor: navIndicatorColor, // Soft Gold background for active tab
          elevation: 0,
          height: 72,
          destinations: [
            NavigationDestination(
              icon: Icon(Icons.dashboard_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.dashboard_rounded, color: activeIconColor),
              label: 'แดชบอร์ด',
            ),
            NavigationDestination(
              icon: Icon(Icons.add_circle_outline_rounded, color: unselectedIconColor),
              selectedIcon: Icon(Icons.add_circle_rounded, color: activeIconColor),
              label: 'บันทึก',
            ),
            NavigationDestination(
              icon: Icon(Icons.analytics_outlined, color: unselectedIconColor),
              selectedIcon: Icon(Icons.analytics_rounded, color: activeIconColor),
              label: 'สรุปผล',
            ),
          ],
        ),
      ),
    );
  }
}
