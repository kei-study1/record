import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'db.dart';

// 行間空け用
Widget Sb(String w, double s) {
  return SizedBox(
    // (w = 'W')? 
    width: (w == 'w')? s : 0,
    height: (w == 'h')? s : 0,
  );
}

Widget ConText(String s, double width, double fontSize) {
  return Container(
    // color: Colors.red,
    width: width,
    child: Text(
      s,
      textAlign: TextAlign.center,
      style: TextStyle(
        fontSize: fontSize,
        color: Colors.white
      )
    ),
  );
}

Widget ListText1(String s, double fontSize) {
  return Text(
    s,
    textAlign: TextAlign.start,
    style: TextStyle(
      color: Colors.white,
      fontSize: fontSize,
    ),
  );
}
Widget ListText2(String s, double fontSize) {
  return Text(
    s,
    textAlign: TextAlign.end,
    style: TextStyle(
      color: Colors.white,
      fontSize: fontSize,
    ),
  );
}

// Timer用
class TimerUtil {
  DateFormat _format = DateFormat('HH:mm:ss');

  String stringDateTime(DateTime? t) {
    if (t == null) {
      return '';
    }
    return _format.format(t);
  }

  DateTime dateTimeIntSeconds(int seconds) {
    var h = seconds ~/ (60 * 60);
    var m = (seconds - h * 60 *60) ~/ 60;
    var s = seconds - h * 60 * 60 - m * 60;
    return DateTime(0,0,0,h,m,s);
  }

  int intSecondsDateTime(DateTime t) {
    var h = t.hour * 60 * 60;
    var m = t.minute * 60;
    var s = t.second;
    return h + m + s;
  }

  int intSecondsDateTimeBetween(DateTime? s, DateTime? e) {
    if (s == null || e == null) {
      return 0;
    }
    return e.difference(s).inSeconds;
  }

  List<int> intDateTimes(DateTime? t) {
    if (t == null) {
      return [0, 0, 0, 0, 0, 0];
    }

    List<int> a = [];
    a.add(int.parse(DateFormat('yyyy').format(t)));
    a.add(int.parse(DateFormat('MM').format(t)));
    a.add(int.parse(DateFormat('dd').format(t)));
    a.add(int.parse(DateFormat('HH').format(t)));
    a.add(int.parse(DateFormat('mm').format(t)));
    a.add(int.parse(DateFormat('ss').format(t)));
    return a;
  }

  DateTime datetimeIntDate(int y, int M, int d, int h, int m ,int s) {
    return DateTime(y, M, d, h, m, s);
  }

  String stringDateTimeDate(DateTime d) {
    return DateFormat('yyyy/MM/dd (E) HH:mm:ss').format(d);
  }

  String stringDateTimeGraphDate(DateTime d) {
    return DateFormat('yyyy/MM/dd').format(d);
  }

  String stringDateTimeGraphDateE(DateTime d) {
    return DateFormat('yyyy/MM/dd (EEEE)').format(d);
  }

  String stringDateTimeGraphDateMonth(DateTime d, int plusMonth) {
    DateTime d2 = DateTime(d.year, d.month + plusMonth);
    return DateFormat('yyyy/MM').format(d2);
  } 

  double doubleStartInt(int h, int m, int s) {
    return h.toDouble() + m.toDouble() / 60 + s.toDouble() / (60 * 60);
  }

  double doubleEndInt(double start, int sec) {
    return start + sec / (60 * 60);
  }

  int intListRecordDbTag (List<RecordDbTag> list, bool b) {
    int sum = 0;
    for (int i = 0; i < list.length; i++) {
      if (b) {
        sum += list[i].endToStartSecond;
      } else {
        sum += list[i].restSecond;
      }
    }
    return sum;
  }
}