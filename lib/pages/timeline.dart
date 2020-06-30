import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/pages/post_screen.dart';
import 'package:projectapp/pages/search.dart';
import 'package:projectapp/widgets/header.dart';
import 'package:projectapp/widgets/progress.dart';

class Timeline extends StatefulWidget {
  final User currentUser;

  Timeline({this.currentUser});
  @override
  _TimelineState createState() => _TimelineState();
}

class _TimelineState extends State<Timeline> {
  List<Post> posts ;
  List<String> followingLists = [];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getTimeLine();
    getFollowing();
  }

  getTimeLine()async{
    QuerySnapshot snapshot = await timelineRef
        .document(widget.currentUser.id)
        .collection('timelinePosts')
        .orderBy('timestamp',descending: true).getDocuments();
    List<Post>posts = snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();
    setState(() {
      this.posts=posts;
    });

  }
  getFollowing()async{
    QuerySnapshot snapshot = await followingRef
        .document(currentUser.id)
        .collection('userFollowing')
        .getDocuments();
    setState(() {
      followingLists = snapshot.documents.map((doc)=>doc.documentID).toList();
    });
  }

  buildTimeLine(){
    if(posts==null){
      return circularProgress();
    } else if(posts.isEmpty){
      return builduserFollower();
    }
    return Container(child: ListView(children: posts,));
  }

  builduserFollower(){
    return StreamBuilder(
      stream: userRef.orderBy('timestamp',descending: true).limit(30).snapshots(),
      builder: (context , snapshot){
        if(!snapshot .hasData){
          return circularProgress();
        }
        List<UserResult> userResults = [];
        snapshot.data.documents.forEach((doc){
          User user = User.formDocument(doc) ;
          final bool isAuthUser = currentUser.id == user.id;
          final bool isFollowingUser = followingLists.contains(user.id);
          if (isAuthUser){
            return ;
          }else if(isFollowingUser){
            return;
          }else{
            UserResult userResult = UserResult(user);
              userResults.add(userResult);
          }
        });

        return Container(
          color: Theme.of(context).primaryColor.withOpacity(0.3),
          child: Column(
            children: <Widget>[
              Container(
                padding: EdgeInsets.all(11.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.person_add,
                      size: 30.0,
                      color: Theme.of(context).primaryColor,

                    ),
                    SizedBox(width: 10.0,),
                    Text('Users To Follow',
                    style: TextStyle(
                      fontSize: 30.0,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),)
                  ],
                ),
              ),
              Column(
                children: userResults,
              )
            ],
          ),
        );
      },
    );
  }
  @override
  Widget build(context) {
    return Scaffold(
     backgroundColor:   Color(0xFFD6D3D5),
      appBar: header(context , isAppTitle: true),
      body: RefreshIndicator(
        onRefresh: ()=>getTimeLine(),
        child: buildTimeLine(),
      ),
    );
  }
}
