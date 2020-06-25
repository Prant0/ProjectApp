
import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/constants.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/pages/input.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class Extra extends StatefulWidget {
  static const String id = 'extra';
  final String profileId;
  Extra({this.profileId});

  @override
  _ExtraState createState() => _ExtraState();
}

class _ExtraState extends State<Extra> {
  final _scaffoldkey = GlobalKey<ScaffoldState>();
  final messageController = TextEditingController();
  final _firestore = Firestore.instance;
  final _auth = FirebaseAuth.instance.currentUser();
  User user;
  final String currentUserId = currentUser?.id;

  FirebaseUser loggedInUser;
  String messageText;

  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final currentUser = await _auth;
      if (currentUser != null) {
        loggedInUser = currentUser;
      }
    } catch (e) {
      print(e);
    }
  }

  showExitPopUp() {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.grey,
            title: Text('Confirm'),
            content: Text('Do you Want To Exit'),
            actions: <Widget>[
              RaisedButton(
                child: Text('No'),
                color: Colors.redAccent,
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
              RaisedButton(
                child: Text('Yes'),
                color: Colors.lightGreen,
                onPressed: () {
                  SystemNavigator.pop();
                },
              ),
            ],
          );
        });
  }

//

  Future<Null> getRefresh() async {
    await Future.delayed(Duration(seconds: 3));
    setState(() {
      _getPost;
    });
  }

  Widget _getPost(context, snapshots) {
    if (snapshots.connectionState == ConnectionState.waiting) {
      return Center(child: CircularProgressIndicator());
    } else {
      //print('=== data ===: ${snapshots.data.data.documents}');
      return RefreshIndicator(
        onRefresh: getRefresh,
        child: Container(
         // color: Colors.white10,
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView.builder(
              scrollDirection: Axis.vertical,
              itemCount: snapshots.data.documents.length,
              itemBuilder: (context, index) {
                DocumentSnapshot post = snapshots.data.documents[index];
                print('===post ===${post.data}');
                return Stack(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(left: 8.0, right: 8.0),
                      child: Container(
                        decoration: BoxDecoration(

                          borderRadius: BorderRadius.circular(45.0)
                        ),
                        width: MediaQuery.of(context).size.width - 1.0,
                        height: 150.0,
                        child: Container(
                          padding: EdgeInsets.only(top: 8.0, bottom: 8.0),
                          child: Material(

                            borderRadius: BorderRadius.circular(20.0),
                            borderOnForeground: true,
                            color: Colors.white,
                            elevation: 7.0,
                            shadowColor: Color(0x802196F3),
                            child: Center(
                                  child: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(width: 2,color: Colors.blueGrey),
                                      borderRadius: BorderRadius.circular(20.0),
                                              gradient: LinearGradient(
                                                colors: [
                                                  Colors.teal,
                                                  Colors.greenAccent,
                                                  Colors.white30,

                                                ]

                                            ),),
                                                                            padding: EdgeInsets.only(top:10.0,left: 10.0,right: 13.0),
                                child: Column(
                                  //start
                                  children: <Widget>[
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: <Widget>[

                                        Text(
                                          'Course Name :  ${post.data['courseName']}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 20.0,fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15.0,
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: <Widget>[

                                        Text(


                                             'Room No :  ${post.data['roomNo']}',
                                          style: TextStyle(
                                              color: Colors.black,
                                              fontSize: 16.0),
                                        ),

                                        SizedBox(
                                          width: 50.0,
                                        ),

                                        Text(
                                        'Time :${post.data['time']}',
                                          style: TextStyle(
                                            color: Colors.black,
                                            fontSize: 18.0,
                                          ),
                                        ),
                                      ],
                                    ),

                                    Container(

                                      child: IconButton(
                                        onPressed: () async{
                                          ///do_delete_part_here
                                          await Firestore.instance.runTransaction((Transaction myTransaction) async {
                                            await myTransaction.delete(snapshots.data.documents[index].reference);
                                          });

                                        },
                                        icon: Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                          size: 35,
                                        ),
                                        // onPressed: () async {}
                                      ),
                                    ),


                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                  ],
                );
              }),
        ),
      );
    }
  }


  deletePost()async{
    // delete post referance
    postRef
        .document(currentUser.id)
        .collection("routineDetails")
        .document('routine')
        .get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });


  }

  @override
  // ignore: unused_local_variable
  Widget build(BuildContext context) {
    final currentUser = FirebaseAuth.instance.currentUser();

    return WillPopScope(
      // ignore: missing_return
      onWillPop: () {
        showExitPopUp();
      },
      child: MaterialApp(

          debugShowCheckedModeBanner: false,
          home: DefaultTabController(
            length: 7,
            child: Scaffold(
            //  backgroundColor:Theme.of(context).primaryColor,
              appBar: AppBar(
                leading: null,
                  centerTitle: true,
                title: Text('Class Routine',style: TextStyle(fontSize: 27.0),),
                backgroundColor: Colors.teal,
                bottom: TabBar(
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(30),
                    color: Colors.orangeAccent,
                  ),
                  tabs: <Widget>[

                    Tab(
                      text: "Sun",
                    ),
                    Tab(
                      text: "Mon",
                    ),
                    Tab(
                      text: "Tue",
                    ),
                    Tab(
                      text: "Wed",
                    ),
                    Tab(
                      text: "Thu",
                    ),
                    Tab(
                      text: "Fri",
                    ),
                    Tab(
                      text: "Sat",
                    ),
                    // Tab(text: "Thu",),
                  ],
                ),
              ),
              //drawer: Navigation(),
              body: TabBarView(
                children: <Widget>[

                  Container(
                      height: MediaQuery.of(context).size.height * .70,
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * .6,
                          child: StreamBuilder(
                            stream: postsRef
                                .document(widget.profileId)
                                .collection('routineDetails')
                                .document('routine').collection('Sunday')
                                .snapshots(),
                            builder: _getPost,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color:Colors.orange,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                                //saturday
                                child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                    day: "Sunday",
                                  )));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),    //sunday
                  Container(
                      height: MediaQuery.of(context).size.height * .71,
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * .6,
                          child: StreamBuilder(
                            stream: postsRef
                                .document(widget.profileId)
                                .collection('routineDetails')
                                .document('routine').collection('Monday')
                                .snapshots(),
                            builder: _getPost,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color:Colors.orange,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                                //saturday
                                child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                    day: "Monday",
                                  )));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),    //monday
                  Container(
                      height: MediaQuery.of(context).size.height * .71,
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * .6,
                          child: StreamBuilder(
                            stream: postsRef
                                .document(widget.profileId)
                                .collection('routineDetails')
                                .document('routine').collection('Tuesday')
                                .snapshots(),
                            builder: _getPost,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color:Colors.orange,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                                //saturday
                                child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                    day: "Tuesday",
                                  )));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),   //tuesday
                  Container(
                      height: MediaQuery.of(context).size.height * .71,
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * .6,
                          child: StreamBuilder(
                            stream: postsRef
                                .document(widget.profileId)
                                .collection('routineDetails')
                                .document('routine').collection('Wednesday')
                                .snapshots(),
                            builder: _getPost,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color:Colors.orange,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                                //saturday
                                child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                    day: "Wednesday",
                                  )));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),//wednesday
                  Container(
                      height: MediaQuery.of(context).size.height * .71,
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * .6,
                          child: StreamBuilder(
                            stream: postsRef
                                .document(widget.profileId)
                                .collection('routineDetails')
                                .document('routine').collection('Thursday')
                                .snapshots(),
                            builder: _getPost,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color:Colors.orange,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                                //saturday
                                child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                    day: "Thursday",
                                  )));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),//thusday
                  Container(
                      height: MediaQuery.of(context).size.height * .71,
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                          height: MediaQuery.of(context).size.height * .6,
                          child: StreamBuilder(
                            stream: postsRef
                                .document(widget.profileId)
                                .collection('routineDetails')
                                .document('routine').collection('Friday')
                                .snapshots(),
                            builder: _getPost,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(right: 20.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: <Widget>[
                              RaisedButton(
                                color:Colors.orange,
                                elevation: 10.0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(28.0),
                                ),
                                //saturday
                                child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                    day: "Friday",
                                  )));
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    )
                  ),//friday

                  Container(
                    // margin: EdgeInsets.only(bottom: 16.0),
                    decoration: kMessageContainerDecoration,
                    child: Column(
                      children: <Widget>[
                        Container(
                            height: MediaQuery.of(context).size.height * .71,
                            decoration: kMessageContainerDecoration,
                            child: Column(
                              children: <Widget>[
                                Container(
                                  decoration:BoxDecoration(
                                    // color: Colors.black,
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  height: MediaQuery.of(context).size.height * .6,
                                  child: StreamBuilder(
                                    stream: postsRef
                                        .document(widget.profileId)
                                        .collection('routineDetails')
                                        .document('routine').collection('Saturday')
                                        .snapshots(),
                                    builder: _getPost,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(right: 30.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: <Widget>[
                                      RaisedButton(
                                        color:Colors.orange,
                                        elevation: 10.0,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(28.0),
                                        ),
                                        //saturday
                                        child: Text('ADD',style: TextStyle(color: Colors.white,fontWeight: FontWeight.bold),),
                                        onPressed: () {
                                          Navigator.push(context, MaterialPageRoute(builder: (context) => Input(
                                            day: "Saturday",
                                          )));
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                        ),


                      ],
                    ),
                  ),  //sat
                ],
              ),
            ),
          )),
    );
  }
}


