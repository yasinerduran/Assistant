
import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'record.dart';
import 'package:assistant/services/player.dart';
import 'package:assistant/services/record_class.dart';
import 'package:assistant/pages/record.dart';
import 'package:flutter_tts/flutter_tts.dart';

// External Libraries
import 'package:qrscan/qrscan.dart' as scanner;

// Custom Widgets
import 'package:assistant/widgets/warning.dart';


class Listing extends StatefulWidget {
  @override
  _ListingState createState() => _ListingState();
}

class _ListingState extends State<Listing> {

  // User Defined Variables
  List<RecordClass> records;
  Player player = new Player();
  bool first_start = true;
  String last_id;

  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription<RecordStatus>_recorderSubscription;


  List list = [
    Warnings(message: "Herhangi bir QR kodu Bulunamadı,Lütfen QR kod ekleyiniz!")
  ];


  Future<String> qr() async{
    String cameraScanResult = await scanner.scan();
    return cameraScanResult;
  }
  
  FlutterTts flutterTts = FlutterTts();
  Future _speak(String word) async{
    List<dynamic> languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage("tr-TR");
    var result = await flutterTts.speak(word);
}

  void qrCodeReader() async{
    String id =  await qr();
    player.play(records, id);
    //Directory tempDir = await getApplicationDocumentsDirectory();
    //File outputFile =  File ('${tempDir.path}/flutter1.aac');
    //flutterSound.startPlayer(outputFile.path);
   
    _speak(id);
    setState(() {
      last_id = id;
    });
    qrCodeReader();

  }

  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    if(first_start){
      qrCodeReader();
      first_start = false;
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF347474),
      appBar: AppBar(
        title: Center(child:
         Text("Asistant",
         style:  TextStyle(
           color:Colors.white 
         ),),
         
         ),
        backgroundColor: Color(0xFF35495e),//0xFF Önce
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: Color(0xFF35495e),
            child: Icon(
                Icons.add
            ),
            onPressed: (){
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Record()),
              );
            },
          ),
          SizedBox(width: 10,),
          FloatingActionButton(
            heroTag: "btn2",
            backgroundColor: Color(0xFF35495e),
            child: Icon(
                Icons.center_focus_strong
            ),
            onPressed: (){
              qrCodeReader();
            },
          )
        ],
      ),
      body: SafeArea(
          child:  ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index){
                return list[index];
              },
            ),
        )
    );
  }
}


