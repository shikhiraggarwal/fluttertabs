import 'package:flutter/material.dart';
import 'package:crictfever/data.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:admob_flutter/admob_flutter.dart';

class Rank extends StatefulWidget {
  @override
  Data data;

  Rank({Key key, this.data}) : super(key: key);

  RankState createState() => new RankState();
}

class RankState extends State<Rank> {
  Map rankData;
  ScrollController _scrollController =
      new ScrollController(initialScrollOffset: 0.0);

  @override
  void initState() {
    getRanks(widget.data.id);
    Admob.initialize(adAppID);
    super.initState();
  }

  Future<void> getRanks(id) async {
    String apiUrl = baseUrl + '/ranks/index.json?id=' + id.toString();
    final response = await http.get(apiUrl);
    if (this.mounted) {
      setState(() {
        rankData = jsonDecode(response.body);
      });
    }
  }

  void jumpToYourName(rank) {
    rank = rank.toString();
    if (rank == "0") {
      rank = jsonDecode(jsonDecode(widget.data.myData)["data"])["rank"];
    }
    rank = int.tryParse(rank);
    if (rank < 5){ rank = 5;}
    _scrollController.animateTo((rank - 5) * 56.5,
        duration: new Duration(seconds: 1), curve: Curves.ease);
  }

  Widget getNameWidget() {
    if (widget.data.name == null || widget.data.name == "") {
      return Container(child: Center(child: Text("Enter your name in profile to see in ranks", style: TextStyle(color: Colors.blueGrey, fontWeight: FontWeight.w300, letterSpacing: 1.2),),));
    } else {
      return Container();
    }
  }

  Widget build(BuildContext context) {
    if (rankData != null) {
      return new Container(
          child: new Column(
        children: <Widget>[
          new Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              new FlatButton(
                textColor: Colors.blueGrey,
                child: new Text('Your Rank'),
                onPressed: () => jumpToYourName(rankData["rank"]),
              ),
              new FlatButton(
                textColor: Colors.blueGrey,
                child: new Text('Top'),
                onPressed: () => jumpToYourName(1),
              ),
            ],
          ),
          getNameWidget(),
          new Expanded(
            child: new Center(
              child: new ListView.separated(
                  controller: _scrollController,
                  itemCount: rankData["rankings"] == null
                      ? 0
                      : rankData["rankings"].length,
                  itemBuilder: (BuildContext context, i) {
                    return new ListTile(
                      title: new Text(
                        rankData["rankings"][i]["name"].toString(),
                        style: TextStyle(
                            fontSize: 20.0,
                            letterSpacing: 2.0,
                            color: rankData["rankings"][i]["id"].toString() ==
                                    widget.data.id.toString()
                                ? Colors.red
                                : Colors.black),
                      ),
                      leading: new Text(
                        rankData["rankings"][i]["rank"].toString(),
                        style: TextStyle(
                            fontSize: 20.0,
                            color: rankData["rankings"][i]["id"].toString() ==
                                    widget.data.id.toString()
                                ? Colors.red
                                : Colors.black),
                      ),
                      trailing: new Text(
                        rankData["rankings"][i]["points"].toString(),
                        style: TextStyle(
                            fontSize: 17.0,
                            fontStyle: FontStyle.italic,
                            fontWeight: FontWeight.bold,
                            color: rankData["rankings"][i]["id"].toString() ==
                                    widget.data.id.toString()
                                ? Colors.red
                                : Colors.black),
                      ),
                    );
                  },
                  separatorBuilder: (BuildContext context, i) {
                    if ((i - 19) % 20 != 0) {
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
                          color : Colors.white,
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
                  }),
            ),
          ),
          new Container(
            child: Center(
              child: Container(
                height: 50.0,
                width: 320.0,
                color: Colors.white,
                child: AdmobBanner(
                    adUnitId: bannerAdID,
                    adSize: AdmobBannerSize.BANNER,
                ),
              ),
            ),
          )
        ],
      ));
    } else {
      return new Center(child: new CircularProgressIndicator());
    }
  }
}
