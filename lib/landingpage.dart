import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:shokti/ChatPage.dart';
import 'package:shokti/LandingPageAppBar.dart';
import 'package:shokti/EnergyPage.dart';
import 'package:shokti/Tracker.dart';
import 'package:shokti/chart/energy_chart.dart';
import 'package:shokti/chart/prediction.dart';

class Landingpage extends StatefulWidget {
  const Landingpage({super.key});

  @override
  State<Landingpage> createState() => _LandingpageState();
}

class _LandingpageState extends State<Landingpage> {
  int _pageIndex = 0;

  // Build the home content (charts) used for index 0
  Widget _buildHomeContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(18.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 2),

          // Energy chart card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: const EnergyChart(),
            ),
          ),

          const SizedBox(height: 8),

          // Prediction chart card
          Card(
            elevation: 4,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: const PredictionChart(),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeColor = Colors.white;
    final inactiveColor = Colors.greenAccent.shade200;

    final items = <Widget>[
      Icon(
        Icons.home,
        size: 30,
        color: _pageIndex == 0 ? activeColor : inactiveColor,
      ),
      Icon(
        Icons.calendar_month,
        size: 28,
        color: _pageIndex == 1 ? activeColor : inactiveColor,
      ),
      Icon(
        Icons.bolt,
        size: 28,
        color: _pageIndex == 2 ? activeColor : inactiveColor,
      ),
      Icon(
        Icons.smart_toy,
        size: 28,
        color: _pageIndex == 3 ? activeColor : inactiveColor,
      ),
    ];

    final pages = <Widget>[
      _buildHomeContent(),
      const Tracker(useScaffold: false),
      const EnergyPage(),
      ChatPage(useScaffold: false),
    ];

    // Wrap non-chat pages with consistent padding; chat should be full-bleed
    final wrappedPages = List<Widget>.generate(pages.length, (i) {
      if (i == 3) return pages[i]; // ChatPage: no extra padding
      if (i == 2)
        return Padding(
          // EnergyPage: needs bottom padding for nav bar
          padding: const EdgeInsets.only(
            bottom: 70,
          ), // Add extra bottom padding for nav bar
          child: pages[i],
        );
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        child: pages[i],
      );
    });

    final titles = ['Shokti Home', 'Monthly Tracker', 'Energy', 'Shokti AI'];

    return Scaffold(
      extendBody: true,
      appBar: LandingPageAppBar(
        title: titles[_pageIndex],
        onBack: _pageIndex != 0 || Navigator.canPop(context)
            ? () {
                if (_pageIndex != 0) {
                  setState(() => _pageIndex = 0);
                } else if (Navigator.canPop(context)) {
                  Navigator.pop(context);
                }
              }
            : null,
      ),
      body: IndexedStack(index: _pageIndex, children: wrappedPages),
      bottomNavigationBar: _pageIndex == 3
          ? null
          : CurvedNavigationBar(
              backgroundColor: Colors.transparent,
              color: const Color.fromARGB(255, 8, 59, 10),
              height: 60,
              index: _pageIndex,
              items: items,
              onTap: (index) {
                setState(() {
                  _pageIndex = index;
                });
              },
            ),
    );
  }
}
