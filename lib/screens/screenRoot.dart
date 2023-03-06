import 'package:flutter/material.dart';
import 'package:record/screens/recordList.dart';
import 'package:record/screens/record.dart';
import 'package:record/screens/graph.dart';


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
    RecordList(),
    Graph(),
  ];
}

class ScreenColor {
  Color? baseColor = Colors.grey[900];
  Color? baseColor2 = Colors.black;
  // Color? baseColor2 = Colors.orange;
  Color? baseColor3 = Colors.grey;
  Color? subColor = Colors.blue;
}
