import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:location/location.dart';
import 'package:travel_app/entities/place.dart';
import 'package:travel_app/main.dart';

import '../mainWidget.dart';
import 'forgetPasswordTap.dart';
import 'registrationWidget.dart';

List<Place> placesList;
int radius;
bool allLiked;
bool bestPlaces;
int time;
int length;

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    Location location = new Location();
    location.getLocation().then((loc) {
      setState(() {
        currentLocation = loc;
      });
    });
    radius = 100;
    allLiked = false;
    bestPlaces = true;
  }

  @override
  Widget build(BuildContext context) {
    if (currentLocation == null) {
      return Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/loading.gif"),
            fit: BoxFit.fitWidth,
          ),
          color: Colors.black,
        ),
      );
    } else {
      FirebaseAuth.instance.authStateChanges().listen((User user) {
        if (user != null && user.emailVerified) {
          loggedInUser = user;
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainWidget()),
          ).whenComplete(() {
            emailController.clear();
            passwordController.clear();
          });
        }
      });
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: Text("Travel app"),
        ),
        body: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/main_cover.gif"),
              fit: BoxFit.fill,
            ),
          ),
          child: Center(
            child: Container(
              padding:
                  EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
              width: 600,
              height: 1000,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  SizedBox(height: 10),
                  Center(
                    child: ButtonTheme(
                      height: 50,
                      minWidth: 300,
                      child: RaisedButton(
                        onPressed: onLoginPressed,
                        child: Text(
                          "Bejelentkezés",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: ButtonTheme(
                      height: 50,
                      minWidth: 300,
                      child: RaisedButton(
                        onPressed: onRegistrationPressed,
                        child: Text(
                          "Regisztráció",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 20),
                        ),
                        color: Colors.white,
                      ),
                    ),
                  ),
                  SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      child: Text(
                        "Elfelejtetted a jelszavadat? Kattints ide!",
                        style: TextStyle(color: Colors.white),
                      ),
                      onTap: onForgetPasswordTap,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    FirebaseAuth.instance.signOut();
    super.dispose();
  }

  //GOMBOK KATTINTÁSAI
  void onLoginPressed() {
    userController
        .loginUser(emailController.text, passwordController.text)
        .then((success) {
      if (success) {
        if (!loggedInUser.emailVerified) {
          Fluttertoast.showToast(
              msg: "A fiókot emailben meg kell erősíteni!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          FirebaseAuth.instance.signOut();
        } else {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MainWidget()),
          ).whenComplete(() {
            emailController.clear();
            passwordController.clear();
          });
        }
      }
    });
  }

  void onRegistrationPressed() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => RegistrationWidget()),
    );
  }

  void onForgetPasswordTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgetPasswordWidget()),
    );
  }
}
