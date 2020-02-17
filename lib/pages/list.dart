
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'record.dart';
import 'package:assistant/services/player.dart';
import 'package:assistant/services/record_class.dart';
import 'package:assistant/pages/record.dart';

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

  List warnings = [
    Warnings(
        button_function: (){
        },
        button_icon: Icon(Icons.add),
        message: "Lütfen en az bir adet QR kod ekleyiniz!"),
  ];


  Future<String> qr() async{
    String cameraScanResult = await scanner.scan();
    return cameraScanResult;
  }
  @override

  void qrCodeReader() async{
    String id =  await qr();
    player.play(records, id);
    setState(() {
      last_id = id;
    });
    qrCodeReader();

  }

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
      backgroundColor: Colors.grey[600],
      appBar: AppBar(
        title: Center(child: Text("Asistant")),
        backgroundColor: Colors.grey[900],
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          FloatingActionButton(
            heroTag: "btn1",
            backgroundColor: Colors.deepOrange,
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
            backgroundColor: Colors.grey[900],
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
        child: ListView.builder(
              itemCount: warnings.length,
              itemBuilder: (context, index){
                return warnings[index];
              },
            ),
        )
    );
  }
}


