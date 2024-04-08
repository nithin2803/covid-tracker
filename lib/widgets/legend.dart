import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Legend extends StatelessWidget {
  List<LegendEntry> legendEntries;

  Legend(List<LegendEntry> legendEntries) {
   this.legendEntries = legendEntries;
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: legendEntries.map((entry) =>
          Row(
            children: <Widget>[
              SizedBox(
                width: 18.0,
                height: 13.0,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: entry.color,
                  ),
                ),
              ),
              Container(child: Text (entry.label, style: TextStyle(fontSize: 16, color: Colors.white)), margin: const EdgeInsets.all(8)),
            ],
          ),
      ).toList()
    );
  }
}

class LegendEntry {
  final String label;
  final Color color;

  LegendEntry(this.label, this.color);
}