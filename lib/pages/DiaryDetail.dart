import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:flutter/material.dart';

class DiaryDetail extends StatefulWidget {
  Map arguments;
  DiaryDetail({Key key, this.arguments}) : super(key: key);
  
  @override
  _DiaryDetailState createState() => _DiaryDetailState(arguments: this.arguments);
}

class _DiaryDetailState extends State<DiaryDetail> {

  Map arguments;
  DateTime _time;
  String _titleOne = "";
  String _titleTwo = "";
  String _data = "";

   _DiaryDetailState({this.arguments});

  @override
  void initState() {
    this._setInfo();
    super.initState();
  }

  void _setInfo(){
    this._time = DateTime.fromMillisecondsSinceEpoch( (arguments["timestamp"] * 1000) );
    this._titleOne = formatDate(this._time, [ m, '月', d, '日']);
    this._titleTwo = formatDate(this._time, [ '/ ', HH, ':', nn]);
    this._data = utf8.decode(base64Decode(arguments["data"]));
  }

 

  @override
  Widget build(BuildContext context) {
    return Container(
       child: Scaffold(
         appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.black54),
          backgroundColor:  Color.fromARGB(0, 0, 0, 0),
          brightness: Brightness.light,
          elevation: 0,
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                this._titleOne,
                style: TextStyle(
                    color: Colors.black54
                ),
              ),
              SizedBox(width: 5),
              Container(
                padding: EdgeInsets.only(bottom: 2),
                child: Text(
                  this._titleTwo,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54
                  ),
                )
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                padding: EdgeInsets.fromLTRB(25, 0, 25, 20),
                child: Text(
                  this._data,
                  style: TextStyle(
                    color: Colors.black54,
                    fontSize: 18
                  ),
                )
              )
            ],
          ),
        ),
       )
    );
  }
}