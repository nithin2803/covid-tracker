import 'package:covid_tracker/common/constants.dart';
import 'package:covid_tracker/pages/zone_page.dart';
import 'package:covid_tracker/widgets/graph.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

class LocalInfoPage extends StatefulWidget {
  @override
  _LocalInfoPageState createState() => new _LocalInfoPageState();
}

class _LocalInfoPageState extends State<LocalInfoPage> {
  final Geolocator geolocator = Geolocator()..forceAndroidLocationManager;

  String state = '';
  String city = '';
  Position _currentPosition;
  List zonesData;
  List<GraphData> districtConfirmedData;
  List<GraphData> districtDeathData;
  List<GraphData> districtRecoveredData;
  List<charts.Series> seriesList;

  var latestCases;
  var latestDeaths;
  var latestRecovered;

  var textColors = {
    'Green': Colors.green,
    'Orange': Colors.orange,
    'Red': Colors.red,
  };

  var abbreviations = {
  'AP': 'Andhra Pradesh', 'AR': 'Arunachal Pradesh', 'AS': 'Assam', 'BR': 'Bihar', 'CG': 'Chhattisgarh', 'GA': 'Goa', 'GJ': 'Gujarat', 'HR': 'Haryana', 'HP': 'Himachal Pradesh', 'JK': 'Jammu and Kashmir', 'JH': 'Jharkhand', 'KA': 'Karnataka', 'KL': 'Kerala', 'MP': 'Madhya Pradesh', 'MH': 'Maharashtra', 'MN': 'Manipur', 'ML': 'Meghalaya', 'MZ': 'Mizoram', 'NL': 'Nagaland', 'OR': 'Orissa', 'PB': 'Punjab', 'RJ': 'Rajasthan', 'SK': 'Sikkim', 'TN': 'Tamil Nadu', 'TG': 'Telangana', 'TR': 'Tripura', 'UK': 'Uttarakhand', 'UP': 'Uttar Pradesh', 'WB': 'West Bengal'
  };

  String currentZoneStatus;

  var newsData;

  Future<String> getCovidData() async {
    zonesData = [];
    districtConfirmedData = [];
    districtDeathData = [];
    districtRecoveredData = [];

    String zonesURL = 'https://api.covid19india.org/zones.json';
    String districtURL = 'https://api.covid19india.org/districts_daily.json';
    String newsURL = 'https://newsapi.org/v2/everything?q=covid&sources=the-times-of-india,the-hindu&sortBy=publishedAt&apiKey=2de0a6bd366242d88d7bf2a8ffa0f248';

    var zonesResults = await http.get(Uri.encodeFull(zonesURL), headers: {"Accept": "application/json"});
    var districtResults = await http.get(Uri.encodeFull(districtURL), headers: {"Accept": "application/json"});
    var newsResults = await http.get(Uri.encodeFull(newsURL), headers: {"Accept": "application/json"});

    if (!mounted) return "";

    var zonesResultsBody = json.decode(zonesResults.body);
    var districtResultsBody = json.decode(districtResults.body);
    var newsResultsBody = json.decode(newsResults.body);

    List tempZoneList = [];
    List<GraphData> tempConfirmedList = [];
    List<GraphData> tempDeathList = [];
    List<GraphData> tempRecoveredList = [];

    for (int i = 0; i < zonesResultsBody["zones"].length; i++) {
      if (zonesResultsBody["zones"][i]["statecode"] == state) {
        tempZoneList.add(zonesResultsBody["zones"][i]);
      }
      if (zonesResultsBody["zones"][i]["district"] == city) {
        currentZoneStatus = zonesResultsBody["zones"][i]["zone"];
      }
    }

    for (int i = 0; i < districtResultsBody["districtsDaily"][abbreviations[state]][city].length; i++) {
      tempConfirmedList.add(GraphData(i, districtResultsBody["districtsDaily"][abbreviations[state]][city][i]["confirmed"]));
      tempDeathList.add(GraphData(i, districtResultsBody["districtsDaily"][abbreviations[state]][city][i]["deceased"]));
      tempRecoveredList.add(GraphData(i, districtResultsBody["districtsDaily"][abbreviations[state]][city][i]["recovered"]));

    }

    setState(() {
      zonesData = tempZoneList;
      districtConfirmedData = tempConfirmedList;
      districtRecoveredData = tempRecoveredList;
      districtDeathData = tempDeathList;
      newsData = newsResultsBody["articles"];

      latestCases = districtResultsBody["districtsDaily"][abbreviations[state]][city].last["confirmed"];
      latestDeaths = districtResultsBody["districtsDaily"][abbreviations[state]][city].last["deceased"];
      latestRecovered = districtResultsBody["districtsDaily"][abbreviations[state]][city].last["recovered"];
    });

    return 'Success!';
  }

