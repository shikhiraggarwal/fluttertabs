import 'package:flutter/material.dart';
import 'package:crictfever/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:admob_flutter/admob_flutter.dart';

class Fixtures extends StatefulWidget {
  @override
  FixturesState createState() => new FixturesState();
}

class FixturesState extends State<Fixtures> {
  @override
  void initState() {
    getFixtures();
    getTeams();
    Admob.initialize(adAppID);
    super.initState();
  }

  List fixtures;
  bool available = false;

  Future<void> getFixtures() async {
    String apiUrl = baseUrl + '/terms/fixtures.json';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode != 200) {
      available = false;
    }
    if (mounted) {
      setState(() {
        available = true;
        fixtures = jsonDecode(response.body);
      });
    }
  }

  List teams;
  bool available2 = false;

  Future<void> getTeams() async {
    String apiUrl = baseUrl + '/terms/teams.json';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode != 200) {
      available2 = false;
    }
    if (mounted) {
      setState(() {
        available2 = true;
        teams = jsonDecode(response.body);
      });
    }
  }

  var formatter = new DateFormat('d MMMM').add_jm();

  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF412d35),
        title: Text(
          "ICC World Cup 2019 Fixtures",
          style: TextStyle(color: Color(0xFFf7e0c8)),
        ),
        iconTheme: IconThemeData(color: Color(0xFFf7e0c8)),
      ),
      body: available && available2
          ? new Container(
              child: Center(
              child: ListView.separated(
                  itemBuilder: (BuildContext context, i) {
                    return ListTile(
                      subtitle: Container(
                        alignment: Alignment.center,
                        color: fixtures[i]["team2"] == 1 ||
                                fixtures[i]["team1"] == 1
                            ? Color(0xFFd8e091)
                            : Color(0xFFf7e0c8),
                        margin: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 0.0),
                        child: Text(
                          "Match time: " +
                              formatter
                                  .format(
                                      DateTime.parse(fixtures[i]["matchtime"])
                                          .toLocal())
                                  .toString(),
                          style: TextStyle(
                              color: Color(0xFF412d35),
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2.0),
                        ),
                      ),
                      title: Container(
                        padding: EdgeInsets.all(10.0),
                        color: fixtures[i]["team2"] == 1 ||
                                fixtures[i]["team1"] == 1
                            ? Color(0xFFd8e091)
                            : Color(0xFFf7e0c8),
                        margin: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
                        child: new Row(
                          children: <Widget>[
                            Expanded(
                              child: Column(
                                children: [
                                  fixtures[i]["team1"] != 11
                                      ? Image.network(
                                          baseUrl +
                                              teams[fixtures[i]["team1"] - 1]
                                                  ["image"],
                                          width: 55.0)
                                      : Icon(
                                          FontAwesomeIcons.lock,
                                          size: 55.0,
                                          color: Color(0xFF7ea4bc),
                                        ),
                                  Text(teams[fixtures[i]["team1"] - 1]["name"],
                                      style: TextStyle(
                                          color: Color(0xFF412d35),
                                          fontSize: 20.0,
                                          letterSpacing: 2.0)),
                                ],
                              ),
                            ),
                            Container(
                              width: 50.0,
                              child: Center(
                                child: Text(
                                  "vs",
                                  style: TextStyle(
                                      color: Color(0xFF412d35),
                                      fontSize: 25.0,
                                      fontStyle: FontStyle.italic,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            Expanded(
                              child: Column(
                                children: [
                                  fixtures[i]["team1"] != 11
                                      ? Image.network(
                                          baseUrl +
                                              teams[fixtures[i]["team2"] - 1]
                                                  ["image"],
                                          width: 55.0)
                                      : Icon(
                                          FontAwesomeIcons.lock,
                                          size: 55.0,
                                          color: Color(0xFF7ea4bc),
                                        ),
                                  Text(teams[fixtures[i]["team2"] - 1]["name"],
                                      style: TextStyle(
                                          color: Color(0xFF412d35),
                                          fontSize: 20.0,
                                          letterSpacing: 2.0)),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, i) {
                    if ((i - 4) % 5 != 0) {
                      return Divider(
                        color: Colors.blueGrey,
                        height: 0.0,
                      );
                    } else {
                      return Column(
                        children: <Widget>[
                          Divider(
                            color: Colors.green,
                            height: 0.0,
                          ),
                          ListTile(
                            title: Container(
                              color: Colors.white,
                              height: 100.0,
                              child: new AdmobBanner(
                                adUnitId: bannerAdID,
                                adSize: AdmobBannerSize.LARGE_BANNER,
                              ),
                            ),
                          ),
                          Divider(
                            color: Colors.green,
                            height: 0.0,
                          ),
                        ],
                      );
                    }
                  },
                  itemCount: fixtures.length),
            ))
          : Center(
              child: CircularProgressIndicator(),
            ),
    );
  }
}
