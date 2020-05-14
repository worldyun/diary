import 'package:flutter/material.dart';

import 'MyDrawer.dart';

class Diarys extends StatefulWidget {
  Diarys({Key key}) : super(key: key);

  @override
  _DiarysState createState() => _DiarysState();
}

class _DiarysState extends State<Diarys> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("日记"),
      ),
      body: Center(
        child: Text("日记卡片列表"),
      ),
      drawer: MyDrawer(),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.add),
        onPressed: (){
          Navigator.pushNamed(context, '/newDiary');
        },
      ),
    );
  }
}