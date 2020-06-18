import 'package:flutter/material.dart';
import 'package:projectapp/widgets/header.dart';

class Routine extends StatefulWidget {
  @override
  _RoutineState createState() => _RoutineState();
}

class _RoutineState extends State<Routine> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Routine"),
      body: Text('routine'),
    );
  }
}
