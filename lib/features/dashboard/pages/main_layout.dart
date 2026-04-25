import 'package:flutter/material.dart';
import 'package:eglise_labe/features/dashboard/widgets/sidebar.dart';
import 'package:eglise_labe/core/constants/colors.dart';
import 'package:eglise_labe/features/dashboard/pages/dashboard_page.dart';
import 'package:eglise_labe/features/dashboard/pages/members_page.dart';
import 'package:eglise_labe/features/dashboard/pages/finances_page.dart';
import 'package:eglise_labe/features/dashboard/pages/activities_page.dart';
import 'package:eglise_labe/features/dashboard/pages/events_page.dart';
import 'package:eglise_labe/features/dashboard/pages/reporting_page.dart';
import 'package:eglise_labe/features/dashboard/pages/settings_page.dart';
import 'package:eglise_labe/features/dashboard/pages/mouvements_page.dart';

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
    const MouvementsPage(),
    const FinancesPage(),
    const ActivitiesPage(),
    const EventsPage(),
    const ReportingPage(),
    const SettingsPage(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;

    Widget content = ColoredBox(
      color: context.surfaceHighlightColor,
      child: IndexedStack(index: _currentIndex, children: _pages),
    );

    return Scaffold(
      backgroundColor: context.surfaceHighlightColor,
      appBar: isDesktop
          ? null
          : AppBar(
              backgroundColor: context.surfaceColor,
              elevation: 0,
              iconTheme: IconThemeData(color: context.textColor),
              title: Text(
                _getPageTitle(_currentIndex),
                style: TextStyle(
                  color: context.textColor,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
      drawer: isDesktop
          ? null
          : SizedBox(
              width: 250,
              child: Drawer(
                child: Sidebar(
                  currentIndex: _currentIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                    if (!isDesktop) {
                      Navigator.of(context).pop(); // Close the drawer safely
                    }
                  },
                ),
              ),
            ),
      body: isDesktop
          ? Row(
              children: [
                Sidebar(
                  currentIndex: _currentIndex,
                  onItemSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                ),
                Expanded(child: content),
              ],
            )
          : content,
    );
  }

  String _getPageTitle(int index) {
    switch (index) {
      case 0:
        return "Dashboard";
      case 1:
        return "Membres";
      case 2:
        return "Mouvements";
      case 3:
        return "Finances";
      case 4:
        return "Activités";
      case 5:
        return "Événements";
      case 6:
        return "Rapports";
      case 7:
        return "Paramètres";
      default:
        return "";
    }
  }
}
