import 'package:flutter/material.dart';
import 'package:crictfever/data.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Profile extends StatefulWidget {
  @override
  Data data;

  Profile({Key key, this.data}) : super(key: key);

  ProfileState createState() => new ProfileState();
}

class _ProfileData {
  String name = '';
  String email = '';
  String phone = '';
  String pincode = '';
  String address = '';
  String street = '';
  String state = '';
  String city = '';
  String share = '';
}

class ProfileState extends State<Profile> {
  BuildContext _scaffoldContext;

  @override
  void initState() {
    super.initState();

  }

  bool _saving = false;

  void submitProfileInfo(id) async{
    Map profileMap = new Map();
    profileMap["id"] = id.toString();
    profileMap["name"] = profileData.name;
    profileMap["email"] = profileData.email;
    profileMap["phone"] = profileData.phone;
    profileMap["pincode"] = profileData.pincode;
    profileMap["address"] = profileData.address;
    profileMap["street"] = profileData.street;
    profileMap["state"] = profileData.state;
    profileMap["city"] = profileData.city;
    profileMap["share"] = profileData.share;
    await updatePlayer(profileMap);
  }

  Future<void> updatePlayer(Map body) async {
    setState(() {
      _saving = true;
    });
    String url = baseUrl + "/players/update.json";
    http.post(url, body: body).then((http.Response response) {
      final int statusCode = response.statusCode;
      print(statusCode);
      Map bodyJson = jsonDecode(response.body);
      if (statusCode != 200) {
        Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
          content: new Text('Unable to save information'),
          duration: new Duration(seconds: 5),
        ));
        _saving = false;
      } else {
        if (bodyJson["error"] != null) {
          Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
            content: new Text(bodyJson["error"]),
            duration: new Duration(seconds: 5),
          ));
          _saving = false;
        } else {
          Scaffold.of(_scaffoldContext).showSnackBar(new SnackBar(
            content: new Text('Your information is saved'),
            duration: new Duration(seconds: 5),
          ));
          _saving = false;
        }
      }
      if (this.mounted && bodyJson["error"] == null) {
        setState(() {
          widget.data.myData = response.body;
          _saving = false;
        });
      }
    });
  }

  _ProfileData profileData = new _ProfileData();

  final _playerProfile = GlobalKey<FormState>();

  Widget build(BuildContext context) {
    _scaffoldContext = context;
    Map myData = jsonDecode(widget.data.myData);
    Map dataBlob = jsonDecode(myData["data"]);
    profileData.name = myData["name"];
    profileData.email = myData["email"];
    profileData.pincode = myData["pincode"];
    profileData.phone = myData["phone"];
    profileData.address = dataBlob["address"];
    profileData.street = dataBlob["street"];
    profileData.state = dataBlob["state"];
    profileData.city = dataBlob["city"];
    profileData.share = dataBlob["share"];
    return SingleChildScrollView(
      child: Center(
        child: Form(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.idBadge, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        style: TextStyle(letterSpacing: 1.2),
                        decoration: InputDecoration(hintText: "Name", labelText: "Name"),
                        initialValue: myData["name"],
                        validator: (value) {
                          if (value.length > 20) {
                            return 'Length should be less than 20';
                          }
                        },
                        onSaved: (value) => profileData.name = value,
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.envelope, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: myData["email"],
                        keyboardType: TextInputType.emailAddress,
                        style: TextStyle(letterSpacing: 1.2),
                        decoration: InputDecoration(hintText: "Email", labelText: "Email"),
                        validator: (value) {
                          if (value.length > 40) {
                            return 'Length should be less than 40';
                          }
                        },
                        onSaved: (String value) => this.profileData.email = value,
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.mobileAlt, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: myData["phone"],
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: false),
                        style: TextStyle(letterSpacing: 1.2),
                        decoration: InputDecoration(hintText: "Mobile Number", labelText: "Mobile Nmuber"),
                        validator: (value) {
                          if (value.length != 10 && value != "") {
                            return 'Mobile number should be 10 digits long';
                          }
                        },
                        onSaved: (String value) => this.profileData.phone = value,
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.mapMarkerAlt, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: myData["pincode"],
                        style: TextStyle(letterSpacing: 1.2),
                        keyboardType: TextInputType.numberWithOptions(
                            decimal: false, signed: false),
                        decoration: InputDecoration(hintText: "Pincode", labelText: "Pincode"),
                        validator: (value) {
                          if (value.length != 6 && value != "") {
                            return 'Pincode should be 6 digits long';
                          }
                        },
                        onSaved: (String value) => this.profileData.pincode = value,
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.home, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: dataBlob["address"],
                        style: TextStyle(letterSpacing: 1.2),
                        decoration: InputDecoration(hintText: "Address", labelText: "Address"),
                        onSaved: (String value) => this.profileData.address = value,
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.road, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: dataBlob["street"],
                        style: TextStyle(letterSpacing: 1.2),
                        decoration: InputDecoration(hintText: "Street", labelText: "Street"),
                        onSaved: (String value) => this.profileData.street = value,
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          initialValue: dataBlob["state"],
                          style: TextStyle(letterSpacing: 1.2),
                          decoration: InputDecoration(hintText: "State", labelText: "State"),
                          validator: (value) {
                            if (value.length > 28) {
                              return 'Invalid state name';
                            }
                          },
                          onSaved: (String value) => this.profileData.state = value,
                        ),
                        padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        child: TextFormField(
                          initialValue: dataBlob["city"],
                          style: TextStyle(letterSpacing: 1.2),
                          decoration: InputDecoration(hintText: "City", labelText: "City"),
                          validator: (value) {
                            if (value.length > 25) {
                              return 'Invalid city name';
                            }
                          },
                          onSaved: (String value) => this.profileData.city = value,
                        ),
                        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, 0.0),
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Container(
                child: Row(
                  children: <Widget>[
                    Container(
                      child: Icon(FontAwesomeIcons.shareAlt, color: Color(0xFF412d35),),
                      padding: EdgeInsets.fromLTRB(0.0, 0.0, 15.0, 0.0),
                    ),
                    Expanded(
                      child: TextFormField(
                        initialValue: dataBlob["share"],
                        style: TextStyle(letterSpacing: 1.2),
                        decoration: InputDecoration(hintText: "Share Code", labelText: "Share code"),
                        enabled: profileData.share == null,
                        onSaved: (String value) => this.profileData.share = value,
                        validator: (value) {
                          if (value.length != 0 && value.length != 6) {
                            return 'Share Code length must be 6 characters';
                          }
                        },
                      ),
                    ),
                  ],
                ),
                width: 400.0,
                padding: EdgeInsets.all(10.0),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: RaisedButton(
                    color: Colors.blueGrey[100],
                    onPressed: () {
                      if (_playerProfile.currentState.validate()) {
                        _playerProfile.currentState.save();
                        this.submitProfileInfo(widget.data.id);
                      }
                    },
                    padding: EdgeInsets.fromLTRB(100.0, 10.0, 100.0, 10.0),
                    child: _saving ? Container(child: CircularProgressIndicator(), height: 24.0, width: 52.0, padding: EdgeInsets.fromLTRB(16.0,2.0,16.0,2.0),) : Text('Save', style: TextStyle(letterSpacing: 2.0, fontWeight: FontWeight.bold, fontSize: 20.0, color: Color(0xFF412d35),),),
                  ),
                ),
              ),
            ],
          ),
          key: _playerProfile,
        ),
      ),
      padding: EdgeInsets.fromLTRB(0.0, 6.0, 0.0, 11.0),
    );
  }
}
