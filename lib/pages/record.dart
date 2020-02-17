
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';



class Record extends StatefulWidget {
  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription<RecordStatus>_recorderSubscription;

 

  Future recording() async{

    
    Directory tempDir = await getApplicationDocumentsDirectory();
    File outputFile =  File ('${tempDir.path}/flutter1.aac');
    print(outputFile.path);

    String result = await flutterSound.startRecorder(uri: outputFile.path,codec: t_CODEC.CODEC_AAC,);
    print(result);

    _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
    });
  }

  Future stoping() async{
    String result = await flutterSound.stopRecorder();

    if (_recorderSubscription != null) {
          _recorderSubscription.cancel();
          _recorderSubscription = null;
    }
  }

  @override
  void initState() {
    // TODO: implement initState
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        title:  Text("Asistant"),
        backgroundColor: Colors.grey[900],
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Text("Record!"),
            FlatButton(
              child: Text("Record"),
              onPressed: () => recording(),
            ),
            FlatButton(
              child: Text("Stop Record"),
              onPressed: () => stoping(),
            ),
            FlatButton(child: Text("Play"),
            onPressed:() async{
              Directory tempDir = await getApplicationDocumentsDirectory();
              File outputFile =  File ('${tempDir.path}/flutter1.aac');
               await flutterSound.startPlayer(outputFile.path);
            }
            ,)

          ],

        ),
      ),
    );

  }
}
