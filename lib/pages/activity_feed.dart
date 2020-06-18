//import 'dart:html';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/pages/post_screen.dart';
import 'package:projectapp/pages/profile.dart';
import 'package:projectapp/widgets/header.dart';
import 'package:projectapp/widgets/post.dart';
import 'package:projectapp/widgets/progress.dart';
import 'package:timeago/timeago.dart' as timeago;


class ActivityFeed extends StatefulWidget {
  @override
  _ActivityFeedState createState() => _ActivityFeedState();
}

class _ActivityFeedState extends State<ActivityFeed> {

  getActivityFeed()async{
    QuerySnapshot snapshot = await activityFeedRef
        .document(currentUser.id)
        .collection('feedItems')
        .orderBy('timestamp',descending: true)
        .limit(50)
        .getDocuments();
    List <ActivityFeedItem> feedItems = [];
    snapshot.documents.forEach((doc){
      feedItems.add(ActivityFeedItem.fromDocument(doc));
    });
    return feedItems;
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.orangeAccent,
      appBar: header(context, titleText: "ActivityFeed"),
      body: Container(
        padding: EdgeInsets.only(top: 5.0),
        child: FutureBuilder(
          future: getActivityFeed(),
          builder: (context,snapshot){
            if(!snapshot .hasData){
              return circularProgress();
            }
            return ListView(
              children: snapshot.data,
            );
          },
        ),
      ),
    );
  }
}

 Widget mediaPreview;
String activityItemText;
class ActivityFeedItem extends StatelessWidget {
  final String userId;
  final String username;
  final String type;
  final String userProfileImg;
  final String caption;
  final String postId;
  final String commentData;
  final Timestamp timestamp;
  ActivityFeedItem({
    this.userId,this.username,this.type,
    this.userProfileImg,this.caption,
    this.postId,this.commentData,
    this.timestamp,
});
factory ActivityFeedItem.fromDocument(DocumentSnapshot doc){
  return ActivityFeedItem(
    userId: doc ['userId'],
    username: doc['username'],
    type: doc['type'],
    userProfileImg: doc['userProfileImg'],
    caption: doc['caption'],
    postId: doc['postId'],
    commentData: doc['commentdata'],
    timestamp: doc['timestamp'],
  );
}

showPost(context){
  Navigator.push(context, MaterialPageRoute
    (builder: (context)=>Postt(postId:postId, userId:  userId,)));
}

  configureMediaPreview(context) {
    if (type == "like" || type == 'comment') {
      mediaPreview = GestureDetector(
        onTap: () => showPost(context),
        child: Container(
          height: 50.0,
          width: 50.0,
          child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                child: Text('$caption'),
              )),
        ),
      );
    } else {
      mediaPreview = Text('');
    }

    if (type == 'like') {
      activityItemText = "is liked your post";
    } else if (type == 'follow') {
      activityItemText = "is following you  ";
    } else if (type == 'comment') {
      activityItemText = "replyed  ' $commentData '";
    } else {
      activityItemText = "Error: Unknown  '$type'";
    }
  }


  @override
  Widget build(BuildContext context) {
  configureMediaPreview(context);

    return Padding(
      padding: EdgeInsets.only(bottom: 5.0),
      child: Container(
        color: Colors.white70,
        child: ListTile(
          title: GestureDetector(
            onTap: ()=>showProfile(context,profileId: userId),
            child: RichText(
              overflow: TextOverflow.ellipsis,
              text: TextSpan(
                style: TextStyle(
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
                children: [
                  TextSpan(
                    text: username,
                  style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.bold),),
                  TextSpan(
                    text: ' $activityItemText',style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w400,)
                          ),
                ],
              ),
            ),
          ),
          leading: CircleAvatar(
            backgroundImage: CachedNetworkImageProvider(userProfileImg),
          ),
          //subtitle: Text(timeago.format(timeStamp.toDate()),
         // overflow: TextOverflow.ellipsis,),
          trailing: mediaPreview,

        // onTap: ()=>showPost(context),
         // subtitle: Text( "$mediaPreview" != null? caption.toString():'xp',
           // style: TextStyle(fontSize: 20.0,fontWeight: FontWeight.w600,),),
        ),
      ),
    );
  }
}

showProfile(BuildContext context,{String profileId}){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Profile(profileId: profileId)));
}
