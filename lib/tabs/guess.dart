import 'package:flutter/material.dart';
import 'package:crictfever/data.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:admob_flutter/admob_flutter.dart';
import 'package:intl/intl.dart';

class Guess extends StatefulWidget {
  @override
  Data data;

  Guess({Key key, this.data}) : super(key: key);

  GuessState createState() => new GuessState();
}

class GuessState extends State<Guess> {
  BuildContext _scaffoldContext;

  @override
  void initState() {
    getBetTeam();
    getOpenBets();
    Admob.initialize(adAppID);

    super.initState();
  }

  bool bettableGame = false;
  Map bettableGameData;

  Future<void> getBetTeam() async {
    String apiUrl = baseUrl + '/prizes/get_bettable_game.json';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      bettableGame = false;
    }
    if (mounted) {
      setState(() {
        bettableGameData = jsonDecode(response.body);
        if (bettableGameData["teams"] == null) {
          bettableGame = false;
        } else {
          bettableGame = true;
        }
      });
    }
  }

  List openBetsData;

  Future<void> getOpenBets() async {
    String apiUrl =
        baseUrl + '/bets/index.json?id=' + widget.data.id.toString();
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      openBetsData = null;
    }
    if (mounted) {
      setState(() {
        if (response.body != "[]") {
          openBetsData = jsonDecode(response.body);
        } else {
          openBetsData = null;
        }
      });
    }
  }

  var team1Data;
  var team2Data;
  var team1ID;
  var team2ID;

  Widget getGameWidget() {
    if (bettableGame) {
      team1ID = bettableGameData["game"]["team1"];
      team2ID = bettableGameData["game"]["team2"];
      var teams = bettableGameData["teams"];

      teams.forEach((element) {
        if (element["id"] == team1ID) {
          team1Data = element;
        } else if (element["id"] == team2ID) {
          team2Data = element;
        }
      });
      var formatter = new DateFormat('d MMMM').add_jm();
      var tempDate =
          DateTime.parse(bettableGameData["game"]["matchtime"]).toLocal();
      var parsedDate = formatter.format(tempDate);
      return Column(
        children: <Widget>[
          Container(
            padding: EdgeInsets.all(10.0),
            height: 120.0,
            color: Color(0xFFf7e0c8),
            margin: EdgeInsets.fromLTRB(1.0, 1.0, 1.0, 0.0),
            child: new Row(
              children: <Widget>[
                Expanded(
                  child: Column(
                    children: [
                      Image.network(baseUrl + team1Data["image"], width: 55.0),
                      Text(team1Data["name"],
                          style: TextStyle(
                              color: Color(0xFF412d35),
                              fontSize: 20.0,
                              letterSpacing: 2.0)),
                      Text(
                          "Score Multiplier: " +
                              bettableGameData["game"]["winteam1"],
                          style: TextStyle(
                              color: Color(0xFF412d35),
                              fontSize: 10.0,
                              fontStyle: FontStyle.italic))
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
                      Image.network(baseUrl + team2Data["image"], width: 55.0),
                      Text(
                        team2Data["name"],
                        style: TextStyle(
                          color: Color(0xFF412d35),
                          fontSize: 20.0,
                          letterSpacing: 2.0,
                        ),
                      ),
                      Text(
                        "Score Multiplier: " +
                            bettableGameData["game"]["winteam2"],
                        style: TextStyle(
                          color: Color(0xFF412d35),
                          fontSize: 10.0,
                          fontStyle: FontStyle.italic,
                        ),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.all(2.0),
            height: 20.0,
            color: Color(0xFFf7e0c8),
            margin: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 1.0),
            child: Center(
              child: Text(
                "Game on " + parsedDate.toString(),
                style: TextStyle(
                  color: Color(0xFF412d35),
                  fontSize: 9.0,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 2.0,
                ),
              ),
            ),
          ),
        ],
      );
    } else {
      return Container(
        padding: EdgeInsets.all(10.0),
        height: 120.0,
        color: Color(0xFFf7e0c8),
        margin: EdgeInsets.all(1.0),
        child: Center(
          child: Text(
            "Loading game...",
            style: TextStyle(
              color: Color(0xFF412d35),
              fontSize: 25.0,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }

  Widget getBettingWidget() {
    if (bettableGame) {
      return Container(
        padding: EdgeInsets.all(2.0),
        height: 20.0,
        color: Color(0xFF412d35),
        margin: EdgeInsets.fromLTRB(0.5, 0.0, 0.5, 1.0),
        child: Center(
          child: Text(
            "Place Bet",
            style: TextStyle(
                color: Color(0xFFf7e0c8),
                fontSize: 12.0,
                fontWeight: FontWeight.bold),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  var selectedTeam = 0;

  void _ChangeTeam(int value) {
    setState(() {
      selectedTeam = value;
    });
  }

  var betPoints = 0;

  void _ChangePointsValue(String value) {
    betPoints = int.parse(value);
  }

  bool _saving = false;

  Future<void> placeBet() async {
    setState(() {
      _saving = true;
    });
    String url = baseUrl + "/bets/place.json";
    Map body = new Map();
    body["id"] = widget.data.id.toString();
    body["points"] = betPoints.toString();
    body["match_id"] = bettableGameData["game"]["id"].toString();
    body["team_id"] = selectedTeam.toString();
    http.post(url, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;
      Map bodyJson = jsonDecode(response.body);
      if (statusCode < 200 || statusCode > 400) {
        Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
          content: new Text('Unable to place bet'),
          duration: new Duration(seconds: 5),
        ));
      } else {
        Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
          content: new Text(bodyJson["message"]),
          duration: new Duration(seconds: 5),
        ));
      }
      if (this.mounted) {
        setState(() {
          _saving = false;
          getBetTeam();
          getOpenBets();
        });
      }
    });
  }

  Widget getBettingFormWidget() {
    if (bettableGame) {
      return SingleChildScrollView(
        child: Center(
          child: Form(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Container(
                  child: Row(
                    children: <Widget>[
                      new Expanded(
                        child: FlatButton(
                            onPressed: () => _ChangeTeam(team1ID),
                            child: Row(
                              children: <Widget>[
                                Image.network(baseUrl + team1Data["image"],
                                    width:
                                        selectedTeam == team1ID ? 35.0 : 25.0),
                                Container(
                                  width: 10.0,
                                ),
                                Text(team1Data["name"],
                                    style: TextStyle(
                                        color: selectedTeam == team1ID
                                            ? Colors.green
                                            : Color(0xFF412d35),
                                        fontSize: selectedTeam == team1ID
                                            ? 17.0
                                            : 15.0,
                                        letterSpacing: 2.0)),
                              ],
                            )),
                      ),
                      new Expanded(
                        child: FlatButton(
                            onPressed: () => _ChangeTeam(team2ID),
                            child: Row(
                              children: <Widget>[
                                Image.network(baseUrl + team2Data["image"],
                                    width:
                                        selectedTeam == team2ID ? 35.0 : 25.0),
                                Container(
                                  width: 10.0,
                                ),
                                Text(team2Data["name"],
                                    style: TextStyle(
                                        color: selectedTeam == team2ID
                                            ? Colors.green
                                            : Color(0xFF412d35),
                                        fontSize: selectedTeam == team2ID
                                            ? 17.0
                                            : 15.0,
                                        letterSpacing: 2.0)),
                              ],
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 20.0,
                      ),
                      Expanded(
                        child: TextField(
                          onChanged: (value) => _ChangePointsValue(value),
                          decoration: InputDecoration(hintText: "Points",labelText: "Points to bet"),
                          style: TextStyle(color: Colors.red, fontStyle: FontStyle.italic, letterSpacing: 1.5),
                          keyboardType: TextInputType.numberWithOptions(
                              signed: false, decimal: false),
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                        width: 100.0,
                        height: 38.0,
                        color: Color(0xFFEEEEEE),
                        child: FlatButton(
                          padding: EdgeInsets.all(5.0),
                          onPressed: () => placeBet(),
                          child: Text(
                            "Place Bet",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2.0,
                                color: Color(0xFF412d35)),
                          ),
                        ),
                      ),
                      Container(
                        child: _saving ? CircularProgressIndicator() : null,
                        width: 20.0,
                        height: 20.0,
                        margin: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 5.0),
                      )
                    ],
                  ),
                  margin: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      return Container();
    }
  }

  Widget openBetsWidget() {
    if (openBetsData == null) {
      return Container(
        padding: EdgeInsets.all(2.0),
        height: 20.0,
        color: Color(0xFFf7e0c8),
        margin: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 1.0),
        child: Center(
          child: Text(
            "No bets",
            style: TextStyle(
              color: Color(0xFF412d35),
              fontSize: 9.0,
              fontStyle: FontStyle.italic,
              letterSpacing: 2.0,
            ),
          ),
        ),
      );
    } else {
      return new Container(
        height: 100.0,
        child: ListView.builder(
            itemCount: openBetsData.length,
            itemBuilder: (BuildContext ctxt, int i) {
              return new Container(
                padding: EdgeInsets.all(2.0),
                height: 24.0,
                color: Color(0xFFf7e0c8),
                margin: EdgeInsets.fromLTRB(1.0, 0.0, 1.0, 1.0),
                child: Row(
                  children: <Widget>[
                    Expanded(
                        child: Text(
                            "Points: " + openBetsData[i]["points"].toString(),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Color(0xFF412d35),
                              fontSize: 14.0,
                              fontStyle: FontStyle.italic,
                              letterSpacing: 2.0,
                            ))),
                    Expanded(
                      child: Row(
                        children: <Widget>[
                          Text("Team: ",
                              style: TextStyle(
                                color: Color(0xFF412d35),
                                fontSize: 14.0,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2.0,
                              )),
                          Text(
                              openBetsData[i]["team"].toString() ==
                                      team1ID.toString()
                                  ? team1Data["name"]
                                  : "",
                              style: TextStyle(
                                color: Color(0xFF412d35),
                                fontSize: 14.0,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2.0,
                              )),
                          Text(
                              openBetsData[i]["team"].toString() ==
                                      team2ID.toString()
                                  ? team2Data["name"]
                                  : "",
                              style: TextStyle(
                                color: Color(0xFF412d35),
                                fontSize: 14.0,
                                fontStyle: FontStyle.italic,
                                letterSpacing: 2.0,
                              ))
                        ],
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                      ),
                    ),
                  ],
                ),
              );
            }),
      );
    }
  }

  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return new SingleChildScrollView(
      child: Container(
        child: new Column(
          // center the children
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            getGameWidget(),
            getBettingWidget(),
            getBettingFormWidget(),
            Container(
              padding: EdgeInsets.all(2.0),
              height: 20.0,
              color: Color(0xFF412d35),
              margin: EdgeInsets.fromLTRB(0.5, 0.0, 0.5, 1.0),
              child: Center(
                child: Text(
                  "Open Bets",
                  style: TextStyle(
                      color: Color(0xFFf7e0c8),
                      fontSize: 12.0,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            openBetsWidget(),
            Center(
              child: Container(
                height: 250.0,
                width: 300.0,
                color: Colors.white,
                child: AdmobBanner(
                  adUnitId: bannerAdID,
                  adSize: AdmobBannerSize.MEDIUM_RECTANGLE,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
