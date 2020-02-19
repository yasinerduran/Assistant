import 'package:assistant/services/player.dart';
import 'package:assistant/services/record_class.dart';
import 'package:assistant/pages/record.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:path_provider/path_provider.dart';

import 'record_class.dart';

class Player{


  List records_list;
  Player();
  int id;
  FlutterSound flutterSound = new FlutterSound();
  StreamSubscription<RecordStatus>_recorderSubscription;

  FlutterTts flutterTts = FlutterTts();
  Future _speak(String word) async{
    List<dynamic> languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage("tr-TR");
    var result = await flutterTts.speak(word);
  }

  void play(record_list, qrData) async{

    String soundPath;
    bool isFounded = false; 
    for( var i = 0 ; i< record_list.length; i++ ) { 
      if(record_list[i].qrCodeValue == qrData ){
        soundPath = record_list[i].pathVoice;
        isFounded = true;
      }
    } 
    if(isFounded){
      File outputFile =  File (soundPath);
      flutterSound.startPlayer(outputFile.path);
    }
    else{
      Fluttertoast.showToast(
        msg: "Okutulan QR kodu henüz kaydedilmemiş!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 1,
        backgroundColor: Colors.redAccent,
        textColor: Colors.white,
        fontSize: 16.0
      );
    }
    
  }
}

