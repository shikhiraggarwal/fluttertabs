import 'package:flutter/material.dart';
import 'package:crictfever/tabs/rank.dart';
import 'package:crictfever/tabs/guess.dart';
import 'package:crictfever/tabs/share.dart';
import 'package:crictfever/tabs/profile.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:unique_identifier/unique_identifier.dart';
import 'package:http/http.dart' as http;
import 'package:crictfever/data.dart';
import 'dart:convert';


void main() {
  runApp(new MaterialApp(
      title: "Crictfever",
      // Home
      home: new MyHome()));
}

class MyHome extends StatefulWidget {
  @override
  MyHomeState createState() => new MyHomeState();
}

// SingleTickerProviderStateMixin is used for animation
class MyHomeState extends State<MyHome> with SingleTickerProviderStateMixin {
  /*
   *-------------------- Setup Tabs ------------------*
   */
  // Create a tab controller
  TabController controller;

  String _identifier = '';

  Data _data = new Data();

  @override
  void initState() {
    super.initState();
    initUniqueIdentifierState();
    // Initialize the Tab Controller
    controller = new TabController(length: 4, vsync: this);
  }

  bool error = false;

  Future<String> createUser(deviceId) async {
    String apiUrl = baseUrl + '/players/new.json?device_id=' + deviceId + '&version=1';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      error = true;
    }
    return response.body;
  }
  bool update = false;
  Future<void> initUniqueIdentifierState() async {
    String identifier;
    String response;
    try {
      identifier = await UniqueIdentifier.serial;
      response = await createUser(identifier);
    } on Exception {
      identifier = null;
    }

    if (!mounted && response == null) return;

    setState(() {
      _identifier = identifier;
      if (response != null && identifier != null) {
        Map myData = jsonDecode(response);
        update = myData["update"] == "true";
        _data = Data(
            deviceId: _identifier,
            id: myData["id"],
            name: myData["name"],
            points: myData["points"],
            myData: response,
            shareId: myData["share_code"]);
      } else {
        initUniqueIdentifierState();
      }
    });
  }

  @override
  void dispose() {
    // Dispose of the Tab Controller
    controller.dispose();
    super.dispose();
  }

  TabBar getTabBar() {
    return new TabBar(
      tabs: <Tab>[
        new Tab(
          // set icon to the tab
          icon: new Icon(FontAwesomeIcons.medal, color: new Color(0xFFf7e0c8)),
          text: "Ranks",
        ),
        new Tab(
          icon: new Icon(FontAwesomeIcons.dice, color: new Color(0xFFf7e0c8)),
          text: "Play",
        ),
        new Tab(
          icon: new Icon(FontAwesomeIcons.shareAlt, color: new Color(0xFFf7e0c8)),
          text: "Share",
        ),
        new Tab(
          icon: new Icon(FontAwesomeIcons.userCircle, color: new Color(0xFFf7e0c8)),
          text: "Profile",
        ),
      ],
      // setup the controller
      controller: controller,
      indicatorColor: new Color(0xFFf7e0c8),
      indicatorWeight: 2.8,
    );
  }

  TabBarView getTabBarView(var tabs) {
    return new TabBarView(
      // Add tabs as widgets
      children: tabs,
      // set the controller
      controller: controller,
    );
  }

  /*
   *-------------------- Setup the page by setting up tabs in the body ------------------*
   */
  @override
  Widget build(BuildContext context) {
    if (_data.deviceId != null && !error && !update) {
      return new Scaffold(
          // Appbar
          appBar: new AppBar(
              // Title
              title: new Row(
                children: <Widget>[
                  Text("C", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("r", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("i", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Colors.red)),
                  Text("c", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("k", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("e", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("t", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("f", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("e", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("v", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("e", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                  Text("r", style: TextStyle(fontFamily: "CartoonUS", fontSize: 40.0, color: Color(0xFFf7e0c8))),
                ],
              ),
              // Set the background color of the App Bar
              backgroundColor: new Color(0xFF412d35), // Color(0xFF42A5F5)
              // Set the bottom property of the Appbar to include a Tab Bar
              bottom: getTabBar()),
          // Set the TabBar view as the body of the Scaffold
          body: getTabBarView(<Widget>[
            new Rank(data: _data),
            new Guess(data: _data),
            new Share(data: _data),
            new Profile(data: _data)
          ]));
    } else if (update) {
      return new Center(child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          new CircularProgressIndicator(),
          new Text("App update available. Please update from Playstore/Appstore", style: TextStyle(color: Colors.yellow, fontSize: 15.0, decoration: TextDecoration.underline), textAlign: TextAlign.center,)
        ],
      ),);
    } else {
      return new Center(child: new CircularProgressIndicator());
    }
  }
}
