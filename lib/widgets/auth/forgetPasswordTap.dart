import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ForgetPasswordWidget extends StatefulWidget {
  @override
  _ForgetPasswordWidgetState createState() => _ForgetPasswordWidgetState();
}

class _ForgetPasswordWidgetState extends State<ForgetPasswordWidget> {
  final emailController = TextEditingController();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Elfelejtett jelszó"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/forget_pass_cover.gif"),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Container(
            padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
            width: 600,
            height: 1000,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Container(
                  padding: EdgeInsets.only(
                    left: 10.0,
                    right: 10.0,
                  ),
                  color: Colors.red.withOpacity(0.7),
                  child: Text(
                    "Az új generált jelszavát kiküldjük a megadott email címre. Bejelentkezést követően meg tudja változtatni azt.",
                    style: TextStyle(color: Colors.white),
                    textAlign: TextAlign.center,
                  ),
                ),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    color: Colors.white.withOpacity(0.7),
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: emailController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ButtonTheme(
                    height: 50,
                    minWidth: 300,
                    child: RaisedButton(
                      onPressed: onEmailPressed,
                      child: Text(
                        "Email küldése",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void onEmailPressed() {
    FirebaseAuth.instance.sendPasswordResetEmail(email: emailController.text);
    Navigator.pop(context);
  }

  @override
  void dispose() {
    emailController.dispose();
    super.dispose();
  }
}
