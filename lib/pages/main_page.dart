import 'package:covid_tracker/common/constants.dart';
import 'package:covid_tracker/pages/breakdown_page.dart';
import 'package:covid_tracker/pages/compare_page.dart';
import 'package:covid_tracker/pages/home_page.dart';
import 'package:covid_tracker/pages/local_info_page.dart';
import 'package:covid_tracker/pages/map_page.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';

import 'package:flutter/material.dart';

class MainPage extends StatefulWidget {
  //Create main page state
  @override
  _MainPageState createState() => new _MainPageState();
}

class _MainPageState extends State<MainPage> {
  //Initialize index of the page that the bottom navbar will display
  int _page = 0;

  //Initialize global key for the bottom navigator
  GlobalKey _bottomNavigationKey = GlobalKey();

  //List of pages that navigator switches between
  final List<Widget> widgets = [
    HomePage(),
    MapPage(),
    LocalInfoPage(),
    BreakdownPage(),
    ComparePage(),
  ];

  //Main render function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        bottomNavigationBar: CurvedNavigationBar(
          key: _bottomNavigationKey,
          items: <Widget>[
            Icon(Icons.home, size: 20, color: WHITE),
            Icon(Icons.public, size: 20, color: WHITE),
            Icon(Icons.location_on, size: 20, color: WHITE),
            Icon(Icons.menu, size: 20, color: WHITE),
            Icon(Icons.compare_arrows, size: 20, color: WHITE),
          ],
          color: NAV_BAR,
          buttonBackgroundColor: NAV_BAR,
          backgroundColor: APP_COLOR,
          animationCurve: Curves.easeInOut,
          animationDuration: Duration(milliseconds: 600),
          onTap: (index) {
            setState(() {
              _page = index;
            });
          },
        ),
        body: widgets[_page]
    );
  }

}
