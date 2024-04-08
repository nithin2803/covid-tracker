import 'package:covid_tracker/common/constants.dart';
import 'package:covid_tracker/widgets/graph.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class ComparePage extends StatefulWidget {

  //Create state for the comparison page
  @override
  _ComparePageState createState() => new _ComparePageState();
}

class _ComparePageState extends State<ComparePage> {
  //List of booleans to show which toggle button is activated
  List<bool> isSelected = [true, false, false];

  //Used to add a property for the API call
  final List<String> types = ['cases', 'deaths', 'recovered'];
  String type = "cases";

  //Default two countries to compare before user has selected new one
  String country1 = 'USA';
  String country2 = 'Italy';

  //Initialize three dynamic variables for the GET data and for the keys to access it by
  var data1;
  var data2;
  var keys = [];

  //Long list of all countries that is stored locally to reduce lag for dropdown selector
  final List<String> countries = [
    'USA',
    'Spain',
    'Italy',
    'UK',
    'France',
    'Germany',
    'Russia',
    'Turkey',
    'Brazil',
    'Iran',
    'China',
    'Canada',
    'Belgium',
    'Peru',
    'India',
    'Netherlands',
    'Switzerland',
    'Ecuador',
    'Saudi Arabia',
    'Portugal',
    'Mexico',
    'Sweden',
    'Ireland',
    'Pakistan',
    'Chile',
    'Singapore',
    'Belarus',
    'Israel',
    'Qatar',
    'Austria',
    'Japan',
    'UAE',
    'Poland',
    'Romania',
    'Ukraine',
    'Indonesia',
    'S. Korea',
    'Bangladesh',
    'Denmark',
    'Philippines',
    'Serbia',
    'Dominican Republic',
    'Norway',
    'Czechia',
    'Colombia',
    'Panama',
    'Australia',
    'South Africa',
    'Egypt',
    'Malaysia',
    'Finland',
    'Kuwait',
    'Morocco',
    'Argentina',
    'Algeria',
    'Moldova',
    'Kazakhstan',
    'Luxembourg',
    'Bahrain',
    'Hungary',
    'Thailand',
    'Afghanistan',
    'Oman',
    'Greece',
    'Nigeria',
    'Armenia',
    'Iraq',
    'Uzbekistan',
    'Ghana',
    'Croatia',
    'Cameroon',
    'Azerbaijan',
    'Bosnia',
    'Iceland',
    'Estonia',
    'Cuba',
    'Bulgaria',
    'Bolivia',
    'Guinea',
    'Macedonia',
    'New Zealand',
    'Slovenia',
    'Lithuania',
    'Slovakia',
    'Côte d\'Ivoire',
    'Senegal',
    'Djibouti',
    'Honduras',
    'Hong Kong',
    'Tunisia',
    'Latvia',
    'Cyprus',
    'Kyrgyzstan',
    'Albania',
    'Niger',
    'Andorra',
    'Lebanon',
    'Costa Rica',
    'Somalia',
    'Sri Lanka',
    'Diamond Princess',
    'Guatemala',
    'DRC',
    'Sudan',
    'Burkina Faso',
    'Uruguay',
    'Mayotte',
    'Georgia',
    'San Marino',
    'Mali',
    'El Salvador',
    'Channel Islands',
    'Maldives',
    'Malta',
    'Tanzania',
    'Jamaica',
    'Kenya',
    'Jordan',
    'Taiwan',
    'Réunion',
    'Paraguay',
    'Venezuela',
    'Palestine',
    'Gabon',
    'Mauritius',
    'Montenegro',
    'Isle of Man',
    'Equatorial Guinea',
    'Vietnam',
    'Rwanda',
    'Guinea-Bissau',
    'Tajikistan',
    'Congo',
    'Faroe Islands',
    'Martinique',
    'Sierra Leone',
    'Cabo Verde',
    'Liberia',
    'Myanmar',
    'Guadeloupe',
    'Madagascar',
    'Gibraltar',
    'Ethiopia',
    'Brunei',
    'Zambia',
    'French Guiana',
    'Togo',
    'Cambodia',
    'Chad',
    'Trinidad and Tobago',
    'Bermuda',
    'Swaziland',
    'Aruba',
    'Benin',
    'Monaco',
    'Uganda',
    'Haiti',
    'Bahamas',
    'Barbados',
    'Guyana',
    'Liechtenstein',
    'Mozambique',
    'Saint Maarten',
    'Nepal',
    'Cayman Islands',
    'Central African Republic',
    'Libyan Arab Jamahiriya',
    'French Polynesia',
    'South Sudan',
    'Macao',
    'Syrian Arab Republic',
    'Malawi',
    'Mongolia',
    'Eritrea',
    'Saint Martin',
    'Angola',
    'Zimbabwe',
    'Antigua and Barbuda',
    'Timor-Leste',
    'Botswana',
    'Grenada',
    'Belize',
    'Fiji',
    'New Caledonia',
    'Saint Lucia',
    'Gambia',
    'Saint Vincent and the Grenadines',
    'Curaçao',
    'Dominica',
    'Namibia',
    'Sao Tome and Principe',
    'Burundi',
    'Nicaragua',
    'Saint Kitts and Nevis',
    'Falkland Islands',
    'Turks and Caicos Islands',
    'Greenland',
    'Montserrat',
    'Seychelles',
    'Suriname',
    'Yemen',
    'MS Zaandam',
    'Mauritania',
    'Papua New Guinea',
    'Bhutan',
    'British Virgin Islands',
    'Caribbean Netherlands',
    'St. Barth',
    'Western Sahara',
    'Anguilla',
    'Comoros',
    'Saint Pierre Miquelon'
  ];

