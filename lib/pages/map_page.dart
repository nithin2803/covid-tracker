import 'dart:async';
import 'dart:collection';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'country_page.dart';

class MapPage extends StatefulWidget {
  @override
  _MapPageState createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  bool isMapCreated = false;
  GoogleMapController _controller;
  List data;
  Set<Circle> circles = HashSet<Circle>();
  var selectedCountry;

  Future<String> getCovidData() async {
    String url = 'https://corona.lmao.ninja/v2/countries?sort=cases';
    var results = await http.get(
        Uri.encodeFull(url), headers: {"Accept": "application/json"});

    if (!mounted) return "";

    setState(() {
      var resBody = json.decode(results.body);
      data = resBody;
    });

    setMarkers();

    return 'Success!';
  }

  static CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(0, 0),
    zoom: -50,
  );


  changeMapMode() {
    getJsonFile('assets/mapStyle.json').then((style) => setMapStyle(style));
  }

  Future<String> getJsonFile(String path) async {
    return await rootBundle.loadString(path);
  }

  void setMapStyle(String mapStyle) {
    _controller.setMapStyle(mapStyle);
  }


  @override
  Widget build(BuildContext context) {
    if(isMapCreated) {
      changeMapMode();
    }
    print(selectedCountry);
    return Scaffold(
      appBar: AppBar(
        title: Text("World Map",
            style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: Center (
        child: Stack(
              children: <Widget>[
                GoogleMap(
                  mapType: MapType.normal,
                  initialCameraPosition: _kGooglePlex,
                  circles: circles,
                  onMapCreated: (GoogleMapController controller) {
                    _controller = controller;
                    isMapCreated = true;
                    changeMapMode();
                  },
                ),
                summary(),
              ],
            ),
        ),
    );
  }

  Widget summary() {
    return InkWell(
      onTap: () {
        if(selectedCountry != null) {
          Navigator.push(
            context,
            new MaterialPageRoute(
                builder: (context) => new CountryPage(selectedCountry)),
          );
        }
      },
      child: FittedBox(
        fit: BoxFit.contain,
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0x66000030),
            border: Border.all(
              color: const Color(0xff000063),
              width: 2,
            ),
          ),
          margin: EdgeInsets.all(5),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                Text((selectedCountry == null) ? 'Country' : selectedCountry["country"].toString(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                const SizedBox(height: 10),
                Text((selectedCountry == null) ? '_____' : 'Cases: ' + NumberFormat.decimalPattern("en_US").format(selectedCountry["cases"]).toString(), style: TextStyle(color: Colors.white, fontSize: 13)),
                const SizedBox(height: 5),
                Text((selectedCountry == null) ? '_____' : 'Deaths: ' + NumberFormat.decimalPattern("en_US").format(selectedCountry["deaths"]).toString(), style: TextStyle(color: Colors.white, fontSize: 13)),
              ],
            ),
          ),
        ),
      )
    );
  }

  void setMarkers() {
    Set<Circle> circleAdder = HashSet<Circle>();
    for(int i = 0; i < data.length; i++) {
      circleAdder.add(
        Circle(
          circleId: CircleId(data[i]["countryInfo"]["_id"].toString()),
          center: LatLng(data[i]["countryInfo"]["lat"].toDouble(), data[i]["countryInfo"]["long"].toDouble()),
          radius: sqrt(data[i]["cases"]) * 1000,
          strokeWidth: 2,
          consumeTapEvents: true,
          strokeColor: Color.fromRGBO(244, 67, 54, 1.0),
          fillColor: Color.fromRGBO(244, 67, 54, .5),
          onTap: () {
            setState(() {
              selectedCountry = data[i];
            });
            _controller.animateCamera(
              CameraUpdate.newLatLngZoom(
                LatLng(data[i]["countryInfo"]["lat"].toDouble(), data[i]["countryInfo"]["long"].toDouble()),
                3.0,
              )
            );
          }
        ),
      );
    }
    setState(() {
      circles = circleAdder;
    });
  }



  @override
  void initState() {
    super.initState();
    this.getCovidData();
  }
}