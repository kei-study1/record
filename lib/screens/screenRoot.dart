import 'package:flutter/material.dart';
import 'package:record/screens/nameless1.dart';
import 'package:record/screens/nameless2.dart';
import 'package:record/screens/record.dart';


class ScreenRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    throw UnimplementedError();
  }
}

class ScreenList {
  List<ScreenRoot> screenLists = [
    Record(),
    Nameless1(),
    Nameless2(),
  ];
}

class ScreenColor {
  // Color? baseColor = Colors.orange[300];
  // Color? subColor = Colors.lightBlue[300];
  Color? subColor = Colors.blue;
  // Color? baseColor2 = Colors.yellow[100];
  Color? baseColor = Colors.grey[800];
  Color? baseColor2 = Colors.black;
}
