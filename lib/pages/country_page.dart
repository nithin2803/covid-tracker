import 'package:covid_tracker/common/constants.dart';
import 'package:covid_tracker/widgets/graph.dart';
import 'package:flutter_circular_chart/flutter_circular_chart.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CountryPage extends StatefulWidget {
  var data;

  CountryPage(var data) {
    this.data = data;
  }

  @override
  _CountryPageState createState() => new _CountryPageState();
}

class _CountryPageState extends State<CountryPage> {
  final GlobalKey<AnimatedCircularChartState> _chartKey = new GlobalKey<AnimatedCircularChartState>();
  final _chartSize = const Size(260.0, 260);
  Color progress = WHITE;
  var icon = Icons.remove;
  List<bool> isSelected = [true, false];
  String doublingTime = '-';
  int renderIndex = 0;

  @override
  Widget build(BuildContext context) {
    var data = widget.data;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title:Row(
          children: <Widget>[
            Icon(icon, color: progress, size: 40,),
            Container(margin: EdgeInsets.symmetric(horizontal: 5), child: Text('${data["country"]}: ${NumberFormat.compact().format(data["cases"])} Total', style: TextStyle(fontWeight: FontWeight.w800))),
          ],
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment:  MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Container(
                    height: 200,
                    width: 200,
                    margin: EdgeInsets.fromLTRB(40, 5, 5, 5),
                    child: new AnimatedCircularChart(
                      key: _chartKey,
                      size: _chartSize,
                      holeRadius: 50.0,
                      initialChartData: <CircularStackEntry>[
                        new CircularStackEntry(
                          <CircularSegmentEntry>[
                            new CircularSegmentEntry(
                              data["active"]/data["cases"],
                              const Color(0xFF1f1fff),
                              rankKey: 'active',
                            ),
                            new CircularSegmentEntry(
                              data["recovered"]/data["cases"],
                              const Color(0xFFCCCCCC),
                              rankKey: 'recovered',
                            ),
                            new CircularSegmentEntry(
                              data["deaths"]/data["cases"],
                              Colors.red,
                              rankKey: 'deaths',
                            ),
                          ],
                          rankKey: 'cases',
                        ),
                      ],
                      chartType: CircularChartType.Radial,
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(5, 5, 75, 5),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFF1f1fff),
                                shape: BoxShape.circle,
                              ),
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            ),
                            Text("Cases", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Text(NumberFormat.decimalPattern("en_US").format(data["cases"]).toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('(+${NumberFormat.decimalPattern("en_US").format(data["todayCases"]).toString()})', style: normal),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                              ),
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            ),
                            Text("Deaths", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Text(NumberFormat.decimalPattern("en_US").format(data["deaths"]).toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        Text('(+${NumberFormat.decimalPattern("en_US").format(data["todayDeaths"]).toString()})', style: normal),
                        const SizedBox(height: 12),
                        Row(
                          children: <Widget>[
                            Container(
                              width: 12,
                              height: 12,
                              decoration: BoxDecoration(
                                color: const Color(0xFFCCCCCC),
                                shape: BoxShape.circle,
                              ),
                              margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                            ),
                            Text("Recovered", style: TextStyle(color: Colors.white)),
                          ],
                        ),
                        Text(NumberFormat.decimalPattern("en_US").format(data["recovered"]).toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            FittedBox(
              fit: BoxFit.fitWidth,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text("Time to Double", style: TextStyle(color: Colors.white)),
                        Row(
                          children: <Widget>[
                            Text(doublingTime, style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                            const SizedBox(width: 5),
                            Text("days", style: TextStyle(color: Colors.white, fontSize: 12)),
                          ],
                        ),
                      ],
                    ),
                    margin: EdgeInsets.all(20),
                  ),
                  Container(
                    height: 90,
                    width:1.0,
                    color: const Color(0x44CCCCCC),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text("Testing", style: TextStyle(color: Colors.white)),
                        Text(NumberFormat.compact().format(data["tests"]).toString(), style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    margin: EdgeInsets.all(20),
                  ),
                  Container(
                    height: 90,
                    width:1.0,
                    color: const Color(0x44CCCCCC),
                  ),
                  Container(
                    child: Column(
                      children: <Widget>[
                        Text("Fatality Rate", style: TextStyle(color: Colors.white)),
                        Text('${NumberFormat.compact().format(data["deaths"]/data["cases"]*100)}%', style: TextStyle(color: Colors.white, fontSize: 25, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    margin: EdgeInsets.all(20),
                  ),
                ],
              ),
            ),
            ToggleButtons(
              children: <Widget>[
                Container(margin: EdgeInsets.all(8), child: Text("Total Summary", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)),
                Container(margin: EdgeInsets.all(8), child: Text("Daily New Cases",  style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),)),
              ],
              isSelected: isSelected,
              borderWidth: 1,
              borderColor: Colors.grey,
              fillColor: const Color(0xCCB71C1C),
              selectedBorderColor: Colors.red,
              onPressed: (int index) {
                setState(() {
                  for (int buttonIndex = 0; buttonIndex <
                      isSelected.length; buttonIndex++) {
                    if (buttonIndex == index) {
                      isSelected[buttonIndex] = true;
                    } else {
                      isSelected[buttonIndex] = false;
                    }
                  }
                  renderIndex = index;
                });
              },
            ),
            Container(
              height: 200,
              width: 350,
              child: Graph(widget.data["country"], renderIndex),
            ),
          ],
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods
  }

  getDoublingTimeAndProgress(String country) async{
    String url = 'https://corona.lmao.ninja/v2/historical/' + country + '?lastdays=90';
    var results = await http.get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var data;
    var keys = [];

    var resBody = json.decode(results.body);
    data = resBody["timeline"]["cases"];
    data.keys.forEach((key) => keys.add(key));
    List<double> growthRates = [];
    List<double> todayProgress = [];
    List<double> yesterdayProgress = [];

    for(int i = data.length - 6; i < data.length - 1; i++) {
      double growthRate = (data[keys[i + 1]] - data[keys[i]])/data[keys[i]]*100;
      double newCases = (data[keys[i + 1]] - data[keys[i]]).toDouble();
      double yesterdayNewCases = (data[keys[i]] - data[keys[i - 1]]).toDouble();
      yesterdayProgress.add(yesterdayNewCases);
      growthRates.add(growthRate);
      todayProgress.add(newCases);
    }

    double growthAverage = 0.0;
    double todayAverage = 0.0;
    double yesterdayAverage = 0.0;
    for(int i = 0; i < growthRates.length; i++) {
      growthAverage += growthRates[i];
      todayAverage += todayProgress[i];
      yesterdayAverage += yesterdayProgress[i];
    }
    growthAverage = 360/growthAverage;
    todayAverage = todayAverage/todayProgress.length;
    yesterdayAverage = yesterdayAverage/yesterdayProgress.length;

    if (!mounted) return;

    print(growthAverage);
    setState(() {
      doublingTime = '~' + NumberFormat.compact().format(growthAverage).toString();
      progress = (todayAverage > yesterdayAverage) ? RED : Colors.green;
      icon = (todayAverage > yesterdayAverage) ? Icons.arrow_drop_up : Icons.arrow_drop_down;
     });
  }

  @override
  void initState() {
    super.initState();
    getDoublingTimeAndProgress(widget.data["country"]);
  }
}
