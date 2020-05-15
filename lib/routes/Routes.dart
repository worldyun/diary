import 'package:flutter/material.dart';
import '../pages/Diarys.dart';
import '../pages/SignUp.dart';
import '../pages/SignIn.dart';
import '../pages/NewDiary.dart';
import '../pages/DiaryDetail.dart';

final Map<String, Function> routes = {
  "/": (contxt,{arguments})=>Diarys(),
  "/signUp": (contxt,{arguments})=>SignUp(),
  "/signIn": (contxt,{arguments})=>SignIn(),
  "/newDiary": (contxt,{arguments})=>NewDiary(),
  "/diaryDetail": (context,{arguments}) =>DiaryDetail(arguments: arguments)
  // '/form': (context,{arguments}) =>FormPage(arguments: arguments),  //路由传值
};

var onGenerateRoute=(RouteSettings settings) {
        // 统一处理
        final String name = settings.name;   
        final Function pageContentBuilder = routes[name];        

        if (pageContentBuilder != null) {
          final Route route = MaterialPageRoute(
              builder: (context) =>
                  pageContentBuilder(context, arguments: settings.arguments));
          return route;
        }
};
