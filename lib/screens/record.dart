import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'screenRoot.dart';
import '../db.dart';
import '../util.dart';
import 'package:sqflite/sqflite.dart';
import 'package:intl/intl.dart';
import 'dart:async';


class Record extends ScreenRoot {
  @override
  Widget build(BuildContext context) {
    return Container(
      child: RecordStateful(),
    );
  }
}

class RecordStateful extends StatefulWidget {
  @override
  RecordState createState() => RecordState();
}

class RecordState extends State<RecordStateful> {
  // ScreenColor
  ScreenColor sc = ScreenColor();
  // Timer用
  late Timer _timer;
  int _seconds = 0;
  String _countTimer = '00:00:00';
  bool _buttonOn = false;
  late DateTime? _startTime = null;
  late DateTime? _endTime = null;
  late DateTime? _restTime = null;
  // Tag color
  int _tagColor = 1;
  int _tagColorCord = 0;
  // TimerUtil
  TimerUtil tu = TimerUtil();
  // Tagクラス
  List<Tag> _tagList = [];
  Future<void> initialize() async {
    _tagList = await Tag.getTags();
  }
  // TextField
  final myController = TextEditingController();
  var _selectedvalue;

  void _buttonPress() {
    setState(() {
      if (_startTime == null) {
        _startTime = DateTime.now();
      }
      _buttonOn = !_buttonOn;
      if(_buttonOn) {
        _timer = Timer.periodic(
          Duration(seconds: 1),
          _onTimer
        );
        if (_endTime != null) {
          _restTime = tu.dateTimeIntSeconds(
            tu.intSecondsDateTimeBetween(_startTime, DateTime.now()) - _seconds
          );
        }
        _endTime = null;
      } else {
        _timer.cancel();
        _endTime = DateTime.now();
      }
    });
  }
  void _onTimer(Timer t) {
    _seconds++;
    setState(() {
      _countTimer = tu.stringDateTime(tu.dateTimeIntSeconds(_seconds));
    });
  }

