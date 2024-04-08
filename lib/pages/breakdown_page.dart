import 'package:covid_tracker/common/constants.dart';
import 'package:covid_tracker/pages/country_page.dart';
import 'package:intl/intl.dart';
import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class BreakdownPage extends StatefulWidget {
  @override
  _BreakdownPageState createState() => new _BreakdownPageState();
}

enum Types {Cases, Deaths, Recovered}

class _BreakdownPageState extends State<BreakdownPage> {
  List data;
  String type = 'cases';
  List<String> types = ['cases', 'deaths', 'recovered'];
  String titleType = 'Cases';
  List<String> titleTypes = ['Cases', 'Deaths', 'Recoveries'];

  Future<String> getCovidData(String type) async {
    data = null;
    String url = 'https://corona.lmao.ninja/v2/countries?sort=' +
        type;
    var results = await http.get(
        Uri.encodeFull(url), headers: {"Accept": "application/json"});

    if (!mounted) return "";

    setState(() {
      var resBody = json.decode(results.body);
      data = resBody;
    });

    return 'Success!';
  }

  Future<void> openDialog() async {
    int index = 0;
    await showDialog(
      barrierDismissible: true,
      context: context,
      builder: (BuildContext context) {
          return SimpleDialog(
            backgroundColor: const Color(0xFF000030),
            title: const Text("Sort By:", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  index = 0;
                  Navigator.pop(context, Types.Cases);
                },
                child: const Text("Cases", style: TextStyle(color: Colors.white),),
              ),
              SimpleDialogOption(
                onPressed: () {
                  index = 1;
                  Navigator.pop(context, Types.Deaths);
                },
                child: const Text("Deaths", style: TextStyle(color: Colors.white),),
              ),
              SimpleDialogOption(
                onPressed: () {
                  index = 2;
                  Navigator.pop(context, Types.Recovered);
                },
                child: const Text("Recovered", style: TextStyle(color: Colors.white),),
              ),
            ],
          );
        }
      );
      setState(() {
        type = types[index];
        titleType = titleTypes[index];
      });
      this.getCovidData(types[index]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Text(titleType + " by Country",
                style: TextStyle(fontWeight: FontWeight.w800)),
            FlatButton(
              child: Icon(Icons.sort, color: Colors.white),
              onPressed: () {
                openDialog();
              },
            ),
          ],
        ),
      ),
      body: (data == null) ? Center(
        child: CircularProgressIndicator(),
      ) :
      ListView.separated(
        separatorBuilder: (context, index) => Divider(
          color: const Color(0x55FFFFFF),
        ),
        itemCount: data == null ? 0 : data.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  new MaterialPageRoute(
                      builder: (context) => new CountryPage(data[index])),
                );
              },
            child: ListTile(
              leading: Container(
                height: 20.0,
                width: 28.0,
                decoration: new BoxDecoration(
                  image: DecorationImage(
                    image: new NetworkImage(
                        data[index]["countryInfo"]['flag']),
                    fit: BoxFit.fill,
                  ),
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
              title: Text(data[index]["country"], style: bold.copyWith(fontSize: 18)),
              trailing: Text(NumberFormat.compact().format(data[index][type]).toString(), style: normal.copyWith(fontSize: 16)),
            ),
          );
        },
      ),
    ); // This trailing comma makes auto-formatting nicer for build methods
  }

  @override
  void initState() {
    super.initState();
    this.getCovidData(type);
  }
}


