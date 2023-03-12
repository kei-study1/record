import 'package:flutter/material.dart';
import '../db.dart';
import '../util.dart';
import 'screenRoot.dart';
import 'package:fl_chart/fl_chart.dart';
// toggle button


class Graph extends ScreenRoot {
  @override
  Widget build(BuildContext context) {
    return GraphStateful();
  }
}

class GraphStateful extends StatefulWidget {
  @override
  GraphState createState() => GraphState();
}

class GraphState extends State<GraphStateful> {
  DateTime now = DateTime.now();
  late DateTime preNow = now.add(Duration(days: -6));
  int _plusDay = 0;
  int _plusMonth = 0;
  // ScreenColor
  ScreenColor sc = ScreenColor();

  @override
  void initState() {
    graphSet();
  }

  void previous() {
    setState(() {
      if (_toggleList[0]) {
        _plusDay -= 7;
      }
      if (_toggleList[1]) {
        _plusMonth -= 1;
      }
    });
    graphSet();
  }
  void next() {
    setState(() {
      if (_toggleList[0]) {
        _plusDay += 7;
      }
      if (_toggleList[1]) {
        _plusMonth += 1;
      }
    });
    graphSet();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    DateTime? date;
    /*
    valueの値とxIntの値が対応しているっぽいので
    xIntの表示順にcase句を並び替えた。
    caseにはconst値しか使えないっぽいため。
    */
    if (_toggleList[0]){
      switch (value.toInt()) {
        case 0:
          date= preNow.add(Duration(days: _plusDay));
          break;
        case 1:
          date = preNow.add(Duration(days: 1 + _plusDay));
          break;
        case 2:
          date = preNow.add(Duration(days: 2 + _plusDay));
          break;
        case 3:
          date = preNow.add(Duration(days: 3 + _plusDay));
          break;
        case 4:
          date = preNow.add(Duration(days: 4 + _plusDay));
          break;
        case 5:
          date = preNow.add(Duration(days: 5 + _plusDay));
          break;
        case 6:
          date = preNow.add(Duration(days: 6 + _plusDay));
          break;
        default:
          date = null;
          break;
      }
    }

    if (_toggleList[1]) {
      switch (value.toInt()) {
        case 0:
          date = DateTime(now.year, now.month + _plusMonth, 1);
          break;
        case 1:
          date = DateTime(now.year, now.month + _plusMonth, 2);
          break;
        case 2:
          date = DateTime(now.year, now.month + _plusMonth, 3);
          break;
        case 3:
          date = DateTime(now.year, now.month + _plusMonth, 4);
          break;
        case 4:
          date = DateTime(now.year, now.month + _plusMonth, 5);
          break;
        case 5:
          date = DateTime(now.year, now.month + _plusMonth, 6);
          break;
        case 6:
          date = DateTime(now.year, now.month + _plusMonth, 7);
          break;
        case 7:
          date = DateTime(now.year, now.month + _plusMonth, 8);
          break;
        case 8:
          date = DateTime(now.year, now.month + _plusMonth, 9);
          break;
        case 9:
          date = DateTime(now.year, now.month + _plusMonth, 10);
          break;
        case 10:
          date = DateTime(now.year, now.month + _plusMonth, 11);
          break;
        case 11:
          date = DateTime(now.year, now.month + _plusMonth, 12);
          break;
        case 12:
          date = DateTime(now.year, now.month + _plusMonth, 13);
          break;
        case 13:
          date = DateTime(now.year, now.month + _plusMonth, 14);
          break;
        case 14:
          date = DateTime(now.year, now.month + _plusMonth, 15);
          break;
        case 15:
          date = DateTime(now.year, now.month + _plusMonth, 16);
          break;
        case 16:
          date = DateTime(now.year, now.month + _plusMonth, 17);
          break;
        case 17:
          date = DateTime(now.year, now.month + _plusMonth, 18);
          break;
        case 18:
          date = DateTime(now.year, now.month + _plusMonth, 19);
          break;
        case 19:
          date = DateTime(now.year, now.month + _plusMonth, 20);
          break;
        case 20:
          date = DateTime(now.year, now.month + _plusMonth, 21);
          break;
        case 21:
          date = DateTime(now.year, now.month + _plusMonth, 22);
          break;
        case 22:
          date = DateTime(now.year, now.month + _plusMonth, 23);
          break;
        case 23:
          date = DateTime(now.year, now.month + _plusMonth, 24);
          break;
        case 24:
          date = DateTime(now.year, now.month + _plusMonth, 25);
          break;
        case 25:
          date = DateTime(now.year, now.month + _plusMonth, 26);
          break;
        case 26:
          date = DateTime(now.year, now.month + _plusMonth, 27);
          break;
        case 27:
          date = DateTime(now.year, now.month + _plusMonth, 28);
          break;
        case 28:
          date = DateTime(now.year, now.month + _plusMonth, 29);
          break;
        case 29:
          date = DateTime(now.year, now.month + _plusMonth, 30);
          break;
        case 30:
          date = DateTime(now.year, now.month + _plusMonth, 31);
          break;
        default:
          date = null;
          break;
      }
    }

    int day = date!.day;

    if (_toggleList[1] && day % 2 == 0) {
      return SideTitleWidget(
        axisSide: meta.axisSide,
        child: Text(''),
      );
    }

    // 曜日
    int weekday = date!.weekday;
    Color color = Colors.transparent;
    if (weekday == 6) {
      color = Colors.blue;
    }
    if (weekday == 7) {
      color = Colors.red;
    }

    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Container(
        alignment: Alignment.center,
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
        child: Text('${day}',
          style: TextStyle(
            fontSize: 10,
            color: Colors.white
          ),
        )
      ),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
      color: Colors.white,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }


  // グラフタッチ時にコールバック関数が何回が動くのでそれの制御用フラグ
  bool singleFunctionFlg = true;

  void graphDialog(BuildContext context, int rodIndex) {
    // その日１日分のデータ群
    List<RecordDbTag> oneDayList = dayList[week[rodIndex].day]!;
    oneDayList = List.from(oneDayList.reversed);
    int workSecond = tu.intListRecordDbTag(oneDayList, true);
    int restSecond = tu.intListRecordDbTag(oneDayList, false);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, dialogState) {
            return SimpleDialog(
              contentPadding: EdgeInsets.all(10),
              backgroundColor: sc.baseColor,
              children: <Widget>[

                Text(
                  '${tu.stringDateTimeGraphDateE(week[rodIndex])}',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20
                  )
                ),
                Sb('h', 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(Icons.history, color: Colors.white,),
                    Sb('w', 5),
                    ListText1(
                      tu.stringDateTime(
                        tu.dateTimeIntSeconds(workSecond)
                      ),
                      20
                    ),
                    Sb('W', 10),
                    Icon(Icons.hourglass_bottom_outlined, color: Colors.white,),
                    Sb('w', 5),
                    ListText1(
                      tu.stringDateTime(
                        tu.dateTimeIntSeconds(restSecond)
                      ),
                      20
                    ),
                  ],
                ),

                Sb('h', 10),

                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 300,
                      height: 400,
                      child: ListView.builder(
                        itemCount: dayList[week[rodIndex].day]!.length,
                        itemBuilder: (context3, index) {
                          return Card(
                            color: Color(oneDayList[index].color),
                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: sc.baseColor,
                                  minimumSize: Size.zero,
                                  padding: EdgeInsets.all(5),
                                ),
                                onPressed: null,
                                onLongPress: () {
                                  showDialog(
                                    context: context3,
                                    builder: (BuildContext contextS) {
                                      return SimpleDialog(
                                        contentPadding: EdgeInsets.all(20),
                                        backgroundColor: sc.baseColor,
                                        children: <Widget>[
                                          Container(
                                            child: SingleChildScrollView(
                                              child: Text(
                                                '選択したリストを\n削除しますか？',
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontSize: 20,
                                                  color: Colors.white
                                                ),
                                              ),
                                            ),
                                          ),
                                          SimpleDialogOption(
                                            onPressed: () async {
                                              await RecordDb.deleteRecordList(oneDayList[index].id!);
                                              dialogState(() {
                                                oneDayList.removeAt(index);
                                                oneDayList = oneDayList;
                                                workSecond = tu.intListRecordDbTag(oneDayList, true);
                                                restSecond = tu.intListRecordDbTag(oneDayList, false);
                                                graphSet();
                                              });
                                              Navigator.pop(contextS);
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text('YES', style: TextStyle(color: Colors.white, fontSize: 20),),
                                              ],
                                            ),
                                          ),
                                          SimpleDialogOption(
                                            onPressed: () {
                                              Navigator.pop(contextS);
                                            },
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.end,
                                              children: [
                                                Text('NO', style: TextStyle(color: Colors.white, fontSize: 20),),
                                              ],
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                            
                                child: Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Container(
                                        width: double.infinity,
                                        child: ListText2(
                                          tu.stringDateTimeDate(
                                            tu.datetimeIntDate(
                                              oneDayList[index].year,
                                              oneDayList[index].month,
                                              oneDayList[index].day,
                                              oneDayList[index].hour,
                                              oneDayList[index].minute,
                                              oneDayList[index].second,
                                            )
                                          ),
                                          13
                                        ),
                                      ),

                                      Container(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: <Widget>[
                                            ListText1(oneDayList[index].tagText, 20),
                                            Row(
                                              children: <Widget>[
                                                Icon(Icons.history, color: Colors.white,),
                                                Sb('w', 5),
                                                ListText1(
                                                  tu.stringDateTime(
                                                    tu.dateTimeIntSeconds(oneDayList[index].endToStartSecond)
                                                  ),
                                                  17
                                                ),
                                                Sb('w', 10),
                                                Icon(Icons.hourglass_bottom_outlined, color: Colors.white,),
                                                Sb('w', 5),
                                                ListText1(
                                                  tu.stringDateTime(
                                                    tu.dateTimeIntSeconds(oneDayList[index].restSecond)
                                                  ),
                                                  17
                                                )
                                              ],
                                            ),

                                            Container(
                                              width: 90,
                                              child: ElevatedButton(
                                                style: ElevatedButton.styleFrom(
                                                  // minimumSize: Size.zero,
                                                  backgroundColor: Colors.white,
                                                  padding: EdgeInsets.all(0)
                                                ),
                                                onPressed: (){
                                                  showDialog(
                                                    context: context,
                                                    builder: (BuildContext context) {
                                                      return SimpleDialog(
                                                        contentPadding: EdgeInsets.all(20),
                                                        backgroundColor: sc.baseColor,
                                                        children: <Widget>[
                                                          Container(
                                                            height: 300,
                                                            child: SingleChildScrollView(
                                                              child: Text(
                                                                oneDayList[index].recordText,
                                                                style: TextStyle(
                                                                  fontSize: 20,
                                                                  color: Colors.white
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      );
                                                    }
                                                  );
                                                },
                                                child: Row(
                                                  children: <Widget>[
                                                    Icon(Icons.article, color: sc.baseColor,),
                                                    Sb('w', 5),
                                                    Text(
                                                      'memo',
                                                      style: TextStyle(
                                                        color: sc.baseColor,
                                                        fontSize: 18
                                                      ),
                                                    ),
                                                  ],
                                                )
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            );
          }
        );
      }
    );
  }

  List<bool> _toggleList = [true, false];
  // double _constrain = 0;
  double _constrain = 353;
  double barsSpace = 0.0;
  double barsWidth = 0.0;

  final _tab = <Tab> [
    // Tab( text:'WEEK', icon: Icon(Icons.directions_car)),
    // Tab( text:'MONTH', icon: Icon(Icons.directions_bike)),
    Tab( text:'WEEK',),
    Tab( text:'MONTH',),
    // Tab( text:'Boat', icon: Icon(Icons.directions_boat)),
  ];

// Widget build ***********************************************
// Widget build ***********************************************
// Widget build ***********************************************
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: sc.baseColor,
              borderRadius: BorderRadius.circular(5)
            ),
            margin: EdgeInsets.only(left: 5, top: 10, right: 5),
            padding: EdgeInsets.only(left: 20, right: 20),
            child: DefaultTabController(
              length: _tab.length,
              child: TabBar(
                labelColor: sc.subColor,
                unselectedLabelColor: Colors.white,
                indicatorColor: sc.subColor,
                tabs: _tab,
                onTap: (index) {
                  setState(() {
                    for (int i = 0; i < _toggleList.length; i++){
                      _toggleList[i] = i == index;
                    }
                    graphSet();
                  });
                },
              ),
            ),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sc.baseColor
                ),
                onPressed: previous,
                child: Icon(Icons.navigate_before),
              ),
              Card(
                color: sc.baseColor,
                child: Container(
                  alignment: Alignment.center,
                  height: 36,
                  width: 200,
                  child: Text(
                    (_toggleList[0])?
                    tu.stringDateTimeGraphDate(preNow.add(Duration(days: _plusDay)))
                    + ' ~ ' +
                    tu.stringDateTimeGraphDate(now.add(Duration(days: _plusDay)))
                    :
                    tu.stringDateTimeGraphDateMonth(now, _plusMonth)
                    ,
                    style:  TextStyle(
                      fontSize: 13,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: sc.baseColor
                ),
                onPressed: next,
                child: Icon(Icons.navigate_next),
              ),
            ],
          ),
    
          Container(
            decoration: BoxDecoration(
              color: sc.baseColor,
              borderRadius: BorderRadius.circular(5)
            ),
            margin: EdgeInsets.only(left: 5, right: 5),
            child: AspectRatio(
              aspectRatio: 1.1,
              child: Padding(
                padding: const EdgeInsets.only(top: 16, right: 30),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    // _constrain = constraints.maxWidth;

                    return BarChart(
                      BarChartData(
                        minY: 0,
                        maxY: 25,
                        alignment: BarChartAlignment.center,
                        barTouchData: BarTouchData(
                          // 基本的にはtrueにすると、トップの値が分かる
                          enabled: false,
                          // touchTooltipData: BarTouchTooltipData(),
                          touchCallback: (FlTouchEvent event, barTouchResponse) {
                            if(!event.isInterestedForInteractions ||
                                barTouchResponse == null ||
                                barTouchResponse.spot == null) {
                              return;
                            }
                            /*
                            touchedBarGroupIndex bottomTitleのvalue単位
                            touchedRodDataIndex 上のindexの中身単位
                            touchedStackItemIndex 縦軸のデータ単位（値がないところは-1）
                            */
                            final rodIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                            final itemIndex = barTouchResponse.spot!.touchedStackItemIndex;
                            if (itemIndex == -1) {
                              return;
                            }
                            setState(() {
                              singleFunctionFlg = !singleFunctionFlg;
                              if (singleFunctionFlg) {
                                return graphDialog(context, rodIndex + 1);
                              }
                            });
                          }, 
                        ),
                        titlesData: FlTitlesData(
                          // タイトルがtureだと見える
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 35, //28
                              getTitlesWidget: bottomTitles,
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 40,
                              interval: 2,
                              getTitlesWidget: leftTitles,
                            ),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        gridData: FlGridData(
                          // メモリ線がみえる
                          show: true,
                          horizontalInterval: 2,
                          // checkToShowHorizontalLine: (value) => value % 2 == 0,
                          // checkToShowHorizontalLine: (value) => true,
                          getDrawingHorizontalLine: (value) => FlLine(
                            color: sc.subColor,
                            strokeWidth: 1,
                          ),
                          // 縦のメモリ線
                          drawVerticalLine: false,
                        ),
                        borderData: FlBorderData(
                          // グラフの枠
                          show: false,
                        ),
                        groupsSpace: barsSpace,
                        barGroups: getData(),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
    
          Container(
            decoration: BoxDecoration(
              color: sc.baseColor,
              borderRadius: BorderRadius.circular(5)
            ),
            width: double.infinity,
            height: 132,
            margin: EdgeInsets.only(left: 5, top: 5, right: 5),
            child: ListView.builder(
              itemCount: tagDetailList.length,
              itemBuilder: (context4, index) {
                return Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                    Expanded(
                      flex: 40,
                      child: Container(
                        padding: EdgeInsets.only(left: 5, right: 5),
                        decoration: BoxDecoration(
                          border: Border(bottom: BorderSide(width: 1, color: sc.baseColor3!)),
                        ),
                        child: Row(
                          children: <Widget>[
                            Icon(Icons.bookmark, color: Color(tagDetailList[index].color), size: 40,),
                            Sb('w', 5),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                ListText1(tagDetailList[index].tagText, 15),
                                Row(
                                  children: <Widget>[
                                    Icon(Icons.history, color: Colors.white, size: 20,),
                                    Sb('w', 5),
                                    ListText1(
                                      tu.stringDateTime(
                                        tu.dateTimeIntSeconds(tagDetailList[index].endToStartSecond)
                                      ),
                                      12
                                    ),
                                    Sb('w', 10),
                                    Icon(Icons.hourglass_bottom_outlined, color: Colors.white, size: 20,),
                                    Sb('w', 5),
                                    ListText1(
                                      tu.stringDateTime(
                                        tu.dateTimeIntSeconds(tagDetailList[index].restSecond)
                                      ),
                                      12
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: Container(),
                    ),
                  ],
                );
              },
            ),
          )
        ],
      ),
    );
  }




  // ===============================================================
  // ===============================================================
  // ===============================================================

  // TimerUtilクラス
  TimerUtil tu = TimerUtil();
  // 1週間分の日付が入るリスト・メソッド
  List<DateTime> week = [];
  void weekPutDay() {
    if (_toggleList[0]) {
      for(int i = -1; i < 7; i++) {
        week.add(preNow.add(Duration(days: i + _plusDay)));
      }
    }
    if (_toggleList[1]) {
      for(int i = -1; i < (DateTime(now.year, now.month + _plusMonth + 1, 0).day); i++){
        week.add(DateTime(now.year, now.month + _plusMonth, i + 1));
      }
    }

  }
  // 全recordデータ格納リスト
  List<RecordDbTag> recordTags = [];
  /*
  Map<1日, 1日のrecordデータ>
  dayListに今日の日づけ-j日の形で使うデータが入っている。
  グラフの24時間対応するならここで調整すると思う。
  */
  Map<int, List<RecordDbTag>> dayList = {};
  // 日付とデータが結びついているグラフ用データリスト
  List<BarChartGroupData> barChartGroupDate = [];
  // グラフ下部のTag表示用
  List<RecordDbTag> tagDetailList = [];

  void graphSet() async {
    // 毎回グラフの幅の調節を行う。
    if (_toggleList[0]) {
      barsSpace = 4.0 * _constrain / 100;
      barsWidth = 8.0 * _constrain / 100;
    }
    if (_toggleList[1]) {
      barsSpace = 0.0;
      barsWidth = 9.5;
    }

    // 日付が変わった時用にnowを初期値に戻す。
    now = DateTime.now();
    preNow = now.add(Duration(days: -6));
    // 前回データを削除（1週間の日にち）
    week = [];
    // 今回分の1週間前までの日にちをセット
    weekPutDay();
    // 前回データの削除（dayList, barChartGroupDate, tagDetailList）
    dayList = {};
    barChartGroupDate = [];
    tagDetailList = [];
    recordTags = await RecordDbTag.getAllGraphRecord();
    setState(() {
      // グラフに表示する各データを日付ごとに格納
      RecordDbTag? rdt = null;
      for (int j = 0; j < week.length; j++) {
        List<RecordDbTag> list = [];
        // 昨日の日付からデータが渡ったらlistの初めに入れて、rdtをnullにする。
        if (rdt != null) {
          list.add(rdt);
          rdt = null;
        }
        for (int i = 0; i < recordTags.length; i++) {
          DateTime d = tu.datetimeIntDate(recordTags[i].year, recordTags[i].month, recordTags[i].day, 0, 0, 0);
          if (d.year == week[j].year && d.month == week[j].month && d.day == week[j].day) {
            // 24時間対応
            RecordDbTag rt = recordTags[i];
            double start = tu.doubleStartInt(rt.hour, rt.minute, rt.second);
            double end = tu.doubleEndInt(start, rt.endToStartSecond);
            if (end <= 24) {
              list.add(rt);
            } else {
              list.add(
                RecordDbTag(id: rt.id, recordText: rt.recordText, tagText: rt.tagText, color: rt.color, year: rt.year, month: rt.month, day: rt.day, hour: rt.hour, minute: rt.minute, second: rt.second, endToStartSecond: (24*60*60 - (start*60*60).toInt()), restSecond: rt.restSecond)
              );
              // 24時を超えたデータ
              rdt = RecordDbTag(id: rt.id, recordText: rt.recordText, tagText: rt.tagText, color: rt.color, year: rt.year, month: rt.month, day: rt.day, hour: 0, minute: 0, second: 0, endToStartSecond: ((end*60*60).toInt() - 24*60*60), restSecond: rt.restSecond);
            }
          }
        }
        dayList[week[j].day] = list;
      }


      // グラフに表示するデータをRodグラフに表示用にセット
      for (int j = 1; j < week.length; j++) {
        List<BarChartRodStackItem> rodStackItems = [];

        for (int i = 0; i < dayList[week[j].day]!.length; i++) {
          RecordDbTag rt = dayList[week[j].day]![i];
          double start = tu.doubleStartInt(rt.hour, rt.minute, rt.second);
          double end = tu.doubleEndInt(start, rt.endToStartSecond);
          rodStackItems.add(MakeBarChartRodStackItem(start, end, rt.color));
        }

        // barChartGroupDate.add(MakeBarChartGroupData(week[j].day, rodStackItems));
        barChartGroupDate.add(MakeBarChartGroupData(j - 1, rodStackItems));
      }

      // グラフ下部Tag表示用
      for (int j = 1; j < week.length; j++) {
        for (int i = 0; i < dayList[week[j].day]!.length; i++) {
          RecordDbTag rt1 = dayList[week[j].day]![i];
          bool flg = true;
          for (int k = 0; k < tagDetailList.length; k++) {
            RecordDbTag rt2 = tagDetailList[k];
            if (rt1.color == rt2.color && rt1.tagText == rt2.tagText) {
              rt2.endToStartSecond += rt1.endToStartSecond;
              rt2.restSecond += rt1.restSecond;
              flg = false;
              break;
            }
          }
          if (flg) {
            tagDetailList.add(rt1);
          }
        }
      }
      // tagDetailListを作業時間でsort（作業時間の多い順）
      tagDetailList.sort((a, b) => b.endToStartSecond.compareTo(a.endToStartSecond));
    });
  }

  // グラフの形等を指定するクラス群 getDataが一番最初に呼ばれる
  List<BarChartGroupData> getData() {
    return barChartGroupDate;
  }
  BarChartGroupData MakeBarChartGroupData(int xInt, List<BarChartRodStackItem> rodStackItems) {
    return BarChartGroupData(
      x: xInt,
      barRods: [
        BarChartRodData(
          color: Colors.transparent,
          toY: 24,
          rodStackItems: rodStackItems,
          borderRadius: BorderRadius.zero,
          width: barsWidth,
        ),
      ]
    );
  }
  BarChartRodStackItem MakeBarChartRodStackItem(double start, double end, int color) {
    return BarChartRodStackItem(start, end, Color(color));
  }



  // ===============================================================
  // ===============================================================
  // ===============================================================

  // BarChartRodData MakeBarChartRodData(List<BarChartRodStackItem> rodStackItems) {
  //   return BarChartRodData(
  //     color: Colors.transparent,
  //     toY: 24,
  //     rodStackItems: rodStackItems,
  //     borderRadius: BorderRadius.zero,
  //     width: 20,
  //   );
  // }

  // List<BarChartRodStackItem> rodStackItems = [];




  // List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
  //   return barChartGroupDate;
    // return [
    //   BarChartGroupData(
    //     x: 0,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         // rodStackItems: [
    //         //   // BarChartRodStackItem(0, 2, widget.dark),
    //         //   // BarChartRodStackItem(12, 13.5, widget.normal),
    //         //   // BarChartRodStackItem(17, 17.2, widget.light),
    //         // ],
    //         // udnd が使えるからそういう値を渡すこと！
    //         rodStackItems: udnd,
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),

    //   BarChartGroupData(
    //     x: 1,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         rodStackItems: [
    //           BarChartRodStackItem(0, 2, widget.dark),
    //           BarChartRodStackItem(12, 13.5, widget.normal),
    //           BarChartRodStackItem(17, 24, widget.light),
    //         ],
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),

    //   BarChartGroupData(
    //     x: 2,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         rodStackItems: [
    //           BarChartRodStackItem(0, 2, widget.dark),
    //           BarChartRodStackItem(12, 13.5, widget.normal),
    //           BarChartRodStackItem(17, 17.2, widget.light),
    //         ],
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),

    //   BarChartGroupData(
    //     x: 3,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         rodStackItems: [
    //           BarChartRodStackItem(0, 2, widget.dark),
    //           BarChartRodStackItem(12, 13.5, widget.normal),
    //           BarChartRodStackItem(17, 17.2, widget.light),
    //         ],
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),

    //   BarChartGroupData(
    //     x: 4,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         rodStackItems: [
    //           BarChartRodStackItem(0, 2, widget.dark),
    //           BarChartRodStackItem(12, 13.5, widget.normal),
    //           BarChartRodStackItem(17, 17.2, widget.light),
    //         ],
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),

    //   BarChartGroupData(
    //     x: 5,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         rodStackItems: [
    //           BarChartRodStackItem(0, 2, widget.dark),
    //           BarChartRodStackItem(12, 13.5, widget.normal),
    //           BarChartRodStackItem(17, 17.2, widget.light),
    //         ],
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),

    //   BarChartGroupData(
    //     x: 6,
    //     barsSpace: barsSpace,
    //     barRods: [
    //       BarChartRodData(
    //         color: Colors.transparent,
    //         toY: 24,
    //         rodStackItems: [

    //           // BarChartRodStackItem(
    //           //   dayList[0]![0].hour.toDouble(),
    //           //   dayList[0]![1].hour.toDouble(),
    //           //   // widget.dark
    //           //   Color(dayList[0]![0].color),
    //           // ),

    //           // BarChartRodStackItem(
    //           //   dayList[0]![1].hour.toDouble(),
    //           //   dayList[0]![2].hour.toDouble(),
    //           //   // widget.dark
    //           //   Color(dayList[0]![0].color),
    //           // ),
    //           // BarChartRodStackItem(12, 13.5, widget.normal),
    //           // BarChartRodStackItem(17, 17.2, widget.light),
    //         ],
    //         borderRadius: BorderRadius.zero,
    //         width: barsWidth,
    //       ),
    //     ],
    //   ),



    // ];
  // }
}
