import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ChangePassWidget extends StatefulWidget {
  @override
  _ChangePassWidgetState createState() => _ChangePassWidgetState();
}

class _ChangePassWidgetState extends State<ChangePassWidget> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController passAgainController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _passChangeBody()
    );
  }

  Widget _passChangeBody(){
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/change_pass_cover.gif"),
          fit: BoxFit.cover,
        ),
      ),
      child: Center(
        child: Container(
          padding: EdgeInsets.all(MediaQuery.of(context).size.height * 0.02),
          width: 600,
          height: MediaQuery.of(context).size.height / 3 * 2,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(left: 20.0),
                  color: Colors.white.withOpacity(0.7),
                  child: TextField(
                    autofocus: true,
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
                  height: 70,
                  minWidth: 300,
                  child: ElevatedButton(
                    onPressed: onChangePassPress,
                    child: Text(
                      "Jelszó megváltoztatása",
                      style: TextStyle(fontSize: 20, color: Colors.black),
                    ),
                    style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all<Color>(Colors.white)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    passwordController.dispose();
    passAgainController.dispose();
    super.dispose();
  }

  Future<void> onChangePassPress() async {
    if (passwordController.text == passAgainController.text) {
      if(passwordController.text.isEmpty){
        Fluttertoast.showToast(
            msg: "Üres a jelszó mező!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
      else {
        try {
          FirebaseAuth.instance.currentUser
              .updatePassword(passwordController.text).whenComplete(() {
              Navigator.of(context).pop();
              Fluttertoast.showToast(
              msg: "Sikeres jelszóváltoztatás!",
              toastLength: Toast.LENGTH_LONG,
              gravity: ToastGravity.CENTER,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.red,
              textColor: Colors.white,
              fontSize: 16.0);
          });
        } on FirebaseAuthException catch (e) {
          if (e.code == 'weak-password') {
            Fluttertoast.showToast(
                msg: "Túl gyenge jelszó!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          else if (e.code == 'weak-password') {
            Fluttertoast.showToast(
                msg: "Túl gyenge jelszó!",
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
          else{
            Fluttertoast.showToast(
                msg: e.message,
                toastLength: Toast.LENGTH_LONG,
                gravity: ToastGravity.CENTER,
                timeInSecForIosWeb: 2,
                backgroundColor: Colors.red,
                textColor: Colors.white,
                fontSize: 16.0);
          }
        }
      }
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
