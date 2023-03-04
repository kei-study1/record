import 'package:flutter/material.dart';
import 'package:record/db.dart';
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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 500,
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
                  child: Column(
                    children: <Widget>[
                      Text('${recordTags[index].id}'),
                      Text('${recordTags[index].recordText}'),
                      Text('${recordTags[index].year}'),
                      Text('${recordTags[index].month}'),
                      Text('${recordTags[index].day}'),
                      Text('${recordTags[index].hour}'),
                      Text('${recordTags[index].minute}'),
                      Text('${recordTags[index].second}'),
                      Text('${recordTags[index].endToStartSecond}'),
                      Text('${recordTags[index].restSecond}'),
                      Container(
                        width: double.infinity,
                        child: Column(
                          children: <Widget>[
                            Icon(
                              Icons.bookmark,
                              color: Color(recordTags[index].color),
                              size: 50,
                            ),
                            Container(
                              child: Text(
                                recordTags[index].tagText,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  
                                ),
                              )
                            ),
                          ],
                        ),
                      )
                    ],
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