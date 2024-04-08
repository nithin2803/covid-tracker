import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';

class CasesPieChart extends StatelessWidget {

  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(260.0, 260);

  int total = 3429795;
  int recoveredCases = 1096057;
  int deaths = 243858;
  int activeCases = 2089880;

  CasesPieChart(int total, int recoveredCases, int deaths, int activeCases) {
    this.total = total;
    this.recoveredCases = recoveredCases;
    this.deaths = deaths;
    this.activeCases = activeCases;
  }

  @override
  Widget build(BuildContext context) {
    return Center(
     child: new AnimatedCircularChart(
        key: _chartKey,
        size: _chartSize,
        holeRadius: 50.0,
        initialChartData: <CircularStackEntry>[
          new CircularStackEntry(
            <CircularSegmentEntry>[
              new CircularSegmentEntry(
                activeCases/total,
                const Color(0xFF1f1fff),
                rankKey: 'active',
              ),
              new CircularSegmentEntry(
                recoveredCases/total,
                const Color(0xFFCCCCCC),
                rankKey: 'recovered',
              ),
              new CircularSegmentEntry(
                deaths/total,
                Colors.red,
                rankKey: 'deaths',
              ),
            ],
            rankKey: 'cases',
          ),
        ],
        chartType: CircularChartType.Radial,
      ),
    );
  }
}