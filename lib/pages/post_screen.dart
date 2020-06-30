import 'dart:ffi';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/Comments.dart';
import 'package:projectapp/pages/activity_feed.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/widgets/post.dart';
import 'package:projectapp/widgets/progress.dart';

class Post extends StatefulWidget {

  final String caption;
  final String ownerId;
  final String username;
  final String details;
  final dynamic likes;
  final String postId;

  Post({
    this.username,
    this.details,
    this.caption,
    this.postId,
    this.likes,
    this.ownerId,

});
  factory Post.fromDocument(DocumentSnapshot doc){
    return Post(
      postId: doc ['postId'],
      ownerId: doc ['ownerId'],
      username: doc ['username'],
      caption: doc ['caption'],
      details: doc ['details'],
      likes: doc ['likes'],
    );
  }


    int getLikeCount(likes){
    if(likes==0){
      return 0;
    }
    int count =0;
    likes.values.forEach((val){
        if(val == true){
          count +=1;
        }
    });
    return count;
    }


  @override
  _PostState createState() => _PostState(
    postId: this.postId,
    ownerId: this.ownerId,
    username: this.username,
    details: this.details,
    caption: this.caption,
    likes: this.likes,
    likesCount: getLikeCount(this.likes),
  );
}

class _PostState extends State<Post> {
  final String currentUserId= currentUser?.id;
  final String caption;
  final String ownerId;
  final String username;
  final String details;
  final String postId;
  int likesCount;
  Map likes;
  bool isLiked ;

  _PostState({
    this.username,
    this.details,
    this.caption,
    this.postId,
    this.likes,
    this.ownerId,
    this.likesCount,
  });

  buildPostHeader(){
    return FutureBuilder(
      future: userRef.document(ownerId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user=User.formDocument(snapshot.data);

        bool ispostOwner = currentUserId == ownerId;
        return Container(
              margin: EdgeInsets.only(top: 10.0,right: 10.0, left: 10.0),
          padding: EdgeInsets.symmetric(vertical: 5.0),
          decoration: BoxDecoration(
            color: Colors.teal,
            border: Border.all(width: 1.0,color: Colors.black54),
            borderRadius: BorderRadius.circular(5.0)
          ),
          child: ListTile(

            leading: CircleAvatar(
              radius: 30.0,
              backgroundColor: Colors.grey,
              backgroundImage: CachedNetworkImageProvider(user.photoUrl),
            ),
            title: GestureDetector(
              onTap: ()=>showProfile(context,profileId: user.id),
              child: Text(user.username,style: TextStyle(
                fontWeight: FontWeight.w700,color: Colors.black,fontSize: 21.0
              ),),
            ),
            trailing:ispostOwner ? IconButton(
              onPressed: ()=> handleDeletePost(context),
              icon: Icon(Icons.more_horiz),
            ):Text(''),
          ),
        );
      },

    );
  }
  handleDeletePost(BuildContext parentContext){
    return showDialog(
      context: parentContext,
      builder: (context){
        return SimpleDialog(
          title: Text('Remove this Post'),
          children: <Widget>[
            SimpleDialogOption(
              child: Text('Delete'),
              onPressed: (){
                Navigator.pop(context);
              deletePost();
              },
            ),

            SimpleDialogOption(
              child: Text('Cancle'),
              onPressed: ()=>Navigator.pop(context),
            )
          ],
        );
      }
    );
  }
  
  deletePost()async{
    // delete post referance
    postRef
        .document(ownerId)
        .collection('usersPosts')
        .document(postId)
        .get().then((doc){
       if(doc.exists){
         doc.reference.delete();
       }
    });

    //delete Activity Feed notification
    QuerySnapshot activityFeedSnapshot = await activityFeedRef
    .document(ownerId)
    .collection("feedItems")
    .where('postId',isEqualTo: postId)
        .getDocuments();
    activityFeedSnapshot.documents.forEach((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });

    //delete all coments

    QuerySnapshot commentsFeedSnapshot = await commentRef
        .document(postId)
        .collection("feedItems")
        .getDocuments();
    commentsFeedSnapshot.documents.forEach((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });


  }

