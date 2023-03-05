import 'package:flutter/material.dart';
import 'package:record/db.dart';
import '../util.dart';
import 'screenRoot.dart';

class RecordList extends ScreenRoot {
  @override
  Widget build(BuildContext context) {
    return RecordListStateful();
  }
}

class RecordListStateful extends StatefulWidget {
  @override
  RecordListState createState() => RecordListState();
} 

class RecordListState extends State<RecordListStateful> {
  List<RecordDbTag> recordTags = [];
  Future<void> initialize() async {
    recordTags = await RecordDbTag.getAllRecordDbTag();
  }
  // ScreenColor
  ScreenColor sc = ScreenColor();
  // TimerUtil
  TimerUtil tu = TimerUtil();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 620,
      child: FutureBuilder(
        future: initialize(),
        builder: (context2, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              final List<RecordDbTag> recordTagsDb = await RecordDbTag.getAllRecordDbTag();
              setState(() {
                recordTags = recordTagsDb;
              });
            },
            child: ListView.builder(
              itemCount: recordTags.length,
              itemBuilder: (context3, index) {
                return Card(
                  color: sc.baseColor,
                  margin: EdgeInsets.only(left: 10, top: 10, right: 10),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: sc.baseColor,
                      minimumSize: Size.zero,
                      padding: EdgeInsets.only(top: 10, right: 10, bottom: 10)
                    ),
                    onPressed: null,
                    onLongPress: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
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
                                  await RecordDb.deleteRecordList(recordTags[index].id!);
                                  final List<RecordDbTag> recordTagsDb = await RecordDbTag.getAllRecordDbTag();
                                  setState(() {
                                    recordTags = recordTagsDb;
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
                        },
                      );
                    },
                    child: Container(
                      child: Row(
                        children: <Widget>[
                          Icon(
                            Icons.bookmark,
                            color: Color(recordTags[index].color),
                            size: 80,
                          ),
                                    
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: <Widget>[
                                Container(
                                  width: double.infinity,
                                  child: ListText2(
                                    tu.stringDateTimeDate(
                                      tu.datetimeIntDate(
                                        recordTags[index].year,
                                        recordTags[index].month,
                                        recordTags[index].day,
                                        recordTags[index].hour,
                                        recordTags[index].minute,
                                        recordTags[index].second,
                                      )
                                    ),
                                    13
                                  ),
                                ),
                            
                                Container(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: <Widget>[
                                      ListText1(recordTags[index].tagText, 25),
                                      Row(
                                        children: <Widget>[
                                          Icon(Icons.history, color: Colors.white,),
                                          Sb('w', 10),
                                          ListText1(
                                            tu.stringDateTime(
                                              tu.dateTimeIntSeconds(recordTags[index].endToStartSecond)
                                            ),
                                            20
                                          ),
                                          Sb('w', 20),
                                          Icon(Icons.hourglass_bottom_outlined, color: Colors.white,),
                                          Sb('w', 10),
                                          ListText1(
                                            tu.stringDateTime(
                                              tu.dateTimeIntSeconds(recordTags[index].restSecond)
                                            ),
                                            20
                                          )
                                        ],
                                      ),
                                      Container(
                                        width: 105,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            // minimumSize: Size.zero,
                                            backgroundColor: Colors.white,
                                            padding: EdgeInsets.all(7)
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
                                                          recordTags[index].recordText,
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
                                          }
                                          ,
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
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}