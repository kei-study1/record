import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
  int _restSeconds = 0;
  // String _countTimer = '00:00:00';
  String _countTimer = '00:00:00';
  bool _buttonOn = false;
  bool _timeVisible = false;
  late DateTime? _startTime = null;
  late DateTime? _endTime = null;
  late DateTime? _restTime = null;
  // Tag color
  int _tagColor = 1;
  int _tagColorCord = 0xffff0000;
  // Tag Dialog
  bool _stopRegistFlg = false;
  // TimerUtil
  TimerUtil tu = TimerUtil();
  // Tagクラス
  List<Tag> _tagList = [];
  int _tagSelect = 0;
  Future<void> initialize() async {
    await Tag.insertOtherTag();
    _tagList = await Tag.getTags();
  }
  // test
  List<RecordDb> _recordList = [];

  // TextField
  final recordController = TextEditingController();
  final myController = TextEditingController();
  var _selectedvalue;

  final focusNode = FocusNode();

  void _buttonPress() {
    setState(() {
      if (_startTime == null) {
        _startTime = DateTime.now();
      }
      _buttonOn = !_buttonOn;
      if(_buttonOn) {
        _timer = Timer.periodic(
          Duration(milliseconds: 500),
          _onTimer
        );
        _timeVisible = true;
        _restSeconds = tu.intSecondsDateTimeBetween(_startTime, DateTime.now()) - _seconds;
        if (_endTime != null) {
          _restTime = tu.dateTimeIntSeconds(
            _restSeconds
          );
        }
        _endTime = null;
      } else {
        _timer.cancel();
        _endTime = tu.dateTimeIntSeconds(
          tu.intSecondsDateTime(_startTime!)
          + _seconds + _restSeconds
        );
      }
    });
  }
  void _onTimer(Timer t) {
    _seconds = tu.intSecondsDateTimeBetween(_startTime, DateTime.now()) - _restSeconds;
    setState(() {
      _countTimer = tu.stringDateTime(tu.dateTimeIntSeconds(_seconds));
    });
  }
  void _resetTimer(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          contentPadding: EdgeInsets.all(10),
          backgroundColor: sc.baseColor,
          children: <Widget>[
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'タイマーを\nリセットしますか？',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    color: Colors.white
                  ),
                ),
                Sb('h', 20)
              ],
            ),
            SimpleDialogOption(
              onPressed: () {
                setState(() {
                  _timer.cancel();
                  _seconds = 0;
                  _restSeconds = 0;
                  _countTimer = '00:00:00';
                  _buttonOn = false;
                  _startTime = null;
                  _endTime = null;
                  _restTime = null;
                  _timeVisible = false;
                });
                Navigator.pop(context);
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
                Navigator.pop(context);
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
      }
    );
  }
  void _tagChoice(int i) {
    setState(() {
      _tagSelect = i;
    });
  }
  void _tagDeleteDialog(BuildContext context, int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        contentPadding: EdgeInsets.all(10),
        backgroundColor: sc.baseColor,
        children: (_tagList[i].id != 1)? <Widget>[
        // children: (i != 0)? <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _tagList[i].text,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: sc.subColor
                ),
              ),
              Text(
                'を削除しますか？',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ),
              ),
            ],
          ),
          SimpleDialogOption(
            onPressed: () async {
              await Tag.deleteTag(_tagList[i].id!);
              final List<Tag> tags = await Tag.getTags();
              print(_tagSelect);
              print(i);
              setState(() {
                _tagList = tags;
                // 選択状態のタグを消した時は、一番上を選択にする
                if (_tagSelect == i) {
                  _tagSelect = 0;
                } else if (_tagSelect > i) {
                  _tagSelect--;
                }
              });
              Navigator.pop(context);
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
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('NO', style: TextStyle(color: Colors.white, fontSize: 20),),
              ],
            ),
          ),
        ] :
        <Widget> [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'その他',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: sc.subColor
                ),
              ),
              Text(
                'は削除できません',
                style: TextStyle(
                  fontSize: 20,
                  color: Colors.white
                ),
              ),
            ],
          ),
        ]
        ,
      )
    );
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
      backgroundColor: (_tagColor == tagNo) ? sc.baseColor2 : sc.baseColor3,
      foregroundColor: Color(tagColorCord),
      shape: CircleBorder(
        side: BorderSide(
          color: (_tagColor == tagNo) ? sc.subColor! : sc.baseColor3!,
          width: 5,
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
        child: Column(
          children: <Widget>[
            Sb('h', 10),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  flex: 1,
                  child: Container(),
                ),

                Expanded(
                  flex: 22,
                  child: Container(
                    // color: sc.baseColor,
                    height: 500,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: <Widget>[
                        
                        Card(
                          color: _buttonOn? sc.subColor : sc.baseColor,
                          child: Container(
                            padding: EdgeInsets.only(left: 10, top: 15, bottom: 15),
                            width: double.infinity,
                            child: Row(
                              children: <Widget>[
                                Icon(Icons.history, color: Colors.white, size: 40,),
                                Sb('w', 10),
                                Text(
                                  _countTimer,
                                  style: TextStyle(
                                    fontSize: 40,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                  
                        Sb('h', 10),
                  
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            FloatingActionButton(
                              // なんとなくタグの全件削除を入れている。
                              // onPressed: () async {
                              //   await Tag.deleteAllTag();
                              //   final List<Tag> tags = await Tag.getTags();
                              //   setState(() {
                              //     _tagList = tags;
                              //     _selectedvalue = null;
                              //   });
                              // },
                              // splashColor: sc.subColor,

                              onPressed: () => _resetTimer(context),

                              // onPressed: () async {
                              //   await RecordDb.deleteAllRecord();
                              // },
                              backgroundColor: Colors.red,
                              child: Icon(Icons.refresh, size: 40,),
                            ),
                  
                            FloatingActionButton(
                              onPressed: _buttonPress,
                              splashColor: _buttonOn ? sc.subColor : sc.baseColor,
                              backgroundColor: _buttonOn ? sc.baseColor : sc.subColor,
                              child: Icon(_buttonOn ? Icons.stop_circle_outlined : Icons.play_circle_outline, size: 40,),
                            ),
                          ],
                        ),
                  
                        Sb('h', 10),

                        (_timeVisible)?
                        Container(
                          padding: EdgeInsets.all(10),
                          // color: sc.baseColor,
                          decoration: BoxDecoration(
                            color: sc.baseColor,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Column(
                            children: <Widget>[
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // ConText('START', 75, 20),
                                  // ConText(':', 20, 20),
                                  Icon(Icons.play_circle_outline, color: Colors.white, size: 35,),
                                  ConText(
                                    (_startTime == null)? '' :
                                    tu.stringDateTime(_startTime!),
                                    160,
                                    30
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // ConText('END', 75, 20),
                                  // ConText(':', 20, 20),
                                  Icon(Icons.stop_circle_outlined, color: Colors.white, size: 35,),
                                  ConText(
                                    (_endTime == null)? '' :
                                    tu.stringDateTime(_endTime!),
                                    160,
                                    30
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  // ConText('REST', 75, 20),
                                  // ConText(':', 20, 20),
                                  Icon(Icons.hourglass_bottom_outlined, color: Colors.white,size: 35,),
                                  ConText(
                                    (_restTime == null)? '' :
                                    tu.stringDateTime(_restTime!),
                                    160,
                                    30
                                  ),
                                ],
                              ),
                            ],
                          )
                        ) :
                        Sb('h', 35 * 3 + 10 * 2)
                        ,

                        Sb('h', 10),
                  
                        Container(
                          // color: Colors.white,
                          width: double.infinity,
                          child:  TextField(
                            controller: recordController,
                            maxLines: 4,
                            style: TextStyle(
                              color: Colors.white
                            ),
                            decoration: InputDecoration(
                              hintText: "memo",
                              hintStyle: TextStyle(
                                color: Colors.white
                              ),
                              fillColor: sc.baseColor,
                              filled: true,
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: Colors.white
                                )
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(
                                  color: sc.subColor!
                                )
                              ),
                            ),
                          ),
                        ),
                  
                        Sb('h', 10),
                  
                        Container(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed:
                            (_seconds == 0)?
                            () {} :
                            () async {
                              RecordDb _record = RecordDb(
                                text: recordController.text,
                                tagId: _tagList[_tagSelect].id!,
                                year: tu.intDateTimes(_startTime)[0],
                                month: tu.intDateTimes(_startTime)[1],
                                day: tu.intDateTimes(_startTime)[2],
                                hour: tu.intDateTimes(_startTime)[3],
                                minute: tu.intDateTimes(_startTime)[4],
                                second: tu.intDateTimes(_startTime)[5],
                                endToStartSecond: _seconds,
                                restSecond: _restSeconds
                                );
                              await RecordDb.insertRecord(_record);
                              setState(() {
                                _selectedvalue = null;
                                _timer.cancel();
                                _seconds = 0;
                                _restSeconds = 0;
                                _countTimer = '00:00:00';
                                _buttonOn = false;
                                _startTime = null;
                                _endTime = null;
                                _restTime = null;
                                _timeVisible = false;
                                _tagSelect = 0;
                              });
                              recordController.clear();
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sc.subColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                            ),
                            child: Text(
                              'REGISTER',
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
                    // height: MediaQuery.of(context).size.height,
                    child: Column(
                      children: <Widget>[
                        ElevatedButton(
                          onPressed: () {
                            showDialog(
                              context: context,
                              builder: (context) {
                                return StatefulBuilder(
                                  builder: (context, dialogState) {
                                    return Focus(
                                      focusNode: focusNode,
                                      child: GestureDetector(
                                        onTap: focusNode.requestFocus,
                                        child: AlertDialog(
                                          backgroundColor: sc.baseColor,
                                          content: Container(
                                            width: 200,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: <Widget>[
                                                const Text(
                                                  "TO DO",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20
                                                  ),
                                                ),
                                                (_stopRegistFlg)? 
                                                  Text('やることを記入してください！', style: TextStyle(color: Colors.red),) 
                                                  : Container(),
                                                TextField(
                                                  controller: myController,
                                                  onChanged: (text) {
                                                    dialogState(() {
                                                      myController;
                                                      if (text.length > 0) {
                                                        _stopRegistFlg = false;
                                                      }
                                                    });
                                                  },
                                                  maxLength: 15,
                                                  maxLengthEnforcement: MaxLengthEnforcement.truncateAfterCompositionEnds,
                                                  style: TextStyle(
                                                    color: Colors.white
                                                  ),
                                                  decoration: InputDecoration(
                                                    helperStyle: TextStyle(
                                                      color: Colors.white
                                                    ),
                                                    fillColor: sc.baseColor,
                                                    filled: true,
                                                    enabledBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: Colors.white
                                                      )
                                                    ),
                                                    focusedBorder: UnderlineInputBorder(
                                                      borderSide: BorderSide(
                                                        color: sc.subColor!
                                                      )
                                                    ),
                                                  ),
                                                ),
                                                                            
                                                const Text(
                                                  "COLOR SELECT",
                                                  style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 20
                                                  ),
                                                ),
                                                                            
                                                Sb('h', 10),
                                                                            
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    TagButton(dialogState, 1, 0xffff0000),
                                                    TagButton(dialogState, 2, 0xffff007f),
                                                    TagButton(dialogState, 3, 0xffff00ff),
                                                    TagButton(dialogState, 4, 0xff7f00ff),
                                                  ],
                                                ),
                                                Sb('h', 2),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    TagButton(dialogState, 5, 0xff0000ff),
                                                    TagButton(dialogState, 6, 0xff007fff),
                                                    TagButton(dialogState, 7, 0xff00ffff),
                                                    TagButton(dialogState, 8, 0xff00ff7f),
                                                  ],
                                                ),
                                                Sb('h', 2),
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: <Widget>[
                                                    TagButton(dialogState, 9, 0xff00ff00),
                                                    TagButton(dialogState, 10, 0xff7fff00),
                                                    TagButton(dialogState, 11, 0xffffff00),
                                                    TagButton(dialogState, 12, 0xffff7f00),
                                                  ],
                                                ),
                                                                            
                                                Sb('h', 10),
                                                                            
                                                Container(
                                                  width: double.infinity,
                                                  child: ElevatedButton(
                                                    child: Text('REGISTER', style: TextStyle(fontSize: 20),),
                                                    style: ElevatedButton.styleFrom(
                                                      backgroundColor: sc.subColor,
                                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                                                    ),
                                                    onPressed: (myController.text.length == 0)? 
                                                      () {
                                                        dialogState(() {
                                                          _stopRegistFlg = true;
                                                        });
                                                      }
                                                      : () async {
                                                      Tag _tag = Tag(text: myController.text, color: _tagColorCord, visibleFlg: 1);
                                                      await Tag.insertTag(_tag);
                                                      final List<Tag> tags = await Tag.getTags();
                                                      setState(() {
                                                        _tagList = tags;
                                                        _selectedvalue = null;
                                                      });
                                                      myController.clear();
                                                      Navigator.pop(context);
                                                    },
                                                    // onPressed: (myController.text.length == 0)? null :
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
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
                                    'add',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      
                                    ),
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),

                        Sb('h', 5),

                        Container(
                          height: 416,
                          // height: MediaQuery.of(context).size.height,
                          child: FutureBuilder(
                            future: initialize(),
                            builder: (context2, snapshot) {
                              // if(snapshot.connectionState == ConnectionState.waiting) {
                              //   // 非同期処理未完了 = 通信中
                              //   return Center(
                              //     child: CircularProgressIndicator(),
                              //   );
                              // }
                              return ListView.builder(
                                itemCount: _tagList.length,
                                itemBuilder: (context2, index) {
                                  return Column(
                                    children: <Widget> [
                                      ElevatedButton(
                                        onPressed: () => _tagChoice(index),
                                        onLongPress: () => _tagDeleteDialog(context2, index),
                                        style: ElevatedButton.styleFrom(
                                          padding: EdgeInsets.all(3),
                                          backgroundColor: sc.baseColor,
                                          side: BorderSide(
                                            color: (_tagSelect == index)? sc.subColor! : sc.baseColor!,
                                            width: 3
                                          )
                                        ),
                                        child: Container(
                                          width: double.infinity,
                                          child: Column(
                                            children: <Widget>[
                                              Icon(
                                                Icons.bookmark,
                                                color: Color(_tagList[index].color),
                                                size: 50,
                                              ),
                                              Container(
                                                child: Text(
                                                  _tagList[index].text,
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    
                                                  ),
                                                )
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Sb('h', 5)
                                    ]

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
          ],
        ),
      ),
    );
  }
}

