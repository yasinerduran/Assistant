
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Pages
import 'pages/loading.dart';
import 'pages/list.dart';
import 'pages/record.dart';
import 'package:permission_handler/permission_handler.dart';

_izinleriAl() async {
  await PermissionHandler().requestPermissions([
    PermissionGroup.camera,
    PermissionGroup.photos,
    PermissionGroup.storage,
    PermissionGroup.microphone,
  ]);
}

Future oncesiIslemler() async {
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await _izinleriAl();
}

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  oncesiIslemler().then((_) async {
    runApp(MaterialApp(
      initialRoute: '/',
      routes: {
        '/': (context) => Listing(), // QR Code Scanner Page
        '/loading': (context) => Loading(), // For CRUD operations
        '/record': (context) => Record() // Add record
      },
    ));
  });
}
