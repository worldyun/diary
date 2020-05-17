import 'dart:convert';

import 'package:diary/util/EvevBus.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';


import '../util/MyToast.dart';
import '../util/HttpUtil.dart';

class SignIn extends StatefulWidget {
  SignIn({Key key}) : super(key: key);

  @override
  _SignInState createState() => _SignInState();
}

class _SignInState extends State<SignIn> {

  Map _userInfo = {
    "username": "1",
    "password": "1"
  };
  var _signFun;
  FocusNode _commentFocusUName = FocusNode();
  FocusNode _commentFocusPassWd = FocusNode();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "登录",
          style: TextStyle(
            color: Colors.black54
          ),
        ),
        iconTheme: IconThemeData(color: Colors.black54),
        backgroundColor:  Color.fromARGB(0, 0, 0, 0),
        brightness: Brightness.light,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "用户名",
                ),
                focusNode: this._commentFocusUName,
                onChanged: (value) {
                  this._userInfo["username"] = value;
                  if (this._userInfo["password"].length>=4 && this._userInfo["username"].length >= 6 && this._userInfo["username"].length <= 10) {
                    setState(() {
                      this._signFun = this._signIn;
                    });
                  }else{
                    setState(() {
                      this._signFun = null;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              TextField(
                obscureText: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "密码",
                ),
                focusNode: this._commentFocusPassWd,
                onChanged: (value) {
                  this._userInfo["password"] = value;
                  if (this._userInfo["password"].length>=4 && this._userInfo["username"].length >= 6 && this._userInfo["username"].length <= 10) {
                    setState(() {
                      this._signFun = this._signIn;
                    });
                  }else{
                    setState(() {
                      this._signFun = null;
                    });
                  }
                },
              ),
              SizedBox(height: 20),
              Container(
                alignment: Alignment.centerRight,
                child: InkWell(
                  child: Text(
                    "没有账号？去注册",
                    style: TextStyle(
                      color: Colors.black54
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("/signUp");
                  },
                )
              ),
              SizedBox(height: 20),
              Container(
                height: 55,
                width: double.infinity,
                child: RaisedButton(
                  child: Text(
                    "登录",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  // colorBrightness: Colors.black54,
                  color: Color.fromARGB(255, 150, 150, 180),
                  textColor: Colors.white,
                  onPressed: this._signFun,
                ),
              )
            ],
          ),
        ),
      )
    );
  }

  Future<void> _signIn() async {
    this._commentFocusUName.unfocus();
    this._commentFocusPassWd.unfocus();
    Map userInfo = new Map();
    userInfo["username"] = this._userInfo["username"];
    userInfo["password"] = md5.convert(utf8.encode(this._userInfo["password"])).toString();
    
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var resData = await HttpUtil.post("signin", data: userInfo);
    if(resData["status"] != 201){
      prefs.setBool("signIn", false);
      MyToast.showToast(resData["msg"]);
    }else{
      prefs.setBool("signIn", true);
      prefs.setString("username", userInfo["username"]);
      eventBus.fire(RefreshRiarysEvent(true));
      MyToast.showToast("登录成功");
      new Future.delayed(const Duration(milliseconds: 1000)).then((value){
        Navigator.pop(context);
      });
    } 
  }
  
}