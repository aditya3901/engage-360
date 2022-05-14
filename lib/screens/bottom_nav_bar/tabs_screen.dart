import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:engage_360/screens/screens.dart';
import 'package:flutter/material.dart';

class TabsScreen extends StatefulWidget {
  @override
  _TabsScreenState createState() => _TabsScreenState();
}

class _TabsScreenState extends State<TabsScreen> {
  int currentIndex = 1;
  final _items = const <Widget>[
    Icon(Icons.school_rounded, size: 30, color: Colors.white),
    Icon(Icons.home, size: 30, color: Colors.white),
    Icon(Icons.person, size: 30, color: Colors.white),
  ];

  final screens = [
    ExamScreen(),
    MeetScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff7f6fb),
      extendBody: true,
      body: screens[currentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        items: _items,
        backgroundColor: Colors.transparent,
        color: Colors.deepPurple,
        height: 58,
        animationDuration: const Duration(milliseconds: 500),
        index: currentIndex,
        onTap: (index) {
          if (mounted) {
            setState(() {
              currentIndex = index;
            });
          }
        },
      ),
    );
  }
}
