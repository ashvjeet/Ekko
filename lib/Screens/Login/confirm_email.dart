import 'package:flutter/material.dart';

class ConfirmEmail extends StatefulWidget {
  const ConfirmEmail({super.key});

  @override
  State<ConfirmEmail> createState() => _ConfirmEmailState();
}

class _ConfirmEmailState extends State<ConfirmEmail> {
  
  @override
  Widget build(BuildContext context) {
    Size deviceSize = MediaQuery.of(context).size;
    return Scaffold(
      body: Container(
        height: deviceSize.height,
        width: deviceSize.width,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [ 
              Colors.white60,
              Colors.teal.shade100,
              ], 
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ), 
        ), 
      ),
    );
  }
}