  List<charts.Series<GraphData, int>> _createCovidData() {
    return [
      new charts.Series<GraphData, int>(
        id: 'recovered2',
        colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
        domainFn: (GraphData data, _) => data.date,
        measureFn: (GraphData data, _) => data.value,
        data: districtConfirmedData,
      ),
      new charts.Series<GraphData, int>(
        id: 'recovered2',
        colorFn: (_, __) => charts.MaterialPalette.gray.shadeDefault,
        domainFn: (GraphData data, _) => data.date,
        measureFn: (GraphData data, _) => data.value,
        data: districtRecoveredData,
      ),
      new charts.Series<GraphData, int>(
        id: 'recovered2',
        colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
        domainFn: (GraphData data, _) => data.date,
        measureFn: (GraphData data, _) => data.value,
        data: districtDeathData,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    seriesList = _createCovidData();
      return Scaffold(
      appBar: AppBar(
        title: Text("For You", style: bold.copyWith(fontSize: 22)),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new ZonePage(zonesData, abbreviations[state])),
                );
              },
              child: ListTile(
                dense: true,
                leading: Icon(Icons.location_on, color: WHITE),
                title: Text('$city, $state', style: bold.copyWith(fontSize: 18)),
                subtitle: Text((currentZoneStatus != null) ? currentZoneStatus + ' Zone': '', style: bold.copyWith(fontSize: 16, color: textColors[currentZoneStatus])),
                trailing: Icon(Icons.arrow_forward_ios, color: WHITE),
              ),
            ),
            Container(
                width: 350,
                height: 200,
                child: (seriesList == null) ? CircularProgressIndicator() :
                new charts.LineChart(
                  seriesList,
                  defaultRenderer: new charts.LineRendererConfig(includeArea: true, stacked: false),
                  domainAxis: new charts.NumericAxisSpec(
                      renderSpec: new charts.GridlineRendererSpec(
                          labelStyle: new charts.TextStyleSpec(color: charts.MaterialPalette.white),
                          lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.transparent)
                      )
                  ),
                  primaryMeasureAxis: new charts.NumericAxisSpec(
                      renderSpec: new charts.GridlineRendererSpec(
                          labelStyle: new charts.TextStyleSpec(color: charts.MaterialPalette.white),
                          lineStyle: new charts.LineStyleSpec(color: charts.MaterialPalette.white)
                      )
                  ),
                  animate: false,
                )
            ),
            Padding(
              padding: const EdgeInsets.all(25.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  Column(
                    children: <Widget>[
                      Row(
                        children: <Widget>[
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            margin: EdgeInsets.fromLTRB(0, 0, 5, 0),
                          ),
                          Text("Cases", style: TextStyle(color: Colors.white)),
                        ],
                      ),
                      Text(latestCases != null ? NumberFormat.decimalPattern("en_US").format(latestCases).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: <Widget>[
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
                      Text(latestCases != null ? NumberFormat.decimalPattern("en_US").format(latestDeaths).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Column(
                    children: <Widget>[
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
                      Text(latestCases != null ? NumberFormat.decimalPattern("en_US").format(latestRecovered).toString(): '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ],
              ),
            ),
            Text("News", style: bold.copyWith(fontSize: 20)),
            Container(
              height: 110,
              margin: EdgeInsets.symmetric(horizontal: 20),
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: (newsData != null) ? newsData.length : 0,
                itemBuilder: (BuildContext context, int index) {
                  return InkWell(
                    onTap: () {
                      _launchURL(newsData[index]["url"]);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              Container(
                                width: 20,
                                height:20,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: NetworkImage((newsData[index]["source"]["id"] == "the-hindu") ? 'https://d302e0npexowb4.cloudfront.net/wp-content/uploads/2016/11/The-Hindu-logo.png' : 'https://apprecs.org/ios/images/app-icons/256/d1/427589329.jpg'),
                                    fit: BoxFit.fill,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              const SizedBox(width: 15),
                              Text(newsData[index]["source"]["name"], style: bold)
                            ],
                          ),
                          const SizedBox(height: 5),
                          Container(width: 250, child: Text(newsData[index]["title"], style: bold.copyWith(fontSize: 18), overflow: TextOverflow.ellipsis)),
                          const SizedBox(height: 2),
                          Container(width: 250, child: Text(newsData[index]["description"], style: normal, overflow: TextOverflow.ellipsis,)),
                          Text('By ' + ((newsData[index]["author"] == null) ? 'Times of India' : newsData[index]["author"]) + ' on ' + DateFormat.yMMMMd('en_US').format(DateTime.parse(newsData[index]["publishedAt"])), style: normal.copyWith(fontSize: 12, color: const Color(0x55FFFFFF))),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            Text("Resources", style: bold.copyWith(fontSize: 20)),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: FittedBox(
                fit:BoxFit.fitWidth,
                child: Row(
                 children: <Widget>[
                   Container(
                     width: 200,
                     child: InkWell(
                      onTap: () {
                        _launchURL('http://www.aarogyasetumitr.in');
                      },
                      child: Card(
                        color: NAV_BAR,
                          child: Column(
                            children: <Widget>[
                              ListTile(title: Text("AarogyaSetu Mitr", style: bold), trailing: Icon(Icons.local_hospital, color: RED)),
                              Container(margin: EdgeInsets.only(bottom: 7), child: ListTile(title: Text("Free COVID-19 Consultation and Labs/Medicines", style: normal)))
                            ],
                          )
                      ),
                      ),
                   ),
                   Container(
                     width: 200,
                     child: InkWell(
                       onTap: () {
                         _launchURL('http://www.covid123.in');
                       },
                       child: Card(
                           color: NAV_BAR,
                           child: Column(
                             children: <Widget>[
                               ListTile(title: Text("Covid123.in", style: bold), trailing: Icon(Icons.healing, color: Colors.green)),
                               Container(margin: EdgeInsets.only(bottom: 7), child: ListTile(title: Text("Looking to help out? Volunteer or donate with Covid123", style: normal))),
                             ],
                           )
                       ),
                     ),
                   ),
                  ],
                ),
              ),
            ),
          ],
        )
      ),
    );
  }

  Future<void> _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url, forceWebView: false, forceSafariVC: true);
    } else {
      throw 'Could not launch $url';
    }
  }

  _getCurrentLocation() {
    geolocator
        .getCurrentPosition(desiredAccuracy: LocationAccuracy.medium)
        .then((Position position) {
      setState(() {
        _currentPosition = position;
      });

      _getAddressFromLatLng();
    }).catchError((e) {
      print(e);
    });
  }


  _getAddressFromLatLng() async {
    try {
      List<Placemark> p = await geolocator.placemarkFromCoordinates(
          _currentPosition.latitude, _currentPosition.longitude);

      Placemark place = p[0];

      if(!mounted) return;

      print(place.name);
      print(place.subLocality);

      setState(() {
        state = place.administrativeArea;
        city = place.locality;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    getCovidData();
    seriesList = _createCovidData();
  }
}
