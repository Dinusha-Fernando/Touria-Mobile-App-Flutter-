import 'package:flutter/material.dart';
import 'package:touria/screen/eventScreen.dart';
import 'package:touria/screen/itinery_planner.dart';
import 'package:touria/screen/home_screen.dart';
import 'package:touria/screen/profileScreen.dart';
import 'package:touria/screen/search_screen.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const SearchScreen(),
    const EventScreen(),
    const ItineraryPlanner(),
    const Profilescreen(),
  ];

  final List<IconData> _icons = [
    Icons.home,
    Icons.search,
    Icons.event_note,
    Icons.flight_takeoff,
    //Icons.person,
  ];

  final List<String> _lables = [
    'Home',
    'Search',
    'Events',
    'Planer',
    //'Profile',
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;

      // Add navigation logic here if needed

      // Example: Navigator.pushNamed(context, '/somepage');
    });
    // switch (index) {
    //   case 1:
    //     Navigator.pushNamed(context, '/search');
    //     break;

    //   default:
    //     break;
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex], // display the selected screen
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 5,
              offset: Offset(0, -1),
            ),
          ],
        ),

        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          selectedItemColor: Color(0xff0091d5),
          unselectedItemColor: Colors.grey,
          currentIndex: _selectedIndex,
          onTap: _onItemTapped,
          showUnselectedLabels: true,
          items: List.generate(_icons.length, (index) {
            return BottomNavigationBarItem(
              icon: Icon(_icons[index]),
              label: _lables[index],
            );
          }),
        ),
      ),
    );
  }
}
