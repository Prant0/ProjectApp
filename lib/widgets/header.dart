import 'package:flutter/material.dart';

AppBar header(context , {bool isAppTitle = false, String titleText}) {
  return AppBar(
    title: Text(
        isAppTitle ? 'Time Line' : titleText
      ,style: TextStyle(fontSize: 30.0,
    color: Colors.white, fontFamily: 'Acme-Regular'),
    overflow: TextOverflow.ellipsis,),
    centerTitle: true,
    backgroundColor: Colors.teal,
  );
}
