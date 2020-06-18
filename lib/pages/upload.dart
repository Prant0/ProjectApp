import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/home.dart';
import 'package:projectapp/widgets/header.dart';
import 'package:projectapp/widgets/progress.dart';
import 'package:uuid/uuid.dart';

class Upload extends StatefulWidget {
  final User currentUser;
  Upload({this.currentUser});
  @override
  _UploadState createState() => _UploadState();
}

class _UploadState extends State<Upload> {
  final _scaffold =GlobalKey<ScaffoldState>();
  bool isUploading = false;
  String postId = Uuid().v4();
  TextEditingController captionController = TextEditingController();
  TextEditingController detailsController = TextEditingController();

  createPostInFireStore({String caption , String details }){
    postRef.document(widget.currentUser.id)
        .collection("usersPosts")
        .document(postId)
        .setData({
      'ownerId':widget.currentUser.id,
      'username':widget.currentUser.username,
      'postId':postId,
      'caption':caption,
      'details':details,
      'timestamp':timestamp,
      'likes':{},
    });



    SnackBar snackBar = SnackBar(content: Text('Your Post Successful '),);
    _scaffold.currentState.showSnackBar(snackBar);
    Timer(Duration(seconds: 2),(){
                                                //  Navigator use kora lagbe.,.,  onno page er jonno.,
    });

  }

  handleSubmit() async {
    setState(() {
      isUploading=true;
    });

    createPostInFireStore(
      caption:captionController.text,
      details: detailsController.text,
    );
    captionController.clear();
    detailsController.clear();
    setState(() {
      isUploading=false;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key :_scaffold,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        leading: IconButton(
          icon: Icon(Icons.arrow_back,color: Colors.blueGrey,size: 30.0,),
        ),
        title: Text('Upload Your  Post',style: TextStyle(
          color: Colors.white,fontSize: 30.0,fontFamily: "Acme-Regular"
        ),),
      ),
      body: ListView(
        children: <Widget>[
          isUploading ? linearProgress() : Text (''),
          Padding(padding: EdgeInsets.only(top: 20.0)),
          ListTile(
            leading: CircleAvatar(
              radius: 30.0,
              backgroundImage: CachedNetworkImageProvider(widget.currentUser.photoUrl),
            ),
            title: Container(
              //height: 70.0,
              //color: Colors.black,
              child: TextField(
                controller: captionController,
                decoration: InputDecoration(
                  hintText: "Write Post Caption",
                  border: InputBorder.none,
                  filled: true,
                ),
              ),
            ),
          ),

          Divider(),

          Container(
            height: 200.0,

            margin:EdgeInsets.only(left: 50.0,top: 50.0,right: 20.0),
            child: TextField(
              controller: detailsController,
              maxLengthEnforced: true,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.edit),
                hintText: "Add Description",
                border: InputBorder.none,
               // border: OutlineInputBorder(borderRadius: BorderRadius.circular(10.0),gapPadding: 20.0)
              ),
            ),
            decoration: BoxDecoration(
              //color: Colors.red,
              border: Border.all(color: Colors.black,width: 1)
            ),
          ),

          Container(
            height: 40.0,
            width: 100.0,
            margin: EdgeInsets.only(top: 30.0),
            padding: const EdgeInsets.symmetric(horizontal:100.0),

            child: RaisedButton(
              onPressed: isUploading ? null : ()=> handleSubmit (),
              color: Colors.teal,
              child: Text('Post',style: TextStyle(
                  color: Colors.white,fontWeight: FontWeight.bold,fontSize: 20.0
              ),),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20.0)
              ),
            ),
          ),
        ],
      )
    );
  }
}
