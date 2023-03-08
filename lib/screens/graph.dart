import 'package:flutter/material.dart';
import '../db.dart';
import '../util.dart';
import 'screenRoot.dart';
import 'package:fl_chart/fl_chart.dart';

// import 'package:fl_chart_app/presentation/resources/app_resources.dart';
// import 'package:fl_chart_app/util/extensions/color_extensions.dart';


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
  // ScreenColor
  ScreenColor sc = ScreenColor();

  Widget bottomTitles(double value, TitleMeta meta) {
    var style = TextStyle(fontSize: 10, color: Colors.white);
    int day;
    /*
    valueの値とxIntの値が対応しているっぽいので
    xIntの表示順にcase句を並び替えた。
    caseにはconst値しか使えないっぽいため。
    */
    switch (value.toInt()) {
      case 6:
        day = now.add(Duration(days: -6)).day;
        break;
      case 5:
        day = now.add(Duration(days: -5)).day;
        break;
      case 4:
        day = now.add(Duration(days: -4)).day;
        break;
      case 3:
        day = now.add(Duration(days: -3)).day;
        break;
      case 2:
        day = now.add(Duration(days: -2)).day;
        break;
      case 1:
        day = now.add(Duration(days: -1)).day;
        break;
      case 0:
        day = now.day;
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
        ElevatedButton(
          onPressed: graphSet,
          child: Text('ボタン'),
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
                  final barsWidth = 8.0 * constraints.maxWidth / 400;
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
                            setState(() {
                              // touchedIndex = -1;
                            });
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


  // 1週間分のグラフの作成
  List<RecordDbTag> recordTags = [];
  // 1週間分の日付が入ったリスト
  List<DateTime> week = [];
  void weekPutDay() {
    for(int i = 0; i < 7; i++) {
      week.add(now.add(Duration(days: - i)));
    }
  }

  TimerUtil tu = TimerUtil();
  // dayListに今日の日づけ-j日の形で使うデータが入っている。
  // グラフの24時間対応するならここで調整すると思う。
  Map<int, List<RecordDbTag>> dayList = {};

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
      for (int j = 0; j < week.length; j++) {
        List<RecordDbTag> list = [];
        for (int i = 0; i < recordTags.length; i++) {
          DateTime d = tu.datetimeIntDate(recordTags[i].year, recordTags[i].month, recordTags[i].day, 0, 0, 0);
          if (d.year == week[j].year && d.month == week[j].month && d.day == week[j].day) {
            list.add(recordTags[i]);
          }
        }
        dayList[week[j].day] = list;
      }

      // グラフに表示するデータをRodグラフに表示用にセット
      for (int j = week.length - 1; j >= 0; j--) {
        List<BarChartRodStackItem> rodStackItems = [];

        for (int i = 0; i < dayList[week[j].day]!.length; i++) {
          RecordDbTag rt = dayList[week[j].day]![i];
          double start = tu.doubleStartInt(rt.hour, rt.minute, rt.second);
          double end = tu.doubleEndInt(start, rt.endToStartSecond);
          rodStackItems.add(MakeBarChartRodStackItem(start, end, rt.color));
        }

        // barChartGroupDate.add(MakeBarChartGroupData(week[j].day, rodStackItems));
        barChartGroupDate.add(MakeBarChartGroupData(j, rodStackItems));
      }
    });
  }

  BarChartGroupData MakeBarChartGroupData(int xInt, List<BarChartRodStackItem> rodStackItems) {
    return BarChartGroupData(
      x: xInt,
      barsSpace: 80,
      barRods: [
        BarChartRodData(
          color: Colors.transparent,
          toY: 24,
          rodStackItems: rodStackItems,
          borderRadius: BorderRadius.zero,
          width: 20,
        ),
      ]
    );
  }
  List<BarChartGroupData> barChartGroupDate = [];

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
  BarChartRodStackItem MakeBarChartRodStackItem(double start, double end, int color) {
    return BarChartRodStackItem(start, end, Color(color));
  }



  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    return barChartGroupDate;
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
  }
}
