import 'package:flutter/material.dart';

class NewDiary extends StatelessWidget {
  const NewDiary({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("记录好心情"),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.done), 
            onPressed: (){
              print("done");
            }
          )
        ],
      ),
      body: Center(
        child: Text("内容"),
      ),
    );
  }
}