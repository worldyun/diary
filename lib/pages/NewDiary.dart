import 'dart:convert';

import 'package:diary/util/EvevBus.dart';
import 'package:diary/util/HttpUtil.dart';
import 'package:diary/util/MyToast.dart';
import 'package:flutter/material.dart';
import 'package:date_format/date_format.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NewDiary extends StatefulWidget {
  NewDiary({Key key}) : super(key: key);

  @override
  _NewDiaryState createState() => _NewDiaryState();
}

class _NewDiaryState extends State<NewDiary> {

  var _nowTime = DateTime.now();
  String _nowTimeTitleOne = "";
  String _nowTimeTitleTwo = "";
  String _data = "";
  var _lastData = new TextEditingController();
  SharedPreferences _prefs;
  bool _diaryDraft = false;

  @override
  void initState() {
    this._getInfo();
    super.initState();
  }

  Future<void> _getInfo() async {
    this._prefs = await SharedPreferences.getInstance();
    
    if (this._prefs.containsKey("diaryDraft")) {
      if (this._prefs.getBool("diaryDraft")) {
        this._nowTime = DateTime.fromMillisecondsSinceEpoch(this._prefs.getInt("diaryDraftTime"));
        this._data = this._prefs.getString("diaryDraftData");
        setState(() {
          this._lastData.text = this._data;
          this._diaryDraft = true;
        });
      }
    }
    setState(() {
      this._nowTimeTitleOne = formatDate(this._nowTime, [ m, '月', d, '日']);
      this._nowTimeTitleTwo = formatDate(this._nowTime, [ '/ ', HH, ':', nn]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: this._pop,
      child: Container(
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
                  this._nowTimeTitleOne,
                  style: TextStyle(
                      color: Colors.black54
                  ),
                ),
                SizedBox(width: 5),
                Container(
                  padding: EdgeInsets.only(bottom: 2),
                  child: Text(
                    this._nowTimeTitleTwo,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.black54
                    ),
                  )
                )
              ],
            ),
            actions: <Widget>[
              IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    this._prefs.setBool("diaryDraft", false);
                    Navigator.pop(context);
                  },
              ),
              IconButton(
                  icon: Icon(Icons.done),
                  onPressed: this._add
              )
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                  child: TextField(
                    controller: this._diaryDraft ? this._lastData : TextEditingController(),
                    keyboardType: TextInputType.multiline,
                    maxLength: 1000,
                    maxLines: 25,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderSide: BorderSide.none
                      ),
                      hintText: "记录今日"
                    ),
                    onChanged: (value) {
                      this._data = value;
                      this._pop();
                    },
                  ),
                )
              ],
            ),
          )
        )
      ),
    );
  }

  Future<void> _add() async {
    if (this._data.length == 0) {
      MyToast.showToast("一点想记录的都没有么");
      return;
    }
    String data = base64Encode(utf8.encode(this._data));    //编码base64
    // String undata = utf8.decode(base64Decode(data));     //解码回utf8
    // print(data);

    Map reqData = {
      "timestamp": (this._nowTime.millisecondsSinceEpoch / 1000).toInt(),
      "data": data
    };

    var resData = await HttpUtil.post("add", data: reqData);
    if (resData["status"] == 1) {
      MyToast.showToast("未登录");
      this._prefs.setBool("signIn", false);
      Navigator.pushNamed(context, '/signIn');
    }else if(resData["status"] == 401){
      MyToast.showToast("保存成功");
      this._prefs.setBool("diaryDraft", false);
      eventBus.fire(RefreshRiarysEvent(true));
      Navigator.pop(context);
    }else{
      MyToast.showToast(resData["msg"]);
    }
  }

  Future<bool> _pop() async{
    if(this._data.length > 0){
      this._prefs.setBool("diaryDraft", true);
      this._prefs.setInt("diaryDraftTime", this._nowTime.millisecondsSinceEpoch);
      this._prefs.setString("diaryDraftData", this._data);
    }else{
      this._prefs.setBool("diaryDraft", false);
    }
    return true;
  }
}
