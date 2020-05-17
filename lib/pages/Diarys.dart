import 'dart:async';
import 'dart:convert';

import 'package:date_format/date_format.dart';
import 'package:diary/util/EvevBus.dart';
import 'package:diary/util/HttpUtil.dart';
import 'package:diary/util/MyToast.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_cupertino_date_picker/flutter_cupertino_date_picker.dart';

import 'MyDrawer.dart';

class Diarys extends StatefulWidget {
  Diarys({Key key}) : super(key: key);

  @override
  _DiarysState createState() => _DiarysState();
}

class _DiarysState extends State<Diarys> {

  SharedPreferences _prefs;       //本地存储
  List<Widget> _diarysList = [];  //日记表
  List<int> _diaryListIndex = []; //日记表索引
  bool _signIn = false;           //是否登录
  int _page = 1;                  //请求page
  bool _refresh = false;          //是否需要刷新
  bool _noMore = false;           //是否还有更多数据
  bool _noMoreTip = false;
  bool _isRefreshing = false;     //是否正在刷新
  StreamSubscription<RefreshRiarysEvent> _refreshRiarysEvent;     //Event Bus
  ScrollController _listViewController = new ScrollController();  //控制上拉加载更多
  DateTime _endtTime = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _listViewController.addListener(() {                  //上拉加载
      var maxScroll = _listViewController.position.maxScrollExtent -250;
      var pixel = _listViewController.position.pixels;
      if (maxScroll < pixel  && !this._isRefreshing) {
        if (!this._noMore) {
          this._isRefreshing = true;
          this._getData();
        }
      }
    });
    _refreshRiarysEvent = eventBus.on<RefreshRiarysEvent>().listen((event) {    //监听刷新Event
      if (event.refreshRiarys) {
        this._endtTime = DateTime.now();
      }
      this._page = 1;
      this._refresh = true;
      this._start();
    });
    this._start();
  }

  Future<void> _start() async {     //初始化一些数据
    this._prefs = await SharedPreferences.getInstance();
    
    if (this._prefs.containsKey("signIn")) {    //初始化登录
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
        this._diaryListIndex.clear();
        this._noMoreTip = false;
      }
    }else{
      this._prefs.setBool("signIn", false);
    }
    if ( !this._prefs.containsKey("diaryDraft")){     //初始化日记草稿
      this._prefs.setBool("diaryDraft", false);
    }
    
  }

  Future<void> _getData() async {           //获取日记
    Map reqData = {                         //组装post数据
      "page": this._page,
      "endtimestamp": (this._endtTime.millisecondsSinceEpoch / 1000).toInt(),
      "starttimestamp": 1
    };
    var resData = await HttpUtil.post("get", data: reqData);    //post请求
    if (resData == null) {
      return;
    }
    if (resData["status"] == 1) {         //处理状态码
      MyToast.showToast("未登录");
      this._prefs.setBool("signIn", false);
      setState(() {
        this._diarysList.clear();
        this._diaryListIndex.clear();
        this._noMoreTip = false;
      });
    }else if(resData["status"] == 501){         //正常返回数据
      if (resData["diarys"].length == 0 && !this._noMoreTip) {      //处理noMore提示
      var tip = this._diarysList.length == 0 ? "这里一片荒芜" : "人家是有底线的！";
      if(this._diarysList.length == 0){
        this._diarysList.add(new SizedBox(height: 250,));
      }
      this._noMoreTip = true;
        List<Widget> noMoreTip = [
          Container(
            width: 50,
            margin: EdgeInsets.fromLTRB(30, 0, 30, 0),
            child: Column(
              children: <Widget>[
                Divider(height: 5,),
                Text(
                  tip,
                  style: TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 15,)
        ];
        setState(() {
          this._diarysList += noMoreTip.toList();
        });
        this._noMore = true;
        this._isRefreshing = false;
        return;
      }
      this._noMore = false;
      this._page += 1;                //page++ 方便 getMore
      List<Widget> diarysList = new List();
      for (var value in resData["diarys"]) {    //组装List
        var time = DateTime.fromMillisecondsSinceEpoch( (value["timestamp"] * 1000) );
        String data = utf8.decode(base64Decode(value["data"]));
        if (this._refresh) {            //判断是否是刷新，如是则清空_diarysList
          this._diarysList.clear();
          this._diaryListIndex.clear();
          this._noMoreTip = false;
          this._refresh = false;
        }
        var card = Dismissible(
          key: Key("key_${value["did"]}}"),
          onDismissed: (direction) {
            this._delDiary(value["did"]);
            return true;
          },
          child: Card(
            color: Colors.white70,
            margin: EdgeInsets.fromLTRB(15, 15, 15, 0),
            child: new InkWell(
              onTap: () {
                Navigator.pushNamed(context, "/diaryDetail", arguments: value);
                // print("Card点击  DID: ${value["did"]}");
              },
              child: Column(
                children: <Widget>[
                  ListTile(
                    title: Container(
                      height: 28,
                      width: double.infinity,
                      child: Row(
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
                            padding: EdgeInsets.only(bottom: 0),
                            child: Text(
                              formatDate(time, [ ' / ', HH, ':', nn]),
                              style: TextStyle(
                                fontSize: 15,
                                color: Colors.black54,
                              ),
                            )
                          ),
                        ],
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.fromLTRB(10, 0, 15, 0),
                    child: Divider(height: 5,),
                  ),
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
            )
          ),
        );
        diarysList.add(card);
        this._diaryListIndex.add(value["did"]);
      }
      
      if(diarysList.isNotEmpty){      //判断是否为空，如否则将新数据add到_diarysList
        diarysList.add(new SizedBox( height: 15, ));
        if (this._page != 2) {
          this._diarysList.removeLast();
        }
        setState(() {
          this._diarysList += diarysList.toList();
        });
      }
      this._isRefreshing = false;
    }else{
      MyToast.showToast(resData["msg"]);
    }
  }

  void _delDiary(int did) async {       //删除日记
    var index = this._diaryListIndex.indexOf(did);
    if (index == -1) {
      MyToast.showToast("错误");
      eventBus.fire(RefreshRiarysEvent(true));
      return;
    }
    Map reqData = {
      "did": did
    };
    var resData = await HttpUtil.post("del", data: reqData);
    if (resData != null) {
      if (resData["status"] == 1) {
        MyToast.showToast("未登录");
        this._prefs.setBool("signIn", false);
        setState(() {
          this._diarysList.clear();
          this._diaryListIndex.clear();
          this._noMoreTip = false;
        });
      }else if(resData["status"] == 601){
        MyToast.showToast("已删除");
        this._diaryListIndex.removeAt(index);
        List<Widget> list = [];
        list.addAll(this._diarysList);
        list.removeAt(index);
        setState(() {
          this._diarysList = list;                  //一个很奇怪的bug，在这里直接removeAt后 setState不更新。。。。
          // this._diarysList.removeAt(index);      //导致Dismissible报错，不得已，只能这样处理
        });

      }else{
        MyToast.showToast(resData["msg"]);
      }
    }
  }

  void _showDatePicker() {              //选择查看日期
    if (!this._signIn) {
      MyToast.showToast("未登录");
      Navigator.pushNamed(context, '/signIn');
      return;
    }
    DatePicker.showDatePicker(
      context,
      onMonthChangeStartWithFirstDate: true,
      pickerTheme: DateTimePickerTheme(
        backgroundColor: Color.fromARGB(255, 230, 230, 230),
        showTitle: false,
        itemTextStyle: TextStyle(color: Colors.black54),
      ),
      minDateTime: DateTime.parse("2000-01-01"),
      maxDateTime: DateTime.parse("2030-12-31"),
      initialDateTime: this._endtTime,
      dateFormat: 'yyyy-MMMM-dd',
      locale: DateTimePickerLocale.zh_cn,
      onClose: (){
        DateTime nextDay = DateTime.now().add(Duration(days: 1));
        if(nextDay.isBefore(this._endtTime)){
          MyToast.showToast("未来是不可预知的!");
          eventBus.fire(RefreshRiarysEvent(true));
        }else{
          eventBus.fire(RefreshRiarysEvent(false));
        }
      },
      onChange: (dateTime, List<int> index) {
        this._endtTime = dateTime.add(Duration(hours: 23, minutes: 59, seconds: 59, milliseconds: 999));
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "日记",
          style: TextStyle(
            color: Colors.black54
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black54),
        backgroundColor:  Color.fromARGB(10, 0, 0, 0),
        brightness: Brightness.light,
        elevation: 0,
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.calendar_today), 
            onPressed: _showDatePicker
          )
        ],
      ),
      body: this._signIn ? Container(
        // padding: EdgeInsets.only(bottom: 15),
        width: double.infinity,
        child: RefreshIndicator(
          child: ListView(
            controller: this._listViewController,
            children: this._diarysList,
          ), 
          onRefresh: () async{
            this._page = 1;
            this._refresh = true;
            this._endtTime = DateTime.now();
            await this._start();
            return true;
          }
        ),
      ) : Center(child: Text("未登录"),),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color.fromARGB(255, 150, 150, 175),
        child: Icon(Icons.create),
        onPressed: (){
          Navigator.pushNamed(context, "/newDiary");
        },
      ),
    );
  }
}