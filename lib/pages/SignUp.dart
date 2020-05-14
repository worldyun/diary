import 'package:diary/util/HttpUtil.dart';
import 'package:flutter/material.dart';
import 'package:crypto/crypto.dart';

import 'dart:convert';

import '../util/MyToast.dart';

class SignUp extends StatefulWidget {
  SignUp({Key key}) : super(key: key);

  @override
  _SignUpState createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {

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
        title: Text("注册"),
      ),
      body: SingleChildScrollView(
        child: Container(
          width: double.infinity,
          // height: 600,
          padding: EdgeInsets.all(30),
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              TextField(
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: "用户名  6-10位",
                ),
                focusNode: this._commentFocusUName,
                onChanged: (value) {
                  this._userInfo["username"] = value;
                  if (this._userInfo["password"].length>=4 && this._userInfo["username"].length >= 6 && this._userInfo["username"].length <= 10) {
                    setState(() {
                      this._signFun = this._signUp;
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
                  labelText: "密码  至少4位",
                ),
                focusNode: this._commentFocusPassWd,
                onChanged: (value) {
                  this._userInfo["password"] = value;
                  if (this._userInfo["password"].length>=4 && this._userInfo["username"].length >= 6 && this._userInfo["username"].length <= 10) {
                    setState(() {
                      this._signFun = this._signUp;
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
                    "已有账号？去登录",
                    style: TextStyle(
                      color: Colors.blue
                    ),
                  ),
                  onTap: () {
                    Navigator.of(context).pushReplacementNamed("/signIn");
                  },
                )
              ),
              SizedBox(height: 20),
              Container(
                height: 55,
                width: double.infinity,
                child: RaisedButton(
                  child: Text(
                    "注册",
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  color: Colors.blue,
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

  Future<void> _signUp() async {
    this._commentFocusUName.unfocus();
    this._commentFocusPassWd.unfocus();
    Map userInfo = new Map();
    userInfo["username"] = this._userInfo["username"];
    userInfo["password"] = md5.convert(utf8.encode(this._userInfo["password"])).toString();

    var resData = await HttpUtil.post("signup", data: userInfo);
    if(resData["status"] != 101){
      MyToast.showToast(resData["msg"]);
    }else{
      MyToast.showToast("注册成功");
      new Future.delayed(const Duration(milliseconds: 1000)).then((value){
        Navigator.of(context).pushReplacementNamed("/signIn");
      });
    }
  }

}