import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/widgets/header.dart';
import 'package:projectapp/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;
class Comments extends StatefulWidget {

    final String caption;
  final String postId;
  final String postOwnerId;
  Comments({
    this.caption,
    this.postId,
    this.postOwnerId
  });
  @override
  _CommentsState createState() => _CommentsState(
    postId: this.postId, postOwnerId: this.postOwnerId,caption :this.caption
  );
}

class _CommentsState extends State<Comments> {

  TextEditingController commentsController = TextEditingController();
  final String postId;
  final String postOwnerId;
  final String caption;
  _CommentsState({
    this.postId,
    this.caption,
    this.postOwnerId
  });

  buildComments(){
    return StreamBuilder(
      stream: commentRef
          .document(postId)
          .collection('comments')
          .orderBy('timeStamp',descending: true).snapshots(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        List<Comment>comments=[];
        snapshot.data.documents.forEach((doc){
          comments.add(Comment.fromDocument(doc));
        });
        return ListView(
          children: comments,
        );
      }
    );
  }

  addComments(){
    commentRef
        .document(postId)
        .collection('comments')
        .add({
      'userId':currentUser.id,
      'username':currentUser.username,
      'comment':commentsController.text,
      'avatarUrl':currentUser.photoUrl,
      'timeStamp':timestamp,
      'caption':caption,
    });

    bool isNotOwnerPost = postOwnerId != currentUser.id;
    if(isNotOwnerPost){
      activityFeedRef.document(postOwnerId).collection("feedItems").add({
        'type':'comment',
        "commentdata":commentsController.text,
        'userId':currentUser.id,
        'username':currentUser.username,
        'caption':caption,
        'userProfileImg':currentUser.photoUrl,
        "timestamp":timestamp,          //comment jabe na , jode owner psot kore
        'postId':postId,
      });
    }




    commentsController.clear();
  }
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: header(context,titleText: 'Comments,'),
      body: Column(
        children: <Widget>[
          Expanded(
            child: buildComments(),
          ),

          Divider(),
          ListTile(
            title: TextFormField(
              controller: commentsController,
              decoration: InputDecoration(
                labelText: 'Write Comments here'
              ),
            ),
            trailing: OutlineButton(
              onPressed: addComments,
              borderSide: BorderSide.none,
              child: Text('Post'),
            ),
          ),
        ],
      ),
    );
  }
}


class Comment extends StatelessWidget {
    final String userId;
    final String username;
    final String comment;
    final String avatarUrl;
    final String caption;
    final Timestamp timestamp;

    Comment({
   this.userId,this.username,this.comment,this.timestamp,this.avatarUrl,this.caption
});
    factory Comment.fromDocument(DocumentSnapshot doc){
      return Comment(
        userId: doc ['userId'],
        username: doc ['username'],
        comment: doc ['comment'],
        avatarUrl: doc ['avatarUrl'],
        timestamp: doc ['timestamp'],

      );
    }

  @override
  Widget build(BuildContext context) {

    return Column(
      children: <Widget>[
        ListTile(
          title: Text(comment),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(avatarUrl),
          ),
         // subtitle: Text(timeago.format(timestamp.toDate())),
        )
      ],
    );
  }
}
