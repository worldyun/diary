import 'dart:async';
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:diary/util/EvevBus.dart';
import 'package:diary/util/HttpUtil.dart';
import 'package:diary/util/MyToast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'MyDrawer.dart';

class Diarys extends StatefulWidget {
  Diarys({Key key}) : super(key: key);

  @override
  _DiarysState createState() => _DiarysState();
}

class _DiarysState extends State<Diarys> {

  SharedPreferences _prefs;
  List<Widget> _diarysList = [];
  bool _signIn = false;
  int _page = 1;
  bool _refresh = false;
  StreamSubscription<RefreshRiarysEvent> _refreshRiarysEvent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _refreshRiarysEvent = eventBus.on<RefreshRiarysEvent>().listen((event) {
      this._page = 1;
      this._refresh = true;
      this._start();
    });
    this._start();
  }

  Future<void> _start() async {
    this._prefs = await SharedPreferences.getInstance();
    
    if (this._prefs.containsKey("signIn")) {
      if (this._prefs.getBool("signIn")) {
        HttpUtil.post("refreshSession");
        // this._signIn = true;
        setState(() {
          this._signIn = true;
        });
        this._getData();
      }else{
        setState(() {
          this._signIn = false;
        });
        this._diarysList.clear();
      }
    }else{
      this._prefs.setBool("signIn", false);
    }

    if ( !this._prefs.containsKey("diaryDraft")){
      this._prefs.setBool("diaryDraft", false);
    }
    
  }

  Future<void> _getData() async {
    Map reqData = {
      "page": this._page,
      "endtimestamp": (DateTime.now().millisecondsSinceEpoch / 1000).toInt(),
      "starttimestamp": 1
    };
    var resData = await HttpUtil.post("get", data: reqData);
    if (resData == null) {
      return;
    }
    if (resData["status"] == 1) {
      MyToast.showToast("未登录");
      this._prefs.setBool("signIn", false);
      setState(() {
        this._diarysList.clear();
      });
    }else if(resData["status"] == 501){
      this._page += 1;
      List<Widget> diarysList = new List();
      // for (var value in resData["diarys"]) {
      for (var i = resData["diarys"].length - 1; i >= 0 ; i-- ) {
        var value = resData["diarys"][i];
        var time = DateTime.fromMillisecondsSinceEpoch( (value["timestamp"] * 1000) );
        String data = utf8.decode(base64Decode(value["data"]));
        var card = new InkWell(
          onTap: () {
            print("Card点击  DID: ${value["did"]}");
          },
          child: Card(
            color: Colors.white70,
            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: Column(
              children: <Widget>[
                ListTile(
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[
                      Text(
                        formatDate(time, [yyyy, '年', m, '月', d, '日']),
                        style: TextStyle(
                            color: Colors.black54,
                            fontSize: 20
                        ),
                      ),
                      SizedBox(width: 5),
                      Container(
                        padding: EdgeInsets.only(bottom: 2),
                        child: Text(
                          formatDate(time, [ ' / ', HH, ':', nn]),
                          style: TextStyle(
                            fontSize: 15,
                            color: Colors.black54,
                          ),
                        )
                      )
                    ],
                  ),
                ),
                Divider(),
                ListTile(
                  title: Text(
                    data,
                    maxLines: 4,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 15
                    ),
                  ),
                )
              ],
            ),
          ),
        );
        diarysList.add(card);
      }
      if (this._refresh) {
        this._diarysList.clear();
        this._refresh = false;
      }
      if(diarysList.isNotEmpty){
        setState(() {
          this._diarysList += diarysList.toList();
        });
      }
    }else{
      MyToast.showToast(resData["msg"]);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("日记"),
      ),
      body: this._signIn ? Container(
        padding: EdgeInsets.only(bottom: 15),
        width: double.infinity,
        child: ListView(
          children: this._diarysList,
        ),
      ) : Center(child: Text("未登录"),),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.create),
        onPressed: (){
          Navigator.pushNamed(context, "/newDiary");
        },
      ),
    );
  }
}