import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

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

  _PicDataWidgetState({this.currentPlaceNumber});

  @override
  void initState() {
    super.initState();
    placesList[currentPlaceNumber].setGPX();
  }

  @override
  Widget build(BuildContext context) {
    return _picDataWidget();
  }

  Widget _picDataWidget() {
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
                    " km - " + placesList[currentPlaceNumber].hours.toString() + " óra " +
                    placesList[currentPlaceNumber].minutes.toString() + " perc")),
            ListTile(
                leading: Icon(Icons.height),
                title: Text("Szintkülönbség: " +
                    placesList[currentPlaceNumber].levelDiff.toString() + " méter")),
            ListTile(
                leading: Icon(Icons.favorite),
                title: Text("Likeok száma: " +
                    placesList[currentPlaceNumber].likeNumber().toString())),
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

  void _onDestroy() {
    Navigator.of(context).pop();
  }
}
