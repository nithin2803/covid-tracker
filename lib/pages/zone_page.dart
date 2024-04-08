import 'package:covid_tracker/common/constants.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ZonePage extends StatelessWidget {
  List zonesData;
  String title;

  var textColors = {
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Red': Colors.red,
  };

  ZonePage(List zonesData, String title) {
    this.zonesData = zonesData;
    this.title = title;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title + " Zones", style: bold.copyWith(fontSize: 22)),
      ),
      body: Center(
        child: ListView.builder(
          itemCount: zonesData == null ? 0 : zonesData.length,
          itemBuilder: (BuildContext context, int index) {
            return ListTile(
              title: Text(zonesData[index]["district"], style: bold.copyWith(fontSize: 18)),
              trailing: Text(zonesData[index]["zone"] + ' Zone', style: bold.copyWith(fontSize: 15, color: textColors[zonesData[index]["zone"]])),
            );
          },
        ),
      ),
    );
  }
}