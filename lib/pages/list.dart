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
import 'package:permission_handler/permission_handler.dart';

class Listing extends StatefulWidget {
  @override
  _ListingState createState() => _ListingState();
}

List<RecordClass> recordList = [];
bool first_start = true;
bool create_phase = false;

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
  Future<bool> getDataBase() async {
    var status_is_first_start = false;
    var databasesPath = await getDatabasesPath();
    var path = databasesPath + 'application.db';
    Database database = await openDatabase(path, version: 1,
        onCreate: (Database db, int version) async {
      // When creating the db, create the table
      status_is_first_start = true;
      create_phase = true;

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
    return status_is_first_start;
  }

  void removeRecordOnDatabase(id) async {
    var databasesPath = await getDatabasesPath();
    var path = databasesPath + 'application.db';
    Database database = await openDatabase(path, version: 1);
    var count =
        await database.rawDelete('DELETE FROM Records WHERE id = ?', [id]);
  }

  void dn(perm) async {
    print("İzinlerin Durumu $perm");
    if (perm == PermissionStatus.granted) {
      String id = await scanner.scan();
      setState(() {
        last_id = id;
      });
      Player player = new Player();
      player.play(recordList, id);
      qrCodeReader();
    } else {
      Fluttertoast.showToast(
        msg: "Gerekli izinler bulunamadı!",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIos: 5,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
    setState(() {});
  }

  Future _izinleriAl() async {
    await PermissionHandler().requestPermissions([
      PermissionGroup.camera,
      PermissionGroup.photos,
      PermissionGroup.storage,
      PermissionGroup.microphone,
    ]);
  }

  Future oncesiIslemler() async {
    await _izinleriAl();
  }

  Future qrCodeReader() async {
    await oncesiIslemler();
    await dn(await PermissionHandler()
        .checkPermissionStatus(PermissionGroup.camera));
  }

  int countRecordList = 0;

  @override
  void initState() {
    WidgetsBinding.instance
        .addPostFrameCallback((duration) => print(duration.toString()));
    super.initState();
    if (first_start) {
      getDataBase();
      recordList = [];
      qrCodeReader();
    }
    first_start = false;
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
              "Engelsiz Alan",
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
