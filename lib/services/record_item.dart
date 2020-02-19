import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:assistant/services/record_class.dart';

class RecordItem extends StatefulWidget {
  final RecordClass record;
  final List<RecordClass> recordList;
  final ValueChanged<int> silinecekItem;
  RecordItem({
    @required this.record,
    @required this.recordList,
    @required this.silinecekItem,
  });

  @override
  _RecordItemState createState() => _RecordItemState();
}

class _RecordItemState extends State<RecordItem> {
  List<RecordClass> _recordList = List();
  RecordClass _record;
  @override
  void initState() {
    _recordList = widget.recordList;
    _record = widget.record;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: const EdgeInsets.all(8.0),
        child: Card(
          child: Row(
            children: <Widget>[
              Expanded(
                flex: 8,
                child: Row(
                  children: <Widget>[
                    Expanded(
                      flex: 1,
                      child: QrImage(
                        data: "${widget.record.qrCodeValue}",
                        version: QrVersions.auto,
                        size: 60.0,
                      ),
                    ),
                    Expanded(
                      flex: 1,
                      child: IconButton(
                        icon: Icon(Icons.play_arrow),
                        onPressed: () async {
                          FlutterSound flutterSound = new FlutterSound();
                          await flutterSound
                              .startPlayer(widget.record.pathVoice);
                        },
                      ),
                    ),
                    Expanded(
                      flex: 3,
                      child: Text(
                        "${widget.record.label}",
                        overflow: TextOverflow.ellipsis,
                      ),
                    )
                  ],
                ),
              ),
              Expanded(
                flex: 1,
                child: IconButton(
                  icon: Icon(Icons.delete),
                  onPressed: () {
                    widget.silinecekItem(_record.id);
                  },
                ),
              ),
            ],
          ),
        ));
  }
}
