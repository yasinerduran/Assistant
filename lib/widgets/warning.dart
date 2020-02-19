import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:assistant/services/player.dart';

class Warnings extends StatelessWidget {
  String message;
  Icon button_icon;
  Function button_function;
  Warnings({this.message});
  Warnings wrn;
  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0),
      ),
      margin: EdgeInsets.fromLTRB(12, 16, 12, 1),
      child: Center(
        child: ListTile(
          leading: Icon(
            Icons.warning,
            color: Colors.orange,
          ),
          title: Text(message),
        ),
      ),
    );
  }
}