  buildPostFooter(){
    return Container(
      decoration: BoxDecoration(
        //border: Border.all(color: Colors.blueGrey,width: 1.0),


      ),
      margin: EdgeInsets.symmetric(horizontal: 14.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[

          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Container(
                margin: EdgeInsets.only(top: 15.0,bottom: 20.0),
                child: Text(caption,style: TextStyle(fontSize:26.0 ,color: Colors.black87,fontWeight: FontWeight.w500),),
              ),
              //Expanded(child: Text(caption)),
            ],
          ),



          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[

              Expanded(child: Text(details,style: TextStyle(fontWeight: FontWeight.w400),)),
            ],
          ),

          Row(
            children: <Widget>[
              Padding(
                padding: EdgeInsets.only(top:  60.0, left: 20.0),
              ),
              GestureDetector(
                onTap: handleLikePost,
                child: isLiked? Icon(Icons.favorite,color: Colors.red,size: 30,) : Icon(Icons.favorite_border,color: Colors.red,),
              ),
              Padding(
                padding: EdgeInsets.only( right: 21.0),
              ),
              GestureDetector(
                onTap: () =>showComments(
                  context,
                  postId:postId,
                  ownerId:ownerId,
                  caption:caption,
                ),
                child: Icon(Icons.chat_bubble,color: Colors.blue,),
              ),


              Divider(height: 2.0, color: Colors.red,thickness: 5,)
            ],
          ),


          Container(

            margin: EdgeInsets.only(bottom: 5.0),
            child: Text("$likesCount likes ",style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),),
          ),



        ],
      ),
    );
  }

  handleLikePost()
  {
    bool _isLiked = likes[currentUserId]==true;
    if(_isLiked){
      postRef
            .document(ownerId)
            .collection('usersPosts')
          .document(postId)
          .updateData({"likes.$currentUserId":false});
      removeactivityToLikeFeed();
        setState(() {
          likesCount -=1;
          isLiked = false;
          likes[currentUserId]=false;
        });
    } else if(!_isLiked){
      postRef
          .document(ownerId)
          .collection('usersPosts')
          .document(postId)
          .updateData({"likes.$currentUserId":true});
      activityToLikeFeed();
      setState(() {
        likesCount +=1;
        isLiked = true;
        likes[currentUserId]=true;
      });
    }

  }


  activityToLikeFeed(){
    bool isNotpostOwner = currentUserId !=ownerId;
    if(isNotpostOwner){
      activityFeedRef.
      document(ownerId)
          .collection('feedItems')
          .document(postId)
          .setData({
        'type':'like',
        'userId':currentUser.id,
        'username':currentUser.username,
        'caption':caption,
        'userProfileImg':currentUser.photoUrl,
        "timestamp":timestamp,
        'postId':postId,
      });
    }


  }

  removeactivityToLikeFeed(){
    bool isNotpostOwner = currentUserId !=ownerId;
    if(isNotpostOwner){
      activityFeedRef.
      document(ownerId)
          .collection('feedItems')
          .document(postId)
          .get().then((doc){
        if(doc.exists){
          doc.reference.delete();
        }
      });
    }

  }
  @override
  Widget build(BuildContext context) {
    isLiked = (likes[currentUserId]==true);
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.0,vertical: 11.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [

            Color(0xff86A8AC),
            Color(0xffA5F0F7),
          ],
        ),
        borderRadius: BorderRadius.circular(10.0),
        border: Border.all(color: Colors.black,width: 1,style: BorderStyle.solid),
      ),
      child: Column(
        children: <Widget>[
          buildPostHeader(),
           //buildPostImage(),
          buildPostFooter(),

        ],
      ),

    );

  }
}
showComments(BuildContext context,
    {String postId, String ownerId, String mediaUrl,String caption}) {
  Navigator.push(context, MaterialPageRoute(builder: (context) {
    return Comments(
      postId: postId,
      postOwnerId: ownerId,
      caption:caption,
     // postMediaUrl: mediaUrl,
    );
  }));
}
