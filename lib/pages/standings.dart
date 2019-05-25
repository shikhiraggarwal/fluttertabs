import 'package:flutter/material.dart';
import 'package:crictfever/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:admob_flutter/admob_flutter.dart';

class Standings extends StatefulWidget {
  @override
  StandingsState createState() => new StandingsState();
}

class StandingsState extends State<Standings> {
  @override
  void initState() {
    getStandings();
    Admob.initialize(adAppID);
    super.initState();
  }

  String standings;

  Future<void> getStandings() async {
    String apiUrl = baseUrl + '/prizes/index.json';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      standings = "Fixtures data unavailable";
    }
    if (mounted) {
      setState(() {
        standings = response.body;
      });
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF412d35),
        title: Text(
          "ICC World Cup 2019 Standings",
          style: TextStyle(color: Color(0xFFf7e0c8)),
        ),
        iconTheme: IconThemeData(color: Color(0xFFf7e0c8)),
      ),
      body: Center(
        child: Text(
          "Coming soon...",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
