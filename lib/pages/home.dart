import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:projectapp/models/user.dart';
import 'package:projectapp/pages/activity_feed.dart';
import 'package:projectapp/pages/extra.dart';
import 'package:projectapp/pages/profile.dart';
import 'package:projectapp/pages/routine.dart';
import 'package:projectapp/pages/search.dart';
import 'package:projectapp/pages/timeline.dart';
import 'package:projectapp/pages/upload.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'create_account.dart';

final GoogleSignIn googleSignIn = GoogleSignIn();
final StorageReference storageReference =FirebaseStorage.instance.ref();
final userRef = Firestore.instance.collection('users');
final postRef = Firestore.instance.collection('posts');
final commentRef = Firestore.instance.collection('comments');
final activityFeedRef = Firestore.instance.collection('feed');
final followers = Firestore.instance.collection('follower');
final followingRef = Firestore.instance.collection('following');
final timelineRef = Firestore.instance.collection('timeline');
final DateTime timestamp = DateTime.now();
User currentUser;

class Home extends StatefulWidget {
  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool isAuth = false;
  PageController pageController;
  int pageIndex = 0;

  @override
  void initState(){
    super.initState();
    pageController = PageController();

    googleSignIn.onCurrentUserChanged.listen((account){
      handleSignIn(account);
    },onError: (err){
        print('Error User SignIn : $err');
    });

    googleSignIn.signInSilently(suppressErrors: false)
        .then((account){
          handleSignIn(account);
    }).catchError((err){
      print('Error User SignIn : $err');
    });
  }
  handleSignIn(GoogleSignInAccount account)async{
    if(account != null){
      await createUserFirestore();
      setState(() {
        isAuth = true;
      });
    }else{
      setState(() {
        isAuth = false;
      });
    }
  }



  createUserFirestore() async{
    final GoogleSignInAccount user = googleSignIn.currentUser;
     DocumentSnapshot doc = await userRef.document(user.id).get();
    if(!doc.exists){
      final username = await Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateAccount()));

      userRef.document(user.id).setData({
        'id':user.id,
        'email':user.email,
        'username':username,
        'displayName':user.displayName,
        'photoUrl':user.photoUrl,
        'bio':'',
        'timestamp':timestamp,

      });
      doc = await userRef.document(user.id).get();
    }
    currentUser= User.formDocument(doc);
     print(currentUser);
    print(currentUser.username);
  }

  @override
  void dispose(){
    pageController.dispose();
    super.dispose();
  }

  onPageChanged(int pageIndex){
    setState(() {
      this.pageIndex = pageIndex;
    });
  }

  onTap(int pageIndex){
    pageController.animateToPage(
      pageIndex,
      duration: Duration(milliseconds: 200),
      curve: Curves.easeInOut,
    );
  }

  login(){
    googleSignIn.signIn();
  }

  logout(){
    googleSignIn.signOut();
  }

  Scaffold buildAuthScreen(){
    return Scaffold(
      body: PageView(
        children: <Widget>[
          //Timeline(),
          Timeline(currentUser:currentUser),
         Extra(profileId:currentUser?.id),
          ActivityFeed(),
          Upload(currentUser:currentUser),
          Search(),
          Profile(profileId:currentUser?.id),     //current user null nake ,ta check korba
        ],
        controller: pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: onPageChanged,
      ),
      bottomNavigationBar: CupertinoTabBar(

        currentIndex: pageIndex,
        onTap: onTap,
        activeColor:Theme.of(context).primaryColor ,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.whatshot)),
          BottomNavigationBarItem(icon: Icon(Icons.library_books)),
          BottomNavigationBarItem(icon: Icon(Icons.notifications_active)),
          BottomNavigationBarItem(icon: Icon(Icons.control_point_duplicate,size: 40.0,)),
          BottomNavigationBarItem(icon: Icon(Icons.search)),
          BottomNavigationBarItem(icon: Icon(Icons.account_circle)),
        ],
      ),
    );
  }

  Scaffold buildUnAuthScreen(){
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              Theme.of(context).primaryColor.withOpacity(0.2),
              Theme.of(context).accentColor,
            ],
          ),
        ),
        alignment: Alignment.center,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Text(
              'Class TO-Do',
              style: TextStyle(
                fontSize: 90.0,
                fontFamily: 'Signatra',
                color: Colors.white,
              ),
            ),
            GestureDetector(
              onTap: login,
              child: Container(
                width: 260.0,
                height: 60.0,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/images/google_signin_button.png'),
                    fit: BoxFit.cover
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return isAuth ? buildAuthScreen() : buildUnAuthScreen();
  }
}
