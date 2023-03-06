import 'package:flutter/material.dart';
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
  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'Apr';
        break;
      case 1:
        text = 'May';
        break;
      case 2:
        text = 'Jun';
        break;
      case 3:
        text = 'Jul';
        break;
      case 4:
        text = 'Aug';
        break;
      case 5:
        text = 'test';
        break;
      default:
        text = '';
        break;
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
  }


  int touchedIndex = -1;
  bool isShadowBar(int rodIndex) => rodIndex == 1;
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: AspectRatio(
        aspectRatio: 0.8,
        child: Padding(
          padding: const EdgeInsets.only(top: 16),
          child: LayoutBuilder(
            builder: (context, constraints) {
              final barsSpace = 4.0 * constraints.maxWidth / 400;
              final barsWidth = 8.0 * constraints.maxWidth / 400;
              return BarChart(
                BarChartData(
                  alignment: BarChartAlignment.center,
                  barTouchData: BarTouchData(
                    // 基本的にはtrueにすると、トップの値が分かる
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(),
                    // touchCallback: (p0, p1) {
                    //   print('ss----------------');
                    //   print(p0);
                    //   print(p1);
                    //   print('ee----------------');
                    // },
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                if (!event.isInterestedForInteractions ||
                    barTouchResponse == null ||
                    barTouchResponse.spot == null) {
                  setState(() {
                    // touchedIndex = -1;
                  });
                  return;
                }
                final rodIndex = barTouchResponse.spot!.touchedRodDataIndex;
                // if (isShadowBar(rodIndex)) {
                //   setState(() {
                //     print(touchedIndex);
                //     print(rodIndex);
                //     touchedIndex = -1;
                //   });
                //   return;
                // }
                setState(() {
                  // print(touchedIndex);
                  // touchedIndex = barTouchResponse.spot!.touchedBarGroupIndex;
                  // print(touchedIndex);
                  print(rodIndex);
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
                    checkToShowHorizontalLine: (value) => value % 10 == 0,
                    getDrawingHorizontalLine: (value) => FlLine(
                      color: Colors.amber,
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
    );
  }

  List<BarChartGroupData> getData(double barsWidth, double barsSpace) {
    return [
      BarChartGroupData(
        x: 0,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 170000,
            rodStackItems: [
              BarChartRodStackItem(0, 20000, widget.dark),
              BarChartRodStackItem(20000, 120000, widget.normal),
              BarChartRodStackItem(120000, 170000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 240000,
            rodStackItems: [
              BarChartRodStackItem(0, 130000, widget.dark),
              BarChartRodStackItem(130000, 140000, widget.normal),
              BarChartRodStackItem(140000, 240000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            color: Colors.transparent,
            // gradient: LinearGradient(
            //   colors: [Colors.purple, Colors.red],
            //   begin: Alignment.topLeft,
            //   end: Alignment.bottomRight,
            // ),

            toY: 230000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 60000.5, widget.dark),
              BarChartRodStackItem(60000.5, 150000, widget.normal),
              BarChartRodStackItem(180000, 230000.5, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            // color: Colors.black,
            color: Colors.transparent,
            toY: 290000,
            rodStackItems: [
              BarChartRodStackItem(0, 50000, widget.dark),
              BarChartRodStackItem(60000, 80000, widget.light),
              BarChartRodStackItem(90000, 150000, widget.normal),
              BarChartRodStackItem(150000, 290000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 320000,
            rodStackItems: [
              BarChartRodStackItem(0, 20000.5, widget.dark),
              BarChartRodStackItem(20000.5, 170000.5, widget.normal),
              BarChartRodStackItem(170000.5, 320000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 1,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            // 透明色を入れた！
            color: Colors.transparent,
            toY: 410000,
            rodStackItems: [
              BarChartRodStackItem(0, 110000, widget.dark),
              BarChartRodStackItem(110000, 180000, widget.normal),
              BarChartRodStackItem(180000, 300000, widget.light),
            ],
            borderRadius: BorderRadius.circular(10),
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 400000,
            rodStackItems: [
              BarChartRodStackItem(0, 140000, widget.dark),
              BarChartRodStackItem(140000, 270000, widget.normal),
              BarChartRodStackItem(270000, 350000, widget.light),
            ],
            borderRadius: BorderRadius.circular(10),
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 310000,
            rodStackItems: [
              BarChartRodStackItem(0, 80000, widget.dark),
              BarChartRodStackItem(80000, 240000, widget.normal),
              BarChartRodStackItem(240000, 310000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 150000,
            rodStackItems: [
              BarChartRodStackItem(0, 60000.5, widget.dark),
              BarChartRodStackItem(60000.5, 120000.5, widget.normal),
              BarChartRodStackItem(120000.5, 150000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 170000,
            rodStackItems: [
              BarChartRodStackItem(0, 90000, widget.dark),
              BarChartRodStackItem(90000, 150000, widget.normal),
              BarChartRodStackItem(150000, 170000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 2,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 340000,
            rodStackItems: [
              BarChartRodStackItem(0, 60000, widget.dark),
              BarChartRodStackItem(60000, 230000, widget.normal),
              BarChartRodStackItem(230000, 340000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 320000,
            rodStackItems: [
              BarChartRodStackItem(0, 70000, widget.dark),
              BarChartRodStackItem(70000, 240000, widget.normal),
              BarChartRodStackItem(240000, 320000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 140000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 10000.5, widget.dark),
              BarChartRodStackItem(10000.5, 120000, widget.normal),
              BarChartRodStackItem(120000, 140000.5, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 200000,
            rodStackItems: [
              BarChartRodStackItem(0, 40000, widget.dark),
              BarChartRodStackItem(40000, 150000, widget.normal),
              BarChartRodStackItem(150000, 200000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 240000,
            rodStackItems: [
              BarChartRodStackItem(0, 40000, widget.dark),
              BarChartRodStackItem(40000, 150000, widget.normal),
              BarChartRodStackItem(150000, 240000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),
      BarChartGroupData(
        x: 3,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 140000,
            rodStackItems: [
              BarChartRodStackItem(0, 10000.5, widget.dark),
              BarChartRodStackItem(10000.5, 120000, widget.normal),
              BarChartRodStackItem(120000, 140000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 270000,
            rodStackItems: [
              BarChartRodStackItem(0, 70000, widget.dark),
              BarChartRodStackItem(70000, 250000, widget.normal),
              BarChartRodStackItem(250000, 270000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 290000,
            rodStackItems: [
              BarChartRodStackItem(0, 60000, widget.dark),
              BarChartRodStackItem(60000, 230000, widget.normal),
              BarChartRodStackItem(230000, 290000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 160000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 90000, widget.dark),
              BarChartRodStackItem(90000, 150000, widget.normal),
              BarChartRodStackItem(150000, 160000.5, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 150000,
            rodStackItems: [
              BarChartRodStackItem(0, 70000, widget.dark),
              BarChartRodStackItem(70000, 120000.5, widget.normal),
              BarChartRodStackItem(120000.5, 150000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),

      BarChartGroupData(
        x: 5,
        barsSpace: barsSpace,
        barRods: [
          BarChartRodData(
            toY: 140000,
            rodStackItems: [
              BarChartRodStackItem(0, 10000.5, widget.dark),
              BarChartRodStackItem(10000.5, 120000, widget.normal),
              BarChartRodStackItem(120000, 140000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 160000.5,
            rodStackItems: [
              BarChartRodStackItem(0, 90000, widget.dark),
              BarChartRodStackItem(90000, 150000, widget.normal),
              BarChartRodStackItem(150000, 160000.5, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
          BarChartRodData(
            toY: 150000,
            rodStackItems: [
              BarChartRodStackItem(0, 70000, widget.dark),
              BarChartRodStackItem(70000, 120000.5, widget.normal),
              BarChartRodStackItem(120000.5, 150000, widget.light),
            ],
            borderRadius: BorderRadius.zero,
            width: barsWidth,
          ),
        ],
      ),

    ];
  }
}
