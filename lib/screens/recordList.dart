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
  List<RecordDbTag> _recordTags = [];
    Future<void> initialize() async {
    _recordTags = await RecordDbTag.getAllRecordDbTag();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        ElevatedButton(
          onPressed: () async {
            final List<RecordDbTag> recordTags = await RecordDbTag.getAllRecordDbTag();
            setState(() {
              _recordTags = recordTags;
            });
          },
          child: Text('button'),
        ),
        Container(
          height: 500,
          child: FutureBuilder(
            future: initialize(),
            builder: (context2, snapshot) {
              if(snapshot.connectionState == ConnectionState.waiting){
                return Center(
                  child: CircularProgressIndicator(),
                );
              }
              return ListView.builder(
                itemCount: _recordTags.length,
                itemBuilder: (context3, index) {
                  return Card(
                    child: Column(
                      children: <Widget>[
                        Text('${_recordTags[index].id}'),
                        Text('${_recordTags[index].recordText}'),
                        Container(
                          width: double.infinity,
                          child: Column(
                            children: <Widget>[
                              Icon(
                                Icons.bookmark,
                                color: Color(_recordTags[index].color),
                                size: 50,
                              ),
                              Container(
                                child: Text(
                                  _recordTags[index].tagText,
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
              );
            },
          ),
        ),
      ],
    );
  }
}