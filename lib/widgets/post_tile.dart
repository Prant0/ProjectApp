import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/pages/post_screen.dart';

class PostTile extends StatelessWidget {

  final Post post;
  PostTile({this.post});
  showPost(context){
    Navigator.push(context, MaterialPageRoute(builder: (context)=>Post(postId:post.postId, ownerId:  post.ownerId,)));
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: ()=>showPost(context),
      child: post,
    );
  }
}
