import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:travel_app/widgets/auth/loginWidget.dart';

import 'offlinePlacesWidget.dart';

class OfflineOrOnlineWidget extends StatefulWidget {
  @override
  _OfflineOrOnlineWidgetState createState() => _OfflineOrOnlineWidgetState();
}

class _OfflineOrOnlineWidgetState extends State<OfflineOrOnlineWidget> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/offline_or_online_cover.gif"),
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
                  child: ButtonTheme(
                    height: 50,
                    minWidth: 300,
                    child: ElevatedButton(
                      onPressed: onOnlinePress,
                      child: Text(
                        "Online folytatás",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.shade900)),
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Center(
                  child: ButtonTheme(
                    height: 50,
                    minWidth: 300,
                    child: ElevatedButton(
                      onPressed: onOfflinePress,
                      child: Text(
                        "Offline térképek megtekintése",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 20),
                      ),
                      style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(Colors.blue.shade900)),
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

  void onOnlinePress() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => LoginPage()),);
  }

  void onOfflinePress() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => OfflinePlacesWidget()),);
  }

  @override
  void initState() {
    super.initState();
    try {
      installOfflineMapTiles("assets/cache.db");
    } catch (err) {
      print(err);
    }
  }
}
