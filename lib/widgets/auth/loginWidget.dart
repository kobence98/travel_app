import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
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
      return Scaffold(
        body: StreamBuilder<User>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (BuildContext context, snapshot) {
            if (!snapshot.hasData) {
              return Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/main_cover.gif"),
                    fit: BoxFit.fill,
                  ),
                ),
                child: Center(
                  child: Container(
                    padding: EdgeInsets.all(
                        MediaQuery.of(context).size.height * 0.02),
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
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.5)),
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
                                hintStyle: TextStyle(
                                    color: Colors.black.withOpacity(0.5)),
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
              );
            } else {
              loggedInUser = snapshot.data;
              return MainWidget();
            }
          },
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
          showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    content: new Text(
                        "Az ön email címe nincsen megerősítve! Ha nem találja az üzenetet, akkor nézze meg először a spam mappát! Ha ezt is próbálta már, akkor kérjen újabb emailt, amelyre most van lehetősége. Kér újabb megerősítő emailt?"),
                    actions: [
                      TextButton(
                        child: Text('Igen!'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                      TextButton(
                        child: Text('Nem, előbb megnézem a spam mappát!'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ));
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
    ).whenComplete(() {
      Navigator.pop(context);
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LoginPage()),
      );
    });
  }

  void onForgetPasswordTap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgetPasswordWidget()),
    );
  }
}
