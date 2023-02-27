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
  int _tagColorCord = 0xffff0000;
  // Tag Dialog
  bool _stopRegistFlg = false;
  // TimerUtil
  TimerUtil tu = TimerUtil();
  // Tagクラス
  List<Tag> _tagList = [];
  int _tagSelect = -1;
  Future<void> initialize() async {
    _tagList = await Tag.getTags();
  }
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
  void _tagChoice(int i) {
    setState(() {
      _tagSelect = i;
    });
  }
  void _tagDeleteDialog(BuildContext context, int i) {
    showDialog(
      context: context,
      builder: (BuildContext context) => SimpleDialog(
        backgroundColor: sc.baseColor,
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '「' + _tagList[i].text + '」',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 25,
                  color: sc.subColor
                ),
              ),
              Text(
                'を削除しますか？',
                style: TextStyle(
                  fontSize: 25,
                  color: Colors.white
                ),
              ),
            ],
          ),
          SimpleDialogOption(
            onPressed: () async {
              await Tag.deleteTag(_tagList[i].id!);
              final List<Tag> tags = await Tag.getTags();
              setState(() {
                _tagList = tags;
              });
              Navigator.pop(context);
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text('yes', style: TextStyle(color: Colors.white, fontSize: 20),),
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
                Text('no', style: TextStyle(color: Colors.white, fontSize: 20),),
              ],
            ),
          ),
        ],
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
      backgroundColor: sc.baseColor3,
      foregroundColor: Color(tagColorCord),
      shape: CircleBorder(
        side: BorderSide(
          color: (_tagColor == tagNo) ? sc.subColor! : sc.baseColor3!,
          width: 7,
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
                          color: _buttonOn? sc.baseColor : sc.baseColor2,
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
                              // なんとなくタグの全件削除を入れている。
                              onPressed: () async {
                                await Tag.deleteAllTag();
                                final List<Tag> tags = await Tag.getTags();
                                setState(() {
                                  _tagList = tags;
                                  _selectedvalue = null;
                                });
                              },
                              // splashColor: sc.subColor,
                              backgroundColor: Colors.red,
                              child: Icon(Icons.restart_alt, size: 40,),
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
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: sc.subColor,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                            ),
                            child: Text(
                              '登録',
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
                                          content: Column(
                                            mainAxisSize: MainAxisSize.min,
                                            children: <Widget>[
                                              const Text(
                                                "やることの登録",
                                                style: TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 20
                                                ),
                                              ),
                                              (_stopRegistFlg)? 
                                                Text('やることを記入してください！', style: TextStyle(color: Colors.red),) 
                                                : Container(),
                                              TextField(
                                                onChanged: (text) {
                                                  if (text.length > 0) {
                                                    dialogState(() {
                                                      _stopRegistFlg = false;
                                                    });
                                                  }
                                                },
                                                controller: myController,
                                                maxLength: 15,
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
                                                "色の選択",
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
                                                  child: Text('登録', style: TextStyle(fontSize: 20),),
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

                        ElevatedButton(
                          onPressed: () => _tagChoice(-1),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.all(3),
                            backgroundColor: sc.baseColor,
                            side: BorderSide(
                              color: (_tagSelect == -1)? sc.subColor! : sc.baseColor!,
                              width: 3
                            )
                          ),
                          child: Container(
                            width: double.infinity,
                            child: Column(
                              children: <Widget>[
                                Icon(
                                  Icons.bookmark,
                                  color: Colors.white,
                                  size: 50,
                                ),
                                Container(
                                  child: Text(
                                    'その他',
                                    textAlign: TextAlign.center,
                                  )
                                ),
                              ],
                            ),
                          ),
                        ),
                        Sb('h', 5),

                        Container(
                          height: 450,
                          // height: MediaQuery.of(context).size.height,
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
                                  return Column(
                                    children: <Widget> [
                                      ElevatedButton(
                                        onPressed: () => _tagChoice(index),
                                        onLongPress: () => _tagDeleteDialog(context, index),
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

