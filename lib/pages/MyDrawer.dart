import 'package:diary/util/EvevBus.dart';
import 'package:diary/util/HttpUtil.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MyDrawer extends StatefulWidget {
  MyDrawer({Key key}) : super(key: key);

  @override
  _MyDrawerState createState() => _MyDrawerState();
}

class _MyDrawerState extends State<MyDrawer> {

  SharedPreferences _prefs;
  String _username = "UnSignIn";
  bool _signIn = false;

  @override
  Future<void> initState() {
    this._getInfo();
    super.initState();
  }

  Future<void> _getInfo() async {
    this._prefs = await SharedPreferences.getInstance();
    if (this._prefs.containsKey("signIn")) {
      if (this._prefs.getBool("signIn")) {
        setState(() {
        this._signIn = true;
        this._username = this._prefs.getString("username");
      });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Column(
        children: <Widget>[
          Row(
            children: <Widget>[
              Expanded(
                child: UserAccountsDrawerHeader(
                  accountName: Text(this._username),
                  accountEmail: Text("记录好心情"),
                  currentAccountPicture: CircleAvatar(
                    child: Text(
                      this._username[0],
                      style: TextStyle(
                        fontSize: 35
                      ),
                    ),
                  ),
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: AssetImage("images/drawerHeaderBackGroundImage.jpg"),
                      fit: BoxFit.cover,
                    )
                  ),
                )
              )
            ],
          ),
          InkWell(                                              //登录跳转
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.person),
              ),
              title: Text("${this._signIn ? '登出' : '登录/注册'}"),
            ),
            onTap: () {
              if (this._signIn) {
                HttpUtil.post("signout", data: {});
                this._prefs.setBool("signIn", false);
                this._prefs.setString("username", "");
                eventBus.fire(RefreshRiarysEvent(true));
                setState(() {
                  this._signIn = false;
                  this._username = "UnSignIn";
                });
              } else {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/signIn');
              }
            },
          ),
          Divider(),
          InkWell(                                                //设置跳转
            child: ListTile(
              leading: CircleAvatar(
                child: Icon(Icons.settings),
              ),
              title: Text("设置"),
            ),
            onTap: () {
              print("设置事件");
            },
          ),
        ],
      ),
    );
  }
}