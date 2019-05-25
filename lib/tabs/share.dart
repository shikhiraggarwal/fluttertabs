import 'package:flutter/material.dart';
import 'package:crictfever/data.dart';
import 'package:crictfever/prize_dialog.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:admob_flutter/admob_flutter.dart';
import 'package:flutter_share_me/flutter_share_me.dart';

class Share extends StatefulWidget {
  @override
  Data data;

  Share({Key key, this.data}) : super(key: key);

  ShareState createState() => new ShareState();
}

class ShareState extends State<Share> {
  BuildContext _scaffoldContext;
  bool _rewardVideoLoaded;
  AdmobReward rewardAd;
  bool generateReward = false;
  @override
  void initState() {
    getRewards();createUser();getTermsData();
    Admob.initialize(adAppID);

    rewardAd = AdmobReward(
        adUnitId: rewardAdID,
        listener: (AdmobAdEvent event, Map<String, dynamic> args) {
          if (event == AdmobAdEvent.rewarded) {
            print("rewarding");
            generateReward = true;
          } else if (event == AdmobAdEvent.loaded) {
            print("loaded");
            _rewardVideoLoaded = true;
          } else if (event == AdmobAdEvent.opened) {
            print("opened");
          } else if (event == AdmobAdEvent.started) {
            print("started");
          } else if (event == AdmobAdEvent.leftApplication) {
            print("left");
          } else if (event == AdmobAdEvent.completed) {
            print("completed");
            if (generateReward) {
              generateReward = false;
              add25RewardPoints();
              rewardAd.dispose();
            }
          } else if (event == AdmobAdEvent.closed) {
            print("closed");
            if (generateReward) {
              generateReward = false;
              add25RewardPoints();
              rewardAd.dispose();
            } else {
              Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
                content: new Text('Failed to generate ad reward try after some time'),
                duration: new Duration(seconds: 5),
              ));
              rewardAd.dispose();
            }
          } else {
            print("else");
          }
        });
    rewardAd.load();
    super.initState();
  }

  Future<void> createUser() async {
    String apiUrl = baseUrl + '/players/new.json?device_id=' + widget.data.deviceId;
    final response = await http.get(apiUrl);
    Map myData = jsonDecode(response.body);
    widget.data = Data(
        deviceId: widget.data.deviceId,
        id: myData["id"],
        name: myData["name"],
        points: myData["points"],
        myData: response.body,
        shareId: myData["share_code"]);
  }

  String rewards;
  String termsNConditions;
  Future<void> getRewards() async {
    String apiUrl = baseUrl + '/prizes/index.json';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      rewards = "Rewards data unavailable";
    }
    if (mounted) {
      setState(() {
        rewards = response.body;
      });
    }
  }

  Future<void> add25RewardPoints() async {
    String apiUrl = baseUrl + '/prizes/adreward.json?id='+widget.data.id.toString();
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
        content: new Text('Error fetching reward data'),
        duration: new Duration(seconds: 5),
      ));
    } else {
      Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
        content: new Text('You were rewarded 25 bonus points'),
        duration: new Duration(seconds: 5),
      ));
      setState(() {
        widget.data.points = widget.data.points + 25;
      });
    }
  }

  Future<void> playRewardAd() async {
    if (await rewardAd.isLoaded) {
      rewardAd.show();
    } else {
      Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
        content: new Text('Ad failed to load try again'),
        duration: new Duration(seconds: 5),
      ));
      rewardAd = AdmobReward(
          adUnitId: rewardAdID,
          listener: (AdmobAdEvent event, Map<String, dynamic> args) {
            if (event == AdmobAdEvent.rewarded) {
              print("rewarded");
            } else if (event == AdmobAdEvent.loaded) {
              _rewardVideoLoaded = true;
            }
          });
      rewardAd.load();
    }
  }

  Future<void> getTermsData() async {
    String apiUrl = baseUrl + '/terms/index.json';
    final response = await http.get(apiUrl);
    final int statusCode = response.statusCode;
    if (statusCode < 200 || statusCode > 400 || response == null) {
      termsNConditions = "Terms data unavailable";
    }
    if (mounted) {
      setState(() {
        termsNConditions = response.body;
      });
    }
  }

  Widget getTerms(){
    if (termsNConditions == null) {
      return new Center(child: new CircularProgressIndicator());
    }
    List terms = jsonDecode(termsNConditions);
    Widget listView = new Expanded(
      child: ListView.builder(
        itemCount: terms.length,
        itemBuilder: (BuildContext context, int i) {
          return ListTile(
            leading: Icon(FontAwesomeIcons.solidCircle, size: 10.0,),
            title: Text(
              terms[i]["term"].toString(),
              style: TextStyle(color: Colors.grey[700]),
            ),
          );
        },
      ),
    );
    return listView;
  }

  Widget getRewardsTable(rewards) {
    if (rewards == null) {
      return new Center(child: new CircularProgressIndicator());
    }
    rewards = jsonDecode(rewards);
    Widget listView = new Expanded(
      child: ListView.builder(
        itemCount: rewards.length,
        itemBuilder: (BuildContext context, int i) {
          return ListTile(
            leading: Text(
              rewards[i]["id"].toString(),
              style: TextStyle(color: Colors.grey[700]),
            ),
            title: Text(
              rewards[i]["name"],
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold),
            ),
            trailing: i == 0
                ? Text("Rank " + rewards[i]["rank_start"].toString())
                : Text("Ranks " +
                    rewards[i]["rank_start"].toString() +
                    " to " +
                    rewards[i]["rank_end"].toString()),
            dense: true,
          );
        },
      ),
    );
    return listView;
  }

  Future<void> shareWhatsApp(msg) async{
    var response = await FlutterShareMe().shareToSystem(msg: 'Bet and win brand new Hyundai Venue. Download the app from playstore and enter my code in profile. I get 200 points and you get 100 points. My code is *'+msg+'* https://play.google.com/store/apps/details?id=com.crictfever.crictfever');
    print(response);
  }

  Widget build(BuildContext context) {
    _scaffoldContext = context;
    return new SingleChildScrollView(
      child: Container(
        child: new Column(
          // center the children
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            new Container(
              child: Text(
                "Your Points: " + widget.data.points.toString(),
                style: TextStyle(
                    color: Color(0xFF5b1616),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
//              color: Color(0xFF5b1616),
              padding: EdgeInsets.all(20.0),
            ),
            new Container(
              child: Text(
                "Share your code to get 200 bonus points and they get 100 bonus points",
                style: TextStyle(
                    color: Colors.blueGrey, fontSize: 20.0, letterSpacing: 1.8),
                textAlign: TextAlign.center,
              ),
              width: 260.0,
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 10.0),
            ),
            CircleAvatar(
              backgroundColor: Color(0xFF412d35),
              radius: 120.0,
              child: Container(
                padding: EdgeInsets.fromLTRB(0.0, 50.0, 0.0, 0.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      widget.data.shareId,
                      style: TextStyle(
                          color: new Color(0xFFf7e0c8),
                          fontSize: 49.0,
                          fontFamily: "Inconsolata",
                          letterSpacing: 3.0),
                    ),
                    Container(
                      child: FlatButton(
                        child: Text("Tap here to share",style: TextStyle(
                            color: new Color(0xFFf7e0c8),
                            fontSize: 10.0,
                            letterSpacing: 2.0),),
                        onPressed: () => shareWhatsApp(widget.data.shareId),
                      ),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 15.0),
                    ),
                  ],
                )
              ),
            ),
            new Container(
              child: new Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Play a video ad and win 25 points before your next bid",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 20.0,
                        letterSpacing: 1.8),
                    textAlign: TextAlign.center,
                  ),
                  FlatButton(
                    color: Color(0xFFEFEFEF),
                    onPressed: () => playRewardAd(),
                    child: Text(
                      "PLAY AD",
                      style: TextStyle(fontSize: 12.0),
                    ),
                    textColor: Colors.blueGrey,
                    padding: EdgeInsets.all(10.0),
                  ),
                  Text(
                    "Each point matters",
                    style: TextStyle(
                        color: Colors.blueGrey,
                        fontSize: 14.0,
                        letterSpacing: 1.8),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              height: 150.0,
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 10.0),
            ),
            new Container(
              child: FlatButton(
                color: Color(0xFFEFEFEF),
                onPressed: () => showDialog(
                      context: context,
                      builder: (BuildContext context) => PrizeDialog(
                            title: "REWARDS",
                            description: getRewardsTable(rewards),
                            buttonText: "Great!!",
                          ),
                    ),
                child: Text(
                  "SEE REWARDS",
                  style: TextStyle(fontSize: 22.0),
                ),
                textColor: Colors.blueGrey,
                padding: EdgeInsets.all(10.0),
              ),
            ),
            new Container(
              child: FlatButton(
                onPressed: () => showDialog(
                  context: context,
                  builder: (BuildContext context) => PrizeDialog(
                    title: "Terms",
                    description: getTerms(),
                    buttonText: "I have read and agreed",
                  ),
                ),
                child: Text(
                  "Terms and Conditions",
                  style: TextStyle(fontSize: 12.0, fontStyle: FontStyle.italic),
                ),
                textColor: Colors.blueGrey,
                padding: EdgeInsets.all(5.0),
              ),
            ),
            Container(
              height: 50.0,
              width: 320,
              padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.5),
              child: AdmobBanner(
                adUnitId: bannerAdID,
                adSize: AdmobBannerSize.BANNER,
              ),
            )
          ],
        ),
      ),
    );
  }
}
