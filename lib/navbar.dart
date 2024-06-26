import 'package:citysos_police/views/home_view.dart';
import 'package:citysos_police/views/news_view.dart';
import 'package:citysos_police/views/history_view.dart';
import 'package:citysos_police/views/user_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  static final GlobalKey<_NavbarState> navigatorKey = GlobalKey<_NavbarState>();

  @override
  _NavbarState createState() => _NavbarState();

  static _NavbarState? of(BuildContext context) {
    return context.findAncestorStateOfType<_NavbarState>();
  }
}

class _NavbarState extends State<Navbar> {
  int selectedIndex = 0;

  void setIndex(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    final views = [
      const Home(),
      const NewsView(),
      const History(),
      const User(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: selectedIndex,
        children: views,
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        onTap: (_selectedIndex) {
          setState(() {
            selectedIndex = _selectedIndex;
          });
        },
        selectedItemColor: colors.primary,
        unselectedItemColor: Colors.black,
        selectedLabelStyle: TextStyle(color: colors.primary),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            activeIcon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.home_filled, color: colors.primary),
              ),
            ),
            label: 'Inicio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper_outlined),
            activeIcon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.newspaper_rounded, color: colors.primary),
              ),
            ),
            label: 'Noticias',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart_outlined),
            activeIcon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.bar_chart_rounded, color: colors.primary),
              ),
            ),
            label: 'Historial',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            activeIcon: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: colors.primary.withOpacity(0.2),
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Icon(Icons.person, color: colors.primary),
              ),
            ),
            label: 'Usuario',
          ),
        ],
        backgroundColor: colors.background,
      ),
    );
  }
}