  // タグ表示用Widget
  Widget TagButton(StateSetter dialogState, int tagNo, int tagColorCord) {
    return FloatingActionButton(
      // onPressed: () => tagChoice(dialogState, tagNo),
      onPressed: () {
        dialogState(() {
          _tagColor = tagNo;
          _tagColorCord = tagColorCord;
        });
        print('$_tagColor' + ' : ' +  '$_tagColorCord');
      },
      backgroundColor: Colors.white,
      foregroundColor: Color(tagColorCord),
      shape: CircleBorder(
        side: BorderSide(
          color: (_tagColor == tagNo) ? Colors.blue : Colors.white,
          width: 3,
        )
      ),
      child: Icon(
        Icons.bookmark,
        size: 30,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      child: SingleChildScrollView(
        child: Row(
          children: <Widget>[
            Expanded(
              flex: 1,
              child: Container(),
            ),

            Expanded(
              flex: 22,
              child: Container(
                height: 500,
                color: Colors.blue,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    
                    Card(
                      color: _buttonOn? sc.baseColor : Color.fromARGB(255, 167, 157, 133),
                      child: Container(
                        padding: EdgeInsets.only(left: 17, top: 8, bottom:8),
                        width: double.infinity,
                        child: Text(
                          _countTimer,
                          style: TextStyle(
                            fontSize: 50,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
              
                    Sb('h', 10),
              
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        FloatingActionButton(
                          onPressed: (){},
                          splashColor: sc.subColor,
                          backgroundColor: sc.baseColor,
                          child: Icon(Icons.restart_alt, size: 40,),
                        ),
              
                        FloatingActionButton(
                          onPressed: _buttonPress,
                          splashColor: _buttonOn ? sc.baseColor : sc.subColor,
                          backgroundColor: _buttonOn ? sc.subColor : sc.baseColor,
                          child: Icon(_buttonOn ? Icons.stop_circle_outlined : Icons.play_circle_outline, size: 40,),
                        ),
                      ],
                    ),
              
                    Sb('h', 10),

                    Container(
                      child: Column(
                        children: <Widget>[
                          Row(
                            children: <Widget>[
                              ConText('開始時刻：', 100, 20),
                              ConText(
                                (_startTime == null)? '' :
                                tu.stringDateTime(_startTime!),
                                150,
                                30
                              ),
                            ],
                          ),

                          Row(
                            children: <Widget>[
                              ConText('終了時刻：', 100, 20),
                              ConText(
                                (_endTime == null)? '' :
                                tu.stringDateTime(_endTime!),
                                150,
                                30
                              ),
                            ],
                          ),

                          Row(
                            children: <Widget>[
                              ConText('休憩時刻：', 100, 20),
                              ConText(
                                (_restTime == null)? '' :
                                tu.stringDateTime(_restTime!),
                                150,
                                30
                              ),
                            ],
                          ),
                        ],
                      )
                    ),
              
                    Container(
                      color: Colors.white,
                      width: double.infinity,
                      child: const TextField(
                        maxLines: 4,
                        decoration: InputDecoration(
                          hintText: "memo",
                          enabledBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange
                            )
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(
                              color: Colors.orange
                            )
                          ),
                        ),
                      ),
                    ),
              
                    Sb('h', 10),
              
                    Container(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: sc.baseColor,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ),
                        child: Text(
                          '登録する',
                          style: TextStyle(
                            fontSize: 20
                          ),
                        )
                      ),
                    ),
              
                  ],
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(),
            ),

            Expanded(
              flex: 7,
              child: Container(
                height: 500,
                color: Colors.red,
                child: Column(
                  children: <Widget>[
                    ElevatedButton(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return StatefulBuilder(
                              builder: (context, dialogState) {
                                return AlertDialog(
                                  title: Text("教材の登録"),
                                  content: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[
                                      TextField(
                                        controller: myController,
                                        maxLength: 15,
                                      ),

                                      Text('色の登録'),

                                      Row(
                                        children: <Widget>[
                                          // FloatingActionButton(
                                          //   onPressed: () => tagChoice(dialogState),
                                          //   backgroundColor: Colors.white,
                                          //   foregroundColor: Color(0xffff0000),
                                          //   shape: CircleBorder(
                                          //     side: BorderSide(
                                          //       color: (_tagColor == 1) ? Colors.blue : Colors.white,
                                          //       width: 3,
                                          //     )
                                          //   ),
                                          //   child: Icon(
                                          //     Icons.bookmark,
                                          //     size: 30,
                                          //   ),
                                          // ),

                                          // TagButton(dialogState),
                                          TagButton(dialogState, 2, 0xffff0000),
                                          TagButton(dialogState, 3, 0xff00ff00),
                                        ],
                                      ),

                                      ElevatedButton(
                                        child: Text('保存'),
                                        onPressed: () async {
                                          Tag _tag = Tag(text: myController.text, color: 11111, visibleFlg: 1);
                                          await Tag.insertTag(_tag);
                                          final List<Tag> tags = await Tag.getTags();
                                          setState(() {
                                            _tagList = tags;
                                            _selectedvalue = null;
                                          });
                                          myController.clear();
                                          Navigator.pop(context);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                            
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: EdgeInsets.all(3),
                        backgroundColor: sc.baseColor,
                      ),
                      child: Container(
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.bookmark_add,
                              size: 50,
                            ),
                            Container(
                              child: Text(
                                'あああああああああああああああ',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  
                                ),
                              )
                            ),
                          ],
                        ),
                      ),
                    ),
                    Container(
                      height: 300,
                      color: Colors.yellow,
                      child: FutureBuilder(
                        future: initialize(),
                        builder: (context, snapshot) {
                          // if(snapshot.connectionState == ConnectionState.waiting) {
                          //   // 非同期処理未完了 = 通信中
                          //   return Center(
                          //     child: CircularProgressIndicator(),
                          //   );
                          // }
                          return ListView.builder(
                            itemCount: _tagList.length,
                            itemBuilder: (context, index) {
                              return Container(
                                height: 20,
                                color: Colors.blue,
                                child: Text(
                                  // '${_tagList[index].id}'
                                  _tagList.elementAt(index).text
                                ),
                              );
                            },
                          );
                        },
                      ),
                    )

                  ],
                ),
              ),
            ),

            Expanded(
              flex: 1,
              child: Container(),
            ),
          ],
        ),
      ),
    );
  }
}

