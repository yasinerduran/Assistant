import 'dart:async';
import 'package:assistant/pages/record.dart';
import 'package:assistant/services/record_class.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:assistant/services/player.dart';
import 'package:flutter_tts/flutter_tts.dart';

// External Libraries
import 'package:qrscan/qrscan.dart' as scanner;

// Custom Widgets
import 'package:assistant/widgets/warning.dart';
import 'package:assistant/services/record_item.dart';
import 'package:sqflite/sqflite.dart';

class Listing extends StatefulWidget {
  @override
  _ListingState createState() => _ListingState();
}

List<RecordClass> recordList = [];
bool first_start = true;

class _ListingState extends State<Listing> {
  // User Defined Variables
  Player player = new Player();

  String last_id;

  FlutterSound flutterSound = new FlutterSound();

  List list = [
    Warnings(
        message: "Herhangi bir QR kodu Bulunamadı,Lütfen QR kod ekleyiniz!")
  ];

  FlutterTts flutterTts = FlutterTts();
  Future _speak(String word) async {
    List<dynamic> languages = await flutterTts.getLanguages;
    await flutterTts.setLanguage("tr-TR");
    var result = await flutterTts.speak(word);
  }

  // Data Base Operations
  void getDataBase() async {
    var databasesPath = await getDatabasesPath();
    var path = databasesPath + 'application.db';
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      await db.execute(
          'CREATE TABLE Records (id INTEGER PRIMARY KEY, label TEXT, qrdata TEXT, pathvoice TEXT)');
    });
    print("!! DataBase Created!!");
    List<Map> list = await database.rawQuery('SELECT * FROM Records');
    for (int i = 0; i < list.length; i++) {
      RecordClass rc = new RecordClass(
          id: list[i]["id"],
          label: list[i]["label"],
          qrCodeValue: list[i]["qrdata"],
          pathVoice: list[i]["pathvoice"]);
      recordList.add(rc);
    }
    if (recordList.length == 0) {
      Fluttertoast.showToast(
        msg: "Hiç kayıt bulunamadı!, Lütfen QR kod ekleyin!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: Colors.orangeAccent,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {});
  }

  void removeRecordOnDatabase(id) async {
    var databasesPath = await getDatabasesPath();
    var path = databasesPath + 'application.db';
    Database database = await openDatabase(path, version: 1);
    var count =
        await database.rawDelete('DELETE FROM Records WHERE id = ?', [id]);
  }

  Future qrCodeReader() async {
    String id = await scanner.scan();
    setState(() {
      last_id = id;
    });
    Player player = new Player();
    player.play(recordList, id);
    qrCodeReader();
  }

  int countRecordList = 0;
  @override
  void initState() {
    super.initState();
    recordList = [];
    if (first_start) {
      getDataBase();
      qrCodeReader();
      first_start = false;
    }
  }

  Map data = {};
  @override
  Widget build(BuildContext context) {
    data = ModalRoute.of(context).settings.arguments;
    try {
      recordList = data['recordList'];
    } catch (error) {}

    return Scaffold(
        backgroundColor: Color(0xFF347474),
        appBar: AppBar(
          title: Center(
            child: Text(
              "Asistant",
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: Color(0xFF35495e), //0xFF Önce
        ),
        floatingActionButton: Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            FloatingActionButton(
              heroTag: "btn1",
              backgroundColor: Color(0xFF35495e),
              child: Icon(Icons.add),
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/record',
                    arguments: {"recordList": recordList});
              },
            ),
            SizedBox(
              width: 10,
            ),
            FloatingActionButton(
              heroTag: "btn2",
              backgroundColor: Color(0xFF35495e),
              child: Icon(Icons.center_focus_strong),
              onPressed: () {
                qrCodeReader();
              },
            )
          ],
        ),
        body: SafeArea(
          child: recordList.isNotEmpty
              ? ListView.builder(
                  itemCount: recordList.length,
                  itemBuilder: (context, index) {
                    return RecordItem(
                      record: recordList[index],
                      recordList: recordList,
                      silinecekItem: (silinecekItemId) {
                        recordList
                            .removeWhere((item) => item.id == silinecekItemId);
                        removeRecordOnDatabase(silinecekItemId);

                        setState(() {});
                      },
                    );
                  },
                )
              : SizedBox(
                  height: MediaQuery.of(context).size.height * 0.2,
                  child: Warnings(
                    message: "Hiç kayıt bulunamadı!, Lütfen QR kod ekleyin!",
                  ),
                ),
        ));
  }
}

/*
ListView.builder(
              itemCount: list.length,
              itemBuilder: (context, index){
                return list[index];
              },
            ),
*/
