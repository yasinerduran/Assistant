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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: <Widget>[
                  Expanded(
                    flex: 1,
                    child: Icon(
                      Icons.warning,
                    ) ,
                  ),
                  Expanded(
                    flex: 5,
                    child:Text(
                      "$message",
                      style:TextStyle(
                          fontWeight: FontWeight.bold
                      ) ,
                    ),
                  ),
                ],
              )
          )
        ],
      ),
    );
  }
}