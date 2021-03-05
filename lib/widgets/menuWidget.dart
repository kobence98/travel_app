import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/widgets/auth/loginWidget.dart';

import 'addPlaceWidget.dart';
import 'changePassWidget.dart';
import 'mainWidget.dart';

class MenuWidget extends StatefulWidget {
  @override
  _MenuWidgetState createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  double radiusSliderValue;
  double lengthSliderValue;
  double timeSliderValue;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (radius != null) radiusSliderValue = radius.toDouble();
    if (length != null) lengthSliderValue = length.toDouble();
    if (time != null) timeSliderValue = time.toDouble();
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
          leading: Icon(Icons.security),
          title: Text('Jelszó megváltoztatása'),
          onTap: onPassChange,
        ),
        ListTile(
          leading: Icon(Icons.radio_button_checked),
          title: Text('Maximális távolság: ' +
              (radius != null
                  ? radiusSliderValue.round().toString() + " km"
                  : "korlátlan")),
          trailing: Switch(value: radius != null, onChanged: onRadiusSwitcher),
        ),
        radius == null
            ? Container()
            : ListTile(
                title: Slider(
                  value: radiusSliderValue,
                  onChanged: (double value) {
                    radiusSliderValue = value;
                    onRadiusChange();
                  },
                  max: 1000,
                  min: 50,
                  divisions: 19,
                  label: radiusSliderValue.round().toString() + " km",
                ),
              ),
        ListTile(
          leading: Icon(Icons.edit_road_outlined),
          title: Text('Maximális hossz: ' +
              (length != null
                  ? lengthSliderValue.round().toString() + " km"
                  : "korlátlan")),
          trailing: Switch(value: length != null, onChanged: onLengthSwitcher),
        ),
        length == null
            ? Container()
            : ListTile(
                title: Slider(
                  value: lengthSliderValue,
                  onChanged: (double value) {
                    lengthSliderValue = value;
                    onLengthChange();
                  },
                  max: 15,
                  min: 1,
                  divisions: 14,
                  label: lengthSliderValue.round().toString() + " km",
                ),
              ),
        ListTile(
          leading: Icon(Icons.timer),
          title: Text('Maximális időtartam: ' +
              (time != null
                  ? timeSliderValue.round().toString() + " perc"
                  : "korlátlan")),
          trailing: Switch(value: time != null, onChanged: onTimeSwitcher),
        ),
        time == null
            ? Container()
            : ListTile(
                title: Slider(
                  value: timeSliderValue,
                  onChanged: (double value) {
                    timeSliderValue = value;
                    onTimeChange();
                  },
                  max: 600,
                  min: 30,
                  divisions: 19,
                  label: timeSliderValue.round().toString() + " perc",
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
      mainWidget.setState(() {
        changeSearchSettings = true;
      });
    });
  }

  void onRadiusChange() {
    mainWidget.setState(() {
      changeSearchSettings = true;
      radius = radiusSliderValue.round();
    });
  }

  void onLengthChange() {
    mainWidget.setState(() {
      changeSearchSettings = true;
      length = lengthSliderValue.round();
    });
  }

  void onTimeChange() {
    mainWidget.setState(() {
      changeSearchSettings = true;
      time = timeSliderValue.round();
    });
  }

  void logOut() {
    Navigator.of(context).pop();
    FirebaseAuth.instance.signOut();
  }

  void onRadiusSwitcher(bool switcher) {
    mainWidget.setState(() {
      changeSearchSettings = true;
      if (radius == null) {
        radius = 600;
      } else {
        radius = null;
      }
    });
  }

  void onLengthSwitcher(bool switcher) {
    mainWidget.setState(() {
      changeSearchSettings = true;
      if (length == null) {
        length = 6;
      } else {
        length = null;
      }
    });
  }

  void onTimeSwitcher(bool switcher) {
    mainWidget.setState(() {
      changeSearchSettings = true;
      if (time == null) {
        time = 300;
      } else {
        time = null;
      }
    });
  }

  void onPassChange() {
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (BuildContext context) {
      return ChangePassWidget();
    }));
  }
}