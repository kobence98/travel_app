import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:travel_app/widgets/auth/loginWidget.dart';

import 'addPlaceWidget.dart';
import 'changePassWidget.dart';
import 'mainWidget.dart';
import 'ownPlacesWidget.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  RangeValues radiusSliderValue;
  RangeValues lengthSliderValue;
  RangeValues timeSliderValue;
  TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (placesList.isEmpty) {
      Fluttertoast.showToast(
          msg:
          "Nem található egyetlen hely sem a körzetedben, állíts a filtereken!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (maxRadius != null)
      radiusSliderValue =
          RangeValues(minRadius.toDouble(), maxRadius.toDouble());
    if (maxLength != null)
      lengthSliderValue =
          RangeValues(minLength.toDouble(), maxLength.toDouble());
    if (maxTime != null)
      timeSliderValue = RangeValues(minTime.toDouble(), maxTime.toDouble());
    return _menuWidget();
  }

  Widget _menuWidget() {
    return ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          child: null,
          decoration: BoxDecoration(
              color: Colors.green,
              image: DecorationImage(
                  fit: BoxFit.fill,
                  image: AssetImage("assets/images/menu_cover.jpg"))),
        ),
        ListTile(
          leading: Icon(Icons.add_location_alt),
          title: Text('Kirándulóhely hozzáadása'),
          onTap: addPlace,
        ),
        ListTile(
          leading: Icon(Icons.edit_location_rounded),
          title: Text('Saját helyek kezelése'),
          onTap: ownPlaces,
        ),
        ListTile(
          leading: Icon(Icons.security),
          title: Text('Jelszó megváltoztatása'),
          onTap: onPassChange,
        ),
        ListTile(
          leading: Icon(Icons.search),
          title: Row(
            children: [
              Flexible(
                child: Text('Hely keresése:'),
                flex: 4,
              ),
              Flexible(
                child: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: nameController,
                  cursorColor: Colors.black,
                ),
                flex: 5,
              ),
              Flexible(
                child: IconButton(
                  icon: Icon(Icons.search),
                  onPressed: onSearchPress,
                ),
                flex: 1,
              )
            ],
          ),
        ),
        SizedBox(
          height: 2,
          child: Container(
            color: Colors.black,
          ),
        ),
        ListTile(
          leading: Icon(Icons.radio_button_checked),
          title: Text('Távolság: ' +
              (maxRadius != null
                  ? radiusSliderValue.start.round().toString() +
                      " - " +
                      radiusSliderValue.end.round().toString() +
                      " km"
                  : "korlátlan")),
          trailing:
              Switch(value: maxRadius != null, onChanged: onRadiusSwitcher),
        ),
        maxRadius == null
            ? Container()
            : ListTile(
                title: RangeSlider(
                  values: radiusSliderValue,
                  onChanged: (RangeValues values) {
                    setState(() {
                      radiusSliderValue = values;
                      minRadius = radiusSliderValue.start.round();
                      maxRadius = radiusSliderValue.end.round();
                    });
                  },
                  max: 1000,
                  min: 0,
                  divisions: 50,
                  labels: RangeLabels(
                      radiusSliderValue.start.round().toString() + " km",
                      radiusSliderValue.end.round().toString() + " km"),
                ),
              ),
        ListTile(
          leading: Icon(Icons.edit_road_outlined),
          title: Text('Hossz: ' +
              (maxLength != null
                  ? lengthSliderValue.start.round().toString() +
                      " - " +
                      lengthSliderValue.end.round().toString() +
                      " km"
                  : "korlátlan")),
          trailing:
              Switch(value: maxLength != null, onChanged: onLengthSwitcher),
        ),
        maxLength == null
            ? Container()
            : ListTile(
                title: RangeSlider(
                  values: lengthSliderValue,
                  onChanged: (RangeValues values) {
                    setState(() {
                      lengthSliderValue = values;
                      minLength = lengthSliderValue.start.round();
                      maxLength = lengthSliderValue.end.round();
                    });
                  },
                  max: 15,
                  min: 0,
                  divisions: 15,
                  labels: RangeLabels(
                      lengthSliderValue.start.round().toString() + " km",
                      lengthSliderValue.end.round().toString() + " km"),
                ),
              ),
        ListTile(
          leading: Icon(Icons.timer),
          title: Text('Maximális időtartam: ' +
              (maxTime != null
                  ? timeSliderValue.start.round().toString() +
                      " - " +
                      timeSliderValue.end.round().toString() +
                      " perc"
                  : "korlátlan")),
          trailing: Switch(value: maxTime != null, onChanged: onTimeSwitcher),
        ),
        maxTime == null
            ? Container()
            : ListTile(
                title: RangeSlider(
                  values: timeSliderValue,
                  onChanged: (RangeValues values) {
                    setState(() {
                      timeSliderValue = values;
                      minTime = timeSliderValue.start.round();
                      maxTime = timeSliderValue.end.round();
                    });
                  },
                  max: 600,
                  min: 0,
                  divisions: 20,
                  labels: RangeLabels(
                      timeSliderValue.start.round().toString() + " perc",
                      timeSliderValue.end.round().toString() + " perc"),
                ),
              ),
        ListTile(
          leading: Icon(Icons.done_all),
          title: Text(
            "Filterek aktiválása",
            style: TextStyle(color: Colors.white),
          ),
          tileColor: Colors.blue,
          onTap: onFiltersPressed,
        ),
        SizedBox(
          height: 2,
          child: Container(
            color: Colors.black,
          ),
        ),
        ListTile(
          leading: Icon(Icons.exit_to_app),
          title: Text('Kijelentkezés'),
          onTap: logOut,
        ),
      ],
    );
  }

  void addPlace() {
    Navigator.push(
            context, MaterialPageRoute(builder: (context) => AddPlaceWidget()))
        .whenComplete(() {
      mainWidget.setState(() {});
    });
  }

  void onFiltersPressed() {
    mainWidget.setState(() {
      maxRadius =
          radiusSliderValue == null ? null : radiusSliderValue.end.round();
      maxLength =
          lengthSliderValue == null ? null : lengthSliderValue.end.round();
      maxTime = timeSliderValue == null ? null : timeSliderValue.end.round();
      minRadius =
          radiusSliderValue == null ? null : radiusSliderValue.start.round();
      minLength =
          lengthSliderValue == null ? null : lengthSliderValue.start.round();
      minTime = timeSliderValue == null ? null : timeSliderValue.start.round();
    });
  }

  void logOut() {
    FirebaseAuth.instance.signOut().whenComplete((){
      placesList.clear();
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (BuildContext context) => LoginPage(),
        ),
            (route) => false,
      );
    });
  }

  void onRadiusSwitcher(bool switcher) {
    setState(() {
      if (maxRadius == null) {
        maxRadius = 600;
        minRadius = 0;
      } else {
        maxRadius = null;
        minRadius = null;
      }
    });
  }

  void onLengthSwitcher(bool switcher) {
    setState(() {
      if (maxLength == null) {
        maxLength = 6;
        minLength = 0;
      } else {
        maxLength = null;
        minLength = null;
      }
    });
  }

  void onTimeSwitcher(bool switcher) {
    setState(() {
      if (maxTime == null) {
        maxTime = 300;
        minTime = 0;
      } else {
        maxTime = null;
        minTime = null;
      }
    });
  }

  void ownPlaces() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return OwnPlacesWidget();
    })).whenComplete(() => mainWidget.setState(() {}));
  }

  void onPassChange() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ChangePassWidget();
    }));
  }

  void onSearchPress() {
    mainWidget.setState(() {
      searchByName = true;
      name = nameController.text;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
