import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/edit_profile.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/pages/post_screen.dart';
import 'package:projectapp/widgets/header.dart';
import 'package:projectapp/widgets/progress.dart';



class Profile extends StatefulWidget {

  final String profileId;
  Profile({this.profileId});
  @override
  _ProfileState createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  bool isFollowing = false;
  final String currentUserId = currentUser?.id;
  bool isLoading = false;
  int postCount = 0;
  int followersCount=0;
  int followingCount=0;
  List <Post> posts = [];

    @override
    void initState(){
      super.initState();
      getProfilePost( );
      getFollowers();
      getFollowing();
      checkIfFollow();
    }
  checkIfFollow()async{
      DocumentSnapshot doc = await followers
          .document(widget.profileId)
          .collection('userFollower')
          .document(currentUserId).get();
      setState(() {
        isFollowing = doc.exists;
      });
  }

  getFollowers()async{
      QuerySnapshot snapshot = await followers
          .document(widget.profileId)
          .collection("userFollower").getDocuments();
      setState(() {
      followersCount = snapshot.documents.length;
      });
  }

  getFollowing()async{
    QuerySnapshot snapshot = await followingRef
        .document(widget.profileId)
        .collection("userFollowing").getDocuments();
    setState(() {
      followingCount = snapshot.documents.length;
    });
  }

  getProfilePost() async{
      setState(() {
        isLoading=true;
      });
      QuerySnapshot snapshot = await postRef.
      document(widget.profileId)
      .collection('usersPosts')
      .orderBy('timestamp',descending: true)
      .getDocuments();
      setState(() {
        isLoading=false;
        postCount=snapshot.documents.length;       //post count korbe
        posts=snapshot.documents.map((doc)=>Post.fromDocument(doc)).toList();

      });
  }

  Column buildPostColumn(String label , int count){
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
      count.toString(),
          style: TextStyle(fontSize: 22.0,fontWeight: FontWeight.bold,),
    ),
        Container(
          margin: EdgeInsets.only(top: 6.0),
          child: Text(
            label,style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

 Container buildButton({String text, Function function}){
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 3.0,vertical: 5.0),
      child: FlatButton(
        onPressed: function,
        child: Container(
          width: 200.0,
          height: 35.0,
          child: Text(text,style: TextStyle(
            fontSize: 17.0,fontWeight: FontWeight.w700,color:isFollowing?Colors.black: Colors.white
          ),),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color:isFollowing?Colors.white: Colors.orangeAccent,
            border: Border.all(color:isFollowing?Colors.grey: Colors.deepOrange),
            borderRadius: BorderRadius.circular(10.0),
          ),
        ),
      ),
    );
  }
  editProfile(){
Navigator.push(context, MaterialPageRoute(builder: (context)=>EditProfile(currentUserId:currentUserId)));
  }

  buildProfileButton(){
   bool isProfileOwner = currentUserId == widget.profileId;
   if( isProfileOwner){
     return buildButton(
       text: 'Edit Profile',
       function: editProfile,
     );
   }
      else if(isFollowing){
        return buildButton(text:'Unfollow',function: handleUnfollowUser);
   } else if(!isFollowing){
        return buildButton(text:"follow",function: handleFollowUser);
   }
  }
  handleUnfollowUser(){
    setState(() {
      isFollowing=false;
    });
    followers.document(widget.profileId)
        .collection("userFollower")
        .document(currentUserId)
        .get().then((doc){
          if(doc.exists){
            doc.reference.delete();
          }
        });
    followingRef.document(currentUserId)
        .collection("userFollowing")
        .document(widget.profileId)
        .get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });


    activityFeedRef
        .document(widget.profileId)
        .collection("feedItems")
        .document(currentUserId)
        .get().then((doc){
      if(doc.exists){
        doc.reference.delete();
      }
    });
  }
  handleFollowUser(){
            setState(() {
            isFollowing=true;
            });
            followers.document(widget.profileId)
            .collection("userFollower")
            .document(currentUserId)
            .setData({});
            followingRef.document(currentUserId)
            .collection("userFollowing")
            .document(widget.profileId)
            .setData({});
            activityFeedRef
            .document(widget.profileId)
            .collection("feedItems")
            .document(currentUserId)
            .setData({
            "type":"follow",
            "ownerId":widget.profileId,
            "username": currentUser.username,
              'userId':currentUserId,
            'userProfileImg':currentUser.photoUrl,
            'timestamp':timestamp,
            });
  }

  buildProfileHeader(){
    return FutureBuilder(
      future: userRef.document(widget.profileId).get(),
      builder: (context,snapshot){
        if(!snapshot.hasData){
          return circularProgress();
        }
        User user = User.formDocument(snapshot.data);
        return Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            children: <Widget>[
              Row(
                children: <Widget>[
                  CircleAvatar(
                    radius: 52.0,
                    backgroundColor: Colors.grey,
                    backgroundImage: CachedNetworkImageProvider(user.photoUrl),
                  ),
                  Expanded(
                    flex: 1,
                    child: Column(
                      children: <Widget>[
                        Row(
                          mainAxisSize: MainAxisSize.max,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: <Widget>[
                            buildPostColumn('posts',postCount),
                            buildPostColumn('Followers',followersCount),
                            buildPostColumn('Following',followingCount),
                          ],
                        ),
                        Container(
                          child: buildProfileButton(),
                        ),


                      ],
                    ),
                  )
                ],
              ),
              
              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(user.username !=null? user.username.toString():'null',
                  style: TextStyle(color: Colors.deepOrangeAccent,fontSize: 30.0,fontWeight: FontWeight.w500),),
              ),

              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(user.displayName !=null? user.displayName.toString():'null',
                  style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.bold),),
              ),

              Container(
                alignment: Alignment.centerLeft,
                padding: EdgeInsets.only(top: 12.0),
                child: Text(user.bio !=null? user.bio.toString():'null',
                  style: TextStyle(fontSize: 18.0,fontWeight: FontWeight.w400),),
              ),
            ],
          ),
        );
      },
    );
  }
  buildProfilePost(){
    if(isLoading){
      circularProgress();
    }
    return Column(
      children: posts,
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: header(context, titleText: "Profile"),
      body: ListView(
        children: <Widget>[
          buildProfileHeader(),
          Divider(height: 0.5,),

          buildProfilePost(),
        ],
      ),
    );
  }
}
