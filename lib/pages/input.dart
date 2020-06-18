import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/extra.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/pages/routine.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


final postsRef = Firestore.instance.collection('routineList');


class Input extends StatefulWidget {
  final User currentUserId;
  Input({this.currentUserId,this.day});
 // Input({this.day});
  final String day;
  static const String id = 'input';

  @override
  _InputState createState() => _InputState();
}

class _InputState extends State<Input> {
  final messageController = TextEditingController();
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance;
  FirebaseUser loggedInUser;

  String picked, courseName, roomNo;

  TimeOfDay _timeOfDay;

      getTimee()async{
        TimeOfDay time= await showTimePicker(
          context: context, initialTime: TimeOfDay.now());
        setState(() {
          _timeOfDay=time;
        });
      }
//  String postId = Uuid().v4();

  getCourseName(courseName) {
    this.courseName = courseName;
  }

  getRoomNo(roomNo) {
    this.roomNo = roomNo;
  }

  getTime(time) {
    this.picked = time;
  }

  createData() {
//    DocumentReference ds=Firestore.instance.collection('thusday').document(courseName);
    DocumentReference ds = postsRef
        .document(currentUser.id)
        .collection('routineDetails')
        .document('routine').collection(widget.day).document();
    Map<String, dynamic> routine = {

      "courseName": courseName,
      'roomNo': roomNo,
      "time": picked,
    };
    ds.setData(routine).whenComplete(() {
      print('Routine Added');
      Navigator.pushNamed(context, Extra.id);
    });
  }

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  TimeOfDay _time = TimeOfDay.now();

  Future<Null> selectTime(BuildContext context) async {
    final TimeOfDay picked = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (picked != null && picked == _time) {
      print('Time: ${_time.toString()}');
      setState(() {
        _time = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set Routine'),
      ),
      body: SingleChildScrollView(
        physics: AlwaysScrollableScrollPhysics(),
        child: Container(
          child: Column(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: TextField(
                    onChanged: (String value) {
                      getCourseName(value);
                    },
                    decoration: InputDecoration(
                      // contentPadding:
                      hintText: 'Course Name',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.library_books),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 30.0, right: 30.0, top: 20.0),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: TextField(
                    onChanged: (String value) {
                      getRoomNo(value);
                    },
                    decoration: InputDecoration(
                      // contentPadding:
                      hintText: 'Room No',
                      border: InputBorder.none,
                      prefixIcon: Icon(Icons.library_books),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0, right: 10.0, top: 20.0),
                child: Container(
                  padding: EdgeInsets.all(20.0),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15.0),
                    color: Colors.grey.withOpacity(0.2),
                  ),
                  child: Column(
                    children: <Widget>[
                      Text('Time: ${_time.toString()}'),
                      SizedBox(
                        height: 10.0,
                      ),
                      RaisedButton(
                        child: Text('Select Time'),
                        onPressed: () {
                          selectTime(context);
                          //getTimee();
                        },
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.only(left: 50.0, right: 50.0, top: 30.0),
                child: Container(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      RaisedButton(
                        child: Text('Cancel'),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                      RaisedButton(
                        child: Text('Save'),
                        onPressed: () {
                          createData();
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class Tuesday extends StatelessWidget {
  Tuesday({this.courseName, this.time,this.roomNo});

  final String courseName;
  final String time;
  final String roomNo;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Container(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Material(
              color: Colors.lightBlueAccent,
              borderRadius: BorderRadius.circular(30.0),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                child: Text(
                  '$courseName',
                  style: TextStyle(color: Colors.white, fontSize: 15.0),
                ),
              ),
            ),
            Text(time),
          ],
        ),
      ),
    );
  }
}