  //Initialize various List<GraphData> for both countries
  List<GraphData> cases1 = [];
  List<GraphData> cases2 = [];
  List<GraphData> deaths1 = [];
  List<GraphData> deaths2 = [];
  List<GraphData> recovered1 = [];
  List<GraphData> recovered2 = [];
  List<charts.Series> seriesList;

  //Using state variable graph as a place holder progress indicator until a change in state can trigger a re-render
  Widget graph = CircularProgressIndicator();

  void retrieveData() async {
    //reinitialize all fields as empty since method will be called once the dropdown is updated
    data1 = null;
    data2 = null;
    cases1 = [];
    cases2 = [];
    deaths1 = [];
    deaths2 = [];
    recovered1 = [];
    recovered2 = [];
    keys = [];

    //Define both URLs, get data from API and then parse it
    String url1 = 'https://corona.lmao.ninja/v2/historical/' + country1 +'?lastdays=90';
    String url2 = 'https://corona.lmao.ninja/v2/historical/' + country2 + '?lastdays=90';
    var results1 = await http.get(Uri.encodeFull(url1), headers: {"Accept": "application/json"});
    var results2 = await http.get(Uri.encodeFull(url2), headers: {"Accept": "application/json"});
    var resBody1 = json.decode(results1.body);
    var resBody2 = json.decode(results2.body);

    if (!mounted) return;

    setState(() {
      data1 = resBody1["timeline"];
      data2 = resBody2["timeline"];
      data1["cases"].keys.forEach((key) => keys.add(key));
    });

    //Fill in all List<GraphData> lists
    for (int i = 0; i < keys.length; i++) {
      GraphData case1 = new GraphData(i, data1["cases"][keys[i]]);
      cases1.add(case1);
      GraphData death1 = new GraphData(i, data1["deaths"][keys[i]]);
      deaths1.add(death1);
      GraphData recover1 = new GraphData(i, data1["recovered"][keys[i]]);
      recovered1.add(recover1);

      GraphData case2 = new GraphData(i, data2["cases"][keys[i]]);
      cases2.add(case2);
      GraphData death2 = new GraphData(i, data2["deaths"][keys[i]]);
      deaths2.add(death2);
      GraphData recover2 = new GraphData(i, data2["recovered"][keys[i]]);
      recovered2.add(recover2);
    }
  }

