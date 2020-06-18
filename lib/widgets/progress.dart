import 'package:flutter/material.dart';

 Container circularProgress() {
  return Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 10.0),
    child: CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
    ),
  );
}

Container linearProgress() {
  return Container(
    alignment: Alignment.topCenter,
    padding: EdgeInsets.only(top: 10.0),
    child: LinearProgressIndicator(
      valueColor: AlwaysStoppedAnimation(Colors.deepPurple),
    ),
  );
}
