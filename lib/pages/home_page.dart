import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'package:covid_tracker/widgets/legend.dart';
import 'package:covid_tracker/widgets/pie_chart.dart';
import 'package:covid_tracker/common/constants.dart';


//Stateful widget for the main home screen
class HomePage extends StatefulWidget {

  //Create state for home page
  @override
  _HomePageState createState() => new _HomePageState();
}

class _HomePageState extends State<HomePage> {

  //State variables
  var data;
  //Asynchronously gets the data from the Novel Coronavirus API and updates the state.
  void retrieveData() async {

    //API url
    final String url = 'https://covid-api.com/api/reports/total?';

    //Awaits the json results and decodes the JSON object into a dart map
    var results = await http.get(Uri.encodeFull(url), headers: {"Accept": "application/json"});
    var jsonData = jsonDecode(results.body);

    if (!mounted) return;
    //Sets state with appropriate data from the API which triggers a widget tree re-render.
    setState(() {
      data = jsonData['data'];
    });
  }


  //Main render function
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Today's Summary", style: bold.copyWith(fontSize: 22)),
      ),
      body: Center(
        child: (data == null) ? CircularProgressIndicator() :
            FittedBox(
              fit: BoxFit.fitHeight,
              child:
              Center(
                child: Column(
                    children: <Widget>[
                      Container(
                        margin: const EdgeInsets.all(10),
                        child: Text('Global Covid-19 Cases', style: bold.copyWith(fontSize: 25))
                      ),
                      Legend([
                          new LegendEntry("Active", BLUE_ACCENT),
                          new LegendEntry("Recovered", GREY),
                          new LegendEntry("Deaths", RED),
                      ]),
                      CasesPieChart(data["confirmed"], data["recovered"], data["deaths"], data["active"]),
                      Column(
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: <Widget>[
                                    Text("Total", style: normal),
                                    Text((data != null) ? NumberFormat.decimalPattern("en_US").format(data["confirmed"]).toString() : '-', style: bold.copyWith(fontSize: 19)),
                                    Text((data != null) ? '(+${NumberFormat.decimalPattern("en_US").format(data["confirmed_diff"]).toString()})' : '-', style: normal),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: CIRCLE_WIDTH,
                                          height: CIRCLE_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: BLUE_ACCENT,
                                            shape: BoxShape.circle,
                                          ),
                                          margin: EdgeInsets.only(right: 5),
                                        ),
                                        Text("Active", style: normal),
                                      ],
                                    ),
                                    Text((data != null) ? NumberFormat.decimalPattern("en_US").format(data["active"]).toString() : '-', style: bold.copyWith(fontSize: 19)),
                                    Text((data != null) ? '(+${NumberFormat.decimalPattern("en_US").format(data["active_diff"]).toString()})' : '-', style: normal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: <Widget>[
                              Container(
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          width: CIRCLE_WIDTH,
                                          height: CIRCLE_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: RED,
                                            shape: BoxShape.circle,
                                          ),
                                          margin: EdgeInsets.only(right: 5),
                                        ),
                                        Text("Deaths", style: normal),
                                      ],
                                    ),
                                    Text((data != null) ? NumberFormat.decimalPattern("en_US").format(data["deaths"]).toString() : '-', style: bold.copyWith(fontSize: 19)),
                                    Text((data != null) ? '(+${NumberFormat.decimalPattern("en_US").format(data["deaths_diff"]).toString()})' : '-', style: normal),
                                  ],
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(20),
                                child: Column(
                                  children: <Widget>[
                                    Row(
                                      children: <Widget>[
                                        Container(
                                          margin: EdgeInsets.only(right: 5),
                                          width: CIRCLE_WIDTH,
                                          height: CIRCLE_HEIGHT,
                                          decoration: BoxDecoration(
                                            color: GREY,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        Text("Recovered", style: normal),
                                      ],
                                    ),
                                    Text((data != null) ? NumberFormat.decimalPattern("en_US").format(data["recovered"]).toString() : '-', style: bold.copyWith(fontSize: 19)),
                                    Text((data != null) ? '(+${NumberFormat.decimalPattern("en_US").format(data["recovered_diff"]).toString()})' : '-', style: normal),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Text("Last updated at " + DateFormat.jm().format(DateTime.parse(data["last_update"])), style: normal.copyWith(fontSize: 12, color: const Color(0x55FFFFFF))),
                    ],
                  ),
              ),
            ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods
  }

  @override
  void initState() {
    super.initState();
    this.retrieveData();
  }
}
