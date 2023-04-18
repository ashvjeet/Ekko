import 'package:ekko/Screens/Login/login.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(
    MaterialApp(
      title: 'Ekko',
      theme: ThemeData(fontFamily: 'Kanit'),
      debugShowCheckedModeBanner: false,
      home: Login(),
    )
  );
}