  //return the appropriate series for the graph creator
  List<charts.Series<GraphData, int>> _createCovidData() {
    if(type == 'cases') {
      return [
        new charts.Series<GraphData, int>(
          id: 'cases1',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: cases1,
        ),
        new charts.Series<GraphData, int>(
          id: 'cases2',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: cases2,
        ),
      ];
    } if (type == 'deaths') {
      return [
        new charts.Series<GraphData, int>(
          id: 'deaths1',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: deaths1,
        ),
        new charts.Series<GraphData, int>(
          id: 'deaths2',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: deaths2,
        ),
      ];
    } return [
        new charts.Series<GraphData, int>(
          id: 'recovered1',
          colorFn: (_, __) => charts.MaterialPalette.blue.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: recovered1,
        ),
        new charts.Series<GraphData, int>(
          id: 'recovered2',
          colorFn: (_, __) => charts.MaterialPalette.red.shadeDefault,
          domainFn: (GraphData data, _) => data.date,
          measureFn: (GraphData data, _) => data.value,
          data: recovered2,
        ),
      ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Compare Countries", style: bold.copyWith(fontSize: 22)),
      ),
      body: Center(
        child: FittedBox(
          fit: BoxFit.fitHeight,
          child: Container(
            margin: EdgeInsets.all(10),
            child: Center(
              child: Column(
                children: <Widget>[
                  DropdownButton<String>(
                    items: countries.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        country1 = value;
                      });
                      this.retrieveData();
                      seriesList = _createCovidData();
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return countries.map<Widget>((String item) {
                        return Text(item, style: normal);
                      }).toList();
                    },
                    value: country1,
                    elevation: 2,
                    underline: Container(
                      height: 2,
                      color: WHITE,
                    ),
                    style: normal.copyWith(color: BLACK),
                  ),
                  HEIGHT_SPACER,
                  Text("vs.", style: normal),
                  DropdownButton<String>(
                    items: countries.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        country2 = value;
                      });
                      this.retrieveData();
                      seriesList = _createCovidData();
                    },
                    selectedItemBuilder: (BuildContext context) {
                      return countries.map<Widget>((String item) {
                        return Text(item, style: normal);
                      }).toList();
                    },
                    value: country2,
                    elevation: 2,
                    underline: Container(
                      height: 2,
                      color: WHITE,
                    ),
                    style: normal.copyWith(color: BLACK),
                  ),
                  HEIGHT_SPACER,
                  ToggleButtons(
                    children: <Widget>[
                      Container(
                          margin: EdgeInsets.all(8),
                          child: Text("Active Cases", style: bold)
                      ),
                      Container(
                          margin: EdgeInsets.all(8),
                          child: Text("Deaths", style: bold)
                      ),
                      Container(
                          margin: EdgeInsets.all(8),
                          child: Text("Recovered", style: bold)
                      ),
                    ],
                    isSelected: isSelected,
                    borderWidth: 1,
                    borderColor: GREY,
                    fillColor: DARK_RED,
                    selectedBorderColor: RED,
                    onPressed: (int index) {
                      setState(() {
                        for (int buttonIndex = 0;
                        buttonIndex < isSelected.length;
                        buttonIndex++) {
                          if (buttonIndex == index) {
                            isSelected[buttonIndex] = true;
                            type = types[buttonIndex];
                          } else {
                            isSelected[buttonIndex] = false;
                          }
                        }
                      });
                      seriesList = _createCovidData();
                    },
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
                  HEIGHT_SPACER,
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Container(
                                width: CIRCLE_WIDTH,
                                height: CIRCLE_HEIGHT,
                                decoration: BoxDecoration(
                                  color: GRAPH_BLUE,
                                  shape: BoxShape.circle,
                                ),
                                margin: EdgeInsets.only(right: 5),
                              ),
                              Text(country1, style: bold.copyWith(fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("Number of Cases", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(data1 != null ? NumberFormat.compact().format(data1["cases"][keys[keys.length - 1]]).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text("Deaths", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(data1 != null ? NumberFormat.compact().format(data1["deaths"][keys[keys.length - 1]]).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text("Recovered", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(data1 != null ? NumberFormat.compact().format(data1["recovered"][keys[keys.length - 1]]).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                      Container(
                        height: 150,
                        width:1.0,
                        color: const Color(0x44CCCCCC),
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: <Widget>[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
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
                              Text(country2, style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Text("Number of Cases", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(data2 != null ? NumberFormat.compact().format(data2["cases"][keys[keys.length - 1]]).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text("Deaths", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(data2 != null ? NumberFormat.compact().format(data2["deaths"][keys[keys.length - 1]]).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                          const SizedBox(height: 4),
                          Text("Recovered", style: TextStyle(color: Colors.white)),
                          const SizedBox(height: 4),
                          Text(data2 != null ? NumberFormat.compact().format(data2["recovered"][keys[keys.length - 1]]).toString() : '-', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                        ],
                      ),
                    ],
                  )
                ],
              ),
            ),
          )
        ),
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods
  }

  @override
  void initState() {
    super.initState();
    this.retrieveData();
    seriesList = _createCovidData();
  }
}
