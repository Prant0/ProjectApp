import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/pages/home.dart';
import 'package:timeago/timeago.dart' as timeago;

void main(){
 // FirebaseFirestore firestore = FirebaseFirestore.getInstance();

  Future<void> main() async {
    await Firestore.instance.settings(
      sslEnabled:  true,
      persistenceEnabled: true,
    );
  }


  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.deepPurple,
        accentColor: Colors.teal,

      ),
      home: Home(),
    );
  }
}
