import 'package:flutter/material.dart';
import '../db.dart';
import '../util.dart';
import 'screenRoot.dart';
import 'package:fl_chart/fl_chart.dart';

class Graph extends ScreenRoot {
  @override
  Widget build(BuildContext context) {
    return GraphStateful();
  }
}

class GraphStateful extends StatefulWidget {
  final Color dark = Colors.red;
  final Color normal = Colors.blue;
  final Color light = Colors.yellow;
  @override
  GraphState createState() => GraphState();
}

class GraphState extends State<GraphStateful> {
  final DateTime now = DateTime.now();
  final DateTime preNow = DateTime.now().add(Duration(days: -6));
  int _plusDay = 0;
  // ScreenColor
  ScreenColor sc = ScreenColor();

  void previous() {
    setState(() {
      _plusDay -= 1;
    });
    graphSet();
  }
  void next() {
    setState(() {
      _plusDay += 1;
    });
    graphSet();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = TextStyle(fontSize: 10, color: Colors.white);
    int day;
    /*
    valueの値とxIntの値が対応しているっぽいので
    xIntの表示順にcase句を並び替えた。
    caseにはconst値しか使えないっぽいため。
    */
    switch (value.toInt()) {
      case 0:
        day = preNow.add(Duration(days: _plusDay)).day;
        break;
      case 1:
        day = preNow.add(Duration(days: 1 + _plusDay)).day;
        break;
      case 2:
        day = preNow.add(Duration(days: 2 + _plusDay)).day;
        break;
      case 3:
        day = preNow.add(Duration(days: 3 + _plusDay)).day;
        break;
      case 4:
        day = preNow.add(Duration(days: 4 + _plusDay)).day;
        break;
      case 5:
        day = preNow.add(Duration(days: 5 + _plusDay)).day;
        break;
      case 6:
        day = preNow.add(Duration(days: 6 + _plusDay)).day;
        break;
      default:
        day = 0;
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text('$day', style: style),
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

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            ElevatedButton(
              onPressed: previous,
              child: Text('前へ'),
            ),
            ElevatedButton(
              onPressed: graphSet,
              child: Text('ボタン'),
            ),
            ElevatedButton(
              onPressed: next,
              child: Text('次へ'),
            ),
          ],
        ),

        Container(
          margin: EdgeInsets.all(10),
          color: sc.baseColor,
          child: AspectRatio(
            aspectRatio: 0.8,
            child: Padding(
              padding: const EdgeInsets.only(top: 16, right: 30),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final barsSpace = 4.0 * constraints.maxWidth / 100;
                  final barsWidth = 8.0 * constraints.maxWidth / 100;
                  return BarChart(
                    BarChartData(
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
                          setState(() {
                            print('start=========================');
                            print(rodIndex);
                            print(barTouchResponse.spot!.touchedRodDataIndex);
                            print(barTouchResponse.spot!.touchedStackItemIndex);
                            print('end=========================');
                          });
                        }, 
                      ),
                      titlesData: FlTitlesData(
                        // タイトルがtureだと見える
                        show: true,
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 28,
                            getTitlesWidget: bottomTitles,
                          ),
                        ),
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
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
                        checkToShowHorizontalLine: (value) => value % 2 == 0,
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
                      barGroups: getData(barsWidth, barsSpace),
                    ),
                  );
                },
              ),
            ),
          ),
        ),
      ],
    );
  }

  // 以下グラフ作成用
  double _barsWidth = 0;
  double _barsSpace = 0;

  // TimerUtilクラス
  TimerUtil tu = TimerUtil();
  // 1週間分の日付が入るリスト・メソッド
  List<DateTime> week = [];
  void weekPutDay() {
    for(int i = -1; i < 7; i++) {
      week.add(preNow.add(Duration(days: i + _plusDay)));
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

  void graphSet() async {
    // 前回データを削除（1週間の日にち）
    week = [];
    // 今回分の1週間前までの日にちをセット
    weekPutDay();
    // 前回データの削除（dayList, barChartGroupDate）
    dayList = {};
    barChartGroupDate = [];
    recordTags = await RecordDbTag.getAllGraphRecord();
    setState(() {
      // グラフに表示する各データを日付ごとに格納
      RecordDbTag? rdt = null;
      for (int j = 0; j < week.length; j++) {
        List<RecordDbTag> list = [];
        for (int i = 0; i < recordTags.length; i++) {
          if (rdt != null) {
            list.add(rdt);
            rdt = null;
          }
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
    });
  }

  // グラフの形等を指定するクラス群 getDataが一番最初に呼ばれる
  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    _barsWidth = barsWidth;
    _barsSpace = barsSpace;
    return barChartGroupDate;
  }
  BarChartGroupData MakeBarChartGroupData(int xInt, List<BarChartRodStackItem> rodStackItems) {
    return BarChartGroupData(
      x: xInt,
      barsSpace: _barsSpace,
      barRods: [
        BarChartRodData(
          color: Colors.transparent,
          toY: 24,
          rodStackItems: rodStackItems,
          borderRadius: BorderRadius.zero,
          width: _barsWidth,
        ),
      ]
    );
  }
  BarChartRodStackItem MakeBarChartRodStackItem(double start, double end, int color) {
    return BarChartRodStackItem(start, end, Color(color));
  }
  

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
