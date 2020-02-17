
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';



class Record extends StatefulWidget {
  @override
  _RecordState createState() => _RecordState();
}

class _RecordState extends State<Record> {
  FlutterSound flutterSound = new FlutterSound();

  Future recording() async{
    String result = await flutterSound.startRecorder(codec: t_CODEC.CODEC_AAC,);

    var _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        String txt = DateFormat('mm:ss:SS', 'en_US').format(date);
    });
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
              onPressed: ()async{


              },
            ),
            FlatButton(
              child: Text("Stop Record"),
              onPressed: () async{

              },
            )

          ],

        ),
      ),
    );

  }
}
