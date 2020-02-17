import 'package:flutter/material.dart';

// Pages
import 'pages/loading.dart';
import 'pages/list.dart';
import 'pages/record.dart';


void main() => runApp(MaterialApp(
  initialRoute: '/',
  routes: {
    '/': (context) => Listing(), // QR Code Scanner Page
    '/loading': (context) => Loading(), // For CRUD operations
    '/record': (context) => Record() // Add record
  },
));
