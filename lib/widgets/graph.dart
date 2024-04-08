import 'package:flutter/cupertino.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Graph extends StatefulWidget {
  String country;
  int renderIndex;

  Graph(this.country, this.renderIndex);

  @override
  _GraphState createState() => new _GraphState();
}

class _GraphState extends State<Graph> {
  var data;
  var keys = [];
  List<GraphData> cases = [];
  List<GraphData> deaths = [];
  List<GraphData> recovered = [];
  List<charts.Series> seriesList;
  List<GraphData> newCases = [];
  Widget graph = new Text("Loading...", style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold));

  Future<String> getCovidData() async {
    String url = 'https://corona.lmao.ninja/v2/historical/' + widget.country + '?lastdays=90';
    var results = await http.get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    setState(() {
      var resBody = json.decode(results.body);
      data = resBody["timeline"];
      resBody["timeline"]["cases"].keys.forEach((key) => keys.add(key));
    });

    for(int i = 0; i < keys.length; i++) {
      GraphData newData = new GraphData(i, data["cases"][keys[i]]);
      cases.add(newData);
    }
    for(int i = 0; i < keys.length; i++) {
      GraphData newData = new GraphData(i, data["deaths"][keys[i]]);
      deaths.add(newData);
    }
    for(int i = 0; i < keys.length; i++) {
      GraphData newData = new GraphData(i, data["recovered"][keys[i]]);
      recovered.add(newData);
    }
    for(int i = 0; i < keys.length - 1; i++) {
      var delta = data["cases"][keys[i+1]] - data["cases"][keys[i]];
      GraphData newData = new GraphData(i, delta);
      newCases.add(newData);
    }


    return 'Success!';
  }

  List<charts.Series<GraphData, int>> _createCovidData() {
    if(widget.renderIndex == 0) {
      return [
        new charts.Series<GraphData, int>(
          id: 'cases',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: cases,
        ),
        new charts.Series<GraphData, int>(
          id: 'deaths',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: deaths,
        ),
        new charts.Series<GraphData, int>(
          id: 'recovered',
          colorFn: (_, __) => charts.MaterialPalette.white,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: recovered,
        ),
      ];
    } return [
      new charts.Series<GraphData, int>(
        id: 'newCases',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (GraphData data, _) => data.date,
        measureFn: (GraphData data, _) => data.value,
        data: newCases,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    seriesList = _createCovidData();
    if(seriesList != null) {
      setState(() {
        graph = new Container(
            child: new charts.LineChart(seriesList,
              defaultRenderer: new charts.LineRendererConfig(includeArea: true, stacked: false),
              domainAxis: new charts.NumericAxisSpec(
                  renderSpec: new charts.GridlineRendererSpec(

                    // Tick and Label styling here.
                      labelStyle: new charts.TextStyleSpec(
                          color: charts.MaterialPalette.white),
                      lineStyle: new charts.LineStyleSpec(
                          color: charts.MaterialPalette.transparent))),
              primaryMeasureAxis: new charts.NumericAxisSpec(
                  renderSpec: new charts.GridlineRendererSpec(

                    // Tick and Label styling here.
                      labelStyle: new charts.TextStyleSpec(
                          color: charts.MaterialPalette.white),
                      lineStyle: new charts.LineStyleSpec(
                          color: charts.MaterialPalette.white))),
              animate: false,
            ));
      });
    }
    return graph;
  }

  @override
  void initState() {
    super.initState();
    this.getCovidData();
    seriesList = _createCovidData();
  }
}

class GraphData {
  final int date;
  final int value;

  GraphData(this.date, this.value);
}