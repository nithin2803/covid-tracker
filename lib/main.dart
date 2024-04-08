import 'package:covid_tracker/pages/main_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:covid_tracker/common/constants.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    //Force the screen into portrait orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    return MaterialApp(
      title: 'Covid Tracker',
      debugShowCheckedModeBanner: false,
      //Global theme data for the app
      theme: ThemeData(
        scaffoldBackgroundColor: APP_COLOR,
        primaryColor: APP_COLOR,
        accentColor: RED,
        fontFamily: 'ProductSans',
      ),

      //Main screen
      home: MainPage(),
    );
  }
}