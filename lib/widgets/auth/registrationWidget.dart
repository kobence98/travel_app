import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_app/main.dart';

class RegistrationWidget extends StatefulWidget {
  @override
  _RegistrationWidgetState createState() => _RegistrationWidgetState();
}

class _RegistrationWidgetState extends State<RegistrationWidget> {
  final passwordController = TextEditingController();
  final passAgainController = TextEditingController();
  final emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text("Regisztráció"),
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/registration_cover.gif"),
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
                Center(
                  child: Container(
                    padding: EdgeInsets.only(
                      left: 10.0,
                      right: 10.0,
                    ),
                    color: Colors.red.withOpacity(0.7),
                    child: Text(
                      "A regisztrációt követően email-ben meg kell erősíteni azt!",
                      style: TextStyle(color: Colors.white),
                    ),
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
                        hintText: 'Email cím',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    color: Colors.white.withOpacity(0.7),
                    child: TextField(
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      controller: passwordController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Jelszó',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 5),
                Center(
                  child: Container(
                    padding: EdgeInsets.only(left: 20.0),
                    color: Colors.white.withOpacity(0.7),
                    child: TextField(
                      enableSuggestions: false,
                      autocorrect: false,
                      obscureText: true,
                      style: TextStyle(color: Colors.black),
                      controller: passAgainController,
                      cursorColor: Colors.black,
                      decoration: InputDecoration(
                        hintText: 'Jelszó újra',
                        hintStyle:
                            TextStyle(color: Colors.black.withOpacity(0.5)),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: ButtonTheme(
                    height: 50,
                    minWidth: 300,
                    child: RaisedButton(
                      onPressed: onRegistrationPress,
                      child: Text(
                        "Regisztráció",
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

  @override
  void dispose() {
    passwordController.dispose();
    passAgainController.dispose();
    emailController.dispose();
    super.dispose();
  }

  Future<void> onRegistrationPress() async {
    if (passwordController.text == passAgainController.text) {
      await userController
          .registerUser(emailController.text, passwordController.text)
          .then((success) {
        if (success) {
          Navigator.pop(context);
        }
      });
    } else {
      Fluttertoast.showToast(
          msg: "A jelszavak nem egyeznek meg!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }
}
