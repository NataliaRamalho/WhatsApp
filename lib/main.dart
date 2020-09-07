import 'package:flutter/material.dart';
import 'package:whatsapp/telas/RouteGenerator.dart';
import 'Login.dart';

void main() {
  runApp(MaterialApp(
    home: Login(),
    theme: ThemeData(
      primaryColor: Color(0xff075e54),
      accentColor: Color(0xff25D366),
    ),
    initialRoute: "/",
    onGenerateRoute: RouteGenerator.generateRoute,
    debugShowCheckedModeBanner: false,
  ));
}

