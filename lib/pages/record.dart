
import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:qrscan/qrscan.dart' as scanner;
import 'package:qr_flutter/qr_flutter.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:assistant/services/record_class.dart';



class Record extends StatefulWidget {
  @override
  _RecordState createState() => _RecordState();
}



class _RecordState extends State<Record> {
  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription<RecordStatus>_recorderSubscription;
  List<RecordClass> recordList = [];
  int id = 0;
  

  bool record_status = false;
  bool did_record = false;
  Icon record_icon = Icon(
    Icons.mic,
    color: Colors.black,
  );
  TextEditingController qrCodeDescription = TextEditingController();

  String record_seconds = '00:00:000';
  Icon play_icon = Icon(Icons.play_arrow);
  File outputFile;


  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  
  void _submit() {
    SnackBar snackBar = new SnackBar(
        content: new Text("Changes saved at " + new DateTime.now().toString()));
    _scaffoldKey.currentState.showSnackBar(snackBar);
  }
  bool isRecordedToDatabase;
  
  Future recordToDatabase() async{
    setState(() {
      
      isRecordedToDatabase = true;
    });
  }

  Future recording() async{
    Directory tempDir = await getApplicationDocumentsDirectory();
    outputFile =  File ('${tempDir.path}/flutter$id.aac');
    print(outputFile.path);

    String result = await flutterSound.startRecorder(uri: outputFile.path,codec: t_CODEC.CODEC_AAC,);
    print(result);

    _recorderSubscription = flutterSound.onRecorderStateChanged.listen((e) {
        DateTime date = new DateTime.fromMillisecondsSinceEpoch(e.currentPosition.toInt());
        setState(() {
          record_seconds = DateFormat('mm:ss:SS', 'en_US').format(date);
        });
        
    });
  }

  Future stoping() async{
    String result = await flutterSound.stopRecorder();

    if (_recorderSubscription != null) {
          _recorderSubscription.cancel();
          _recorderSubscription = null;
    }
  }

  String qrCodeData;
  Future  qrCodeReader() async{
    String data = await scanner.scan();
    for( var i = 0 ; i< recordList.length; i++ ) { 
      if(recordList[i].qrCodeValue == data ){
        data = "Herhangi bir QR kod okutulmadı!"; 
        Fluttertoast.showToast(
        msg: "Bu QR kod başka bir kayıt tarafından kullanılmaktadır!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
      );
      }
    } 
    setState(() {
      qrCodeData = data;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    if(qrCodeData==null){
      qrCodeData = "Herhangi bir QR kod okutulmadı!"; 
    }
    id = new DateTime.now().millisecondsSinceEpoch;
  }
  

  
  @override
  Widget build(BuildContext context) {
    Map data = ModalRoute.of(context).settings.arguments;
    recordList = data["recordList"];
    return Scaffold(
      backgroundColor: Color(0xFF347474),
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            IconButton(
              icon: Icon(Icons.arrow_back_ios),
              onPressed: (){
                Navigator.pushReplacementNamed(context,'/',arguments: {
                      "recordList":recordList,
                });
              },

            ),
            Text("Asistant")
          ],
        ),
        backgroundColor: Color(0xFF35495e),
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.save),
        backgroundColor: Color(0xFF35495e),
        onPressed:()async{
          if(qrCodeDescription.text.isNotEmpty && did_record && qrCodeData!="Herhangi bir QR kod okutulmadı!" && outputFile.path != null){
              
              await recordToDatabase();
              if(isRecordedToDatabase){
            
                  Fluttertoast.showToast(
                    msg: "Kayıt içlemi gerçekleşti!",
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.TOP,
                    timeInSecForIos: 1,
                    backgroundColor: Colors.greenAccent,
                    textColor: Colors.white,
                    fontSize: 16.0
                  );

                  recordList.add(RecordClass(id: id,label: qrCodeDescription.text,pathVoice: outputFile.path, qrCodeValue:qrCodeData));
                  Navigator.pushReplacementNamed(context,'/',arguments: {
                      "recordList":recordList,
                  });
              }
              else{
                Fluttertoast.showToast(
                  msg: "Veritabanına kayıt esnasında bir problem yaşandı!",
                  toastLength: Toast.LENGTH_SHORT,
                  gravity: ToastGravity.TOP,
                  timeInSecForIos: 1,
                  backgroundColor: Colors.redAccent,
                  textColor: Colors.white,
                  fontSize: 16.0
                );

              }
            
          }
          else{
            Fluttertoast.showToast(
              msg: "Bilgileri lütfen eksiksiz doldurunuz!",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.TOP,
              timeInSecForIos: 1,
              backgroundColor: Colors.redAccent,
              textColor: Colors.white,
              fontSize: 16.0
            );
          }
        },
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 15,
                ),
                Card(
                  child: Padding(
                    padding: EdgeInsets.all(15),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        Expanded(
                          flex: 1,
                          child: QrImage(
                            data: "$qrCodeData",
                            version: QrVersions.auto,
                            size: 100.0,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Column(
                            children: <Widget>[
                              IconButton(
                                icon: Icon(
                                  Icons.center_focus_strong,
                                  size: 30,
                                ),
                                onPressed: (){
                                  qrCodeReader();
                                },
                              ),
                              Text(
                                "Qr Kod verisi:$qrCodeData",
                              )
                            ],
                          )
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: <Widget>[
                      FlatButton(
                        child: record_icon,
                        onPressed: (){
                          if(record_status){
                            stoping();
                            setState(() {
                              record_status = false;
                              record_icon = Icon(
                                Icons.mic,
                                color: Colors.black,
                              );
                            });
                          }
                          else{
                            recording();
                            setState(() {
                              did_record = true;
                              record_status = true;
                              record_icon = Icon(
                                Icons.stop,
                                color: Colors.red);
                              play_icon = Icon(Icons.play_arrow,color: Colors.green);
                            });
                          }
                        },
                      ),
                      Text(record_seconds
                      ),
                      FlatButton(
                        child: play_icon,
                        onPressed: () async{
                          if(!flutterSound.isRecording && did_record){
                            Directory tempDir = await getApplicationDocumentsDirectory();
                            outputFile =  File ('${tempDir.path}/flutter$id.aac');
                            await flutterSound.startPlayer(outputFile.path);
                          }
                        },
                      )
                    ],
                  ),
                ),
                SizedBox(
                  height: 10,
                ),
                Card(
                  child: Column(
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.all(2.0),
                        child: TextField(
                          controller: qrCodeDescription,
                          autofocus: false,
                          decoration: InputDecoration(
                           border: OutlineInputBorder() ,
                           hintText: "Eklenen QR Kodunun Tanımı",
                          ),
                        ),
                      )
                    ],
                  )
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}


/* 

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


*/