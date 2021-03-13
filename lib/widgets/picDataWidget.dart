import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:map_launcher/map_launcher.dart';
import 'package:weather/weather.dart';
import 'package:weather_icons/weather_icons.dart';

import 'auth/loginWidget.dart';
import 'mapWidget.dart';

class PicDataWidget extends StatefulWidget {
  final int currentPlaceNumber;

  PicDataWidget({this.currentPlaceNumber});

  @override
  _PicDataWidgetState createState() =>
      _PicDataWidgetState(currentPlaceNumber: currentPlaceNumber);
}

class _PicDataWidgetState extends State<PicDataWidget> {
  final int currentPlaceNumber;
  List<Weather> weather;

  _PicDataWidgetState({this.currentPlaceNumber});

  @override
  void initState() {
    super.initState();
    placesList[currentPlaceNumber].setGPX();
    WeatherFactory wf = new WeatherFactory("c04464c51f6b391b2799d8bc8e62eb7f");
    wf
        .fiveDayForecastByLocation(placesList[currentPlaceNumber].xCoordinate,
            placesList[currentPlaceNumber].yCoordinate)
        .then((value) {
      setState(() {
        weather = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return weather != null
        ? _picDataWidget()
        : Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("assets/images/loading.gif"),
                fit: BoxFit.fitWidth,
              ),
              color: Colors.black,
            ),
          );
  }

  BoxedIcon _weatherIcon(String iconCode){
    switch(iconCode.substring(0, 2)){
      case "01":
        return BoxedIcon(iconCode.characters.elementAt(2) == "d" ? WeatherIcons.day_sunny : WeatherIcons.moon_alt_full);
      case "02":
        return BoxedIcon(iconCode.characters.elementAt(2) == "d" ? WeatherIcons.day_sunny_overcast : WeatherIcons.night_alt_partly_cloudy);
      case "03":
        return BoxedIcon(WeatherIcons.cloudy);
      case "04":
        return BoxedIcon(WeatherIcons.cloud);
      case "09":
        return BoxedIcon(WeatherIcons.rain);
      case "10":
        return BoxedIcon(iconCode.characters.elementAt(2) == "d" ? WeatherIcons.day_rain : WeatherIcons.night_alt_rain);
      case "11":
        return BoxedIcon(WeatherIcons.lightning);
      case "13":
        return BoxedIcon(WeatherIcons.snow);
      case "50":
        return BoxedIcon(WeatherIcons.fog);
    }
    return BoxedIcon(Icons.not_listed_location_outlined);
  }

  Widget _picDataWidget() {
    List<Widget> _widgetList = [];

    for (int i = 0; i < 8; i++) {
      _widgetList.add(
        Flexible(
          child: Column(
            children: [
              Container(
                child: Center(
                  child: Text((i * 3 + 1).toString()),
                ),
              ),
              Container(
                  child: Text(weather
                          .elementAt(i)
                          .temperature
                          .celsius
                          .round()
                          .toString() +
                      "C°")),
              Container(
                child: _weatherIcon(weather.elementAt(i).weatherIcon),
              ),
            ],
          ),
          flex: 1,
        ),
      );
    }

    return new Scaffold(
      body: InkWell(
        child: ListView(
          padding: EdgeInsets.only(top: 50),
          children: <Widget>[
            ListTile(
                leading: Icon(Icons.font_download),
                title: Text("Név: " + placesList[currentPlaceNumber].name)),
            ListTile(
                leading: Icon(Icons.place), title: Text("Kezdő koordináták:")),
            ListTile(
                title: TextField(
                    textAlign: TextAlign.left,
                    decoration: new InputDecoration(
                        hintText: "x: " +
                            placesList[currentPlaceNumber]
                                .xCoordinate
                                .toString(),
                        contentPadding: EdgeInsets.only(left: 30)))),
            ListTile(
                title: TextField(
                    textAlign: TextAlign.left,
                    decoration: new InputDecoration(
                        hintText: "y: " +
                            placesList[currentPlaceNumber]
                                .yCoordinate
                                .toString(),
                        contentPadding: EdgeInsets.only(left: 30)))),
            ListTile(
                leading: Icon(Icons.edit_road),
                title: Text("Túra hossza: " +
                    placesList[currentPlaceNumber].length.toString() +
                    " km - " +
                    placesList[currentPlaceNumber].hours.toString() +
                    " óra " +
                    placesList[currentPlaceNumber].minutes.toString() +
                    " perc")),
            ListTile(
                leading: Icon(Icons.height),
                title: Text("Szintkülönbség: " +
                    placesList[currentPlaceNumber].levelDiffUp.toString() +
                    " méter fel - " +
                    (placesList[currentPlaceNumber].levelDiffDown * (-1))
                        .toString() +
                    " méter le")),
            ListTile(
                leading: Icon(Icons.favorite),
                title: Text("Likeok száma: " +
                    placesList[currentPlaceNumber].likeNumber().toString())),
            ListTile(
              leading: Icon(Icons.wb_sunny),
              title: Row(
                children: [
                  _widgetList[0],
                  _widgetList[1],
                  _widgetList[2],
                  _widgetList[3],
                  _widgetList[4],
                  _widgetList[5],
                  _widgetList[6],
                  _widgetList[7],
                ],
              ),
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue.shade900),
              ),
              child: Text(
                "Útvonalterv az induláshoz!",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: onRoutePlanPress,
            ),
            ElevatedButton(
              style: ButtonStyle(
                backgroundColor:
                    MaterialStateProperty.all<Color>(Colors.blue.shade900),
              ),
              child: Text(
                "Indulás!",
                style: TextStyle(
                  color: Colors.white,
                ),
              ),
              onPressed: onMapPress,
            ),
          ],
        ),
        onTap: _onDestroy,
      ),
    );
  }

  void onMapPress() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => MapWidget(
                currentPlaceNumber: currentPlaceNumber,
              )),
    );
  }

  Future<void> onRoutePlanPress() async {
    final availableMaps = await MapLauncher.installedMaps;
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Container(
              child: Wrap(
                children: <Widget>[
                  for (var map in availableMaps)
                    ListTile(
                      onTap: () => map.showMarker(
                        coords: Coords(
                            placesList
                                .elementAt(currentPlaceNumber)
                                .xCoordinate,
                            placesList
                                .elementAt(currentPlaceNumber)
                                .yCoordinate),
                        title: placesList.elementAt(currentPlaceNumber).name,
                      ),
                      title: Text(map.mapName),
                      leading: SvgPicture.asset(
                        map.icon,
                        height: 30.0,
                        width: 30.0,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _onDestroy() {
    Navigator.of(context).pop();
  }
}
