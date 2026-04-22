import 'package:flutter/material.dart';
import 'package:eglise_labe/features/dashboard/widgets/sidebar.dart';
import 'package:eglise_labe/features/dashboard/pages/dashboard_page.dart';
import 'package:eglise_labe/features/dashboard/pages/members_page.dart';
import 'package:eglise_labe/features/dashboard/pages/finances_page.dart';
import 'package:eglise_labe/features/dashboard/pages/activities_page.dart';
import 'package:eglise_labe/features/dashboard/pages/events_page.dart';
import 'package:eglise_labe/features/dashboard/pages/reporting_page.dart';
import 'package:eglise_labe/features/dashboard/pages/settings_page.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const DashboardPage(),
    const MembersPage(),
    const FinancesPage(),
    const ActivitiesPage(),
    const EventsPage(),
    const ReportingPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Sidebar(
            currentIndex: _currentIndex,
            onItemSelected: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
          ),
          Expanded(
            child: Container(
              color: const Color(0xFFF1F7F9),
              child: IndexedStack(index: _currentIndex, children: _pages),
            ),
          ),
        ],
      ),
    );
  }
}
