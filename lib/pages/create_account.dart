import 'dart:async';

import 'package:flutter/material.dart';
import 'package:projectapp/widgets/header.dart';

class CreateAccount extends StatefulWidget {
  @override
  _CreateAccountState createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final _scaffold = GlobalKey<ScaffoldState>();
  final _formKey = GlobalKey<FormState>();
  String username;
  //String email;

  submit(){
    final form = _formKey.currentState;
    if(form.validate()){                   //form validate
      form.save();
      SnackBar snackBar = SnackBar(content: Text('Welcome to $username'),);
      _scaffold.currentState.showSnackBar(snackBar);
      Timer(Duration(seconds: 2),(){
        Navigator.pop(context, username);
      });
    }
  }
  @override
  Widget build(BuildContext parentContext) {
    return Scaffold(
      key: _scaffold,
      appBar: AppBar(
        backgroundColor: Colors.teal,
        automaticallyImplyLeading: false,
        title: Center(child: Text('Setup Your Profile',style: TextStyle(fontSize: 30.0,color: Colors.white,),)),
      ),
      body: ListView(
        children: <Widget>[
          Container(
            child: Column(
              children: <Widget>[
                Padding(
                  padding: EdgeInsets.only(top: 25.0),
                  child: Center(
                    child: Text(
                      'Create Your Username',
                      style: TextStyle(fontSize: 35.0,fontFamily: 'Signatra'),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.all(15.0),
                  child: Container(
                    child: Form(
                      key: _formKey,
                      autovalidate: true,
                      child: TextFormField(
                        validator: (val){                 //form validate
                          if(val.trim().length <3 || val.isEmpty){
                            return "Username is too short";
                          }
                          else if(val.trim().length>12){
                            return "Username is too long";
                          }
                          else {
                            return null;
                          }
                        },
                        onSaved: (val)=> username = val,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'Username',
                          hintText: 'Username',
                          labelStyle: TextStyle(fontSize: 15.0),
                        ),
                      ),
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: submit,
                  child: Container(
                    height: 50.0,
                    width: 300.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.teal,
                    ),
                    child: Center(
                      child: Text(
                        'Submit',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
