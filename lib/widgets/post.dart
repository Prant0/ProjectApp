import 'package:flutter/material.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/widgets/header.dart';
import 'package:projectapp/widgets/progress.dart';
 import 'package:projectapp/pages/post_screen.dart';

class Postt extends StatelessWidget {
  final String postId;
  final String userId;
  Postt({this.postId,this.userId});
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: postRef.document(userId).collection("usersPost").document(postId).get(),
      builder: (context, snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        Post post = Post.fromDocument(snapshot.data);
        return Center(
          child: Scaffold(
            appBar: header(context,titleText: post.caption),
            body: ListView(
              children: <Widget>[
                Container(
                  child: post,
                )
              ],
            ),
          ),
        );
      },
    );
  }
}
