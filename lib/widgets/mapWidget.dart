import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:travel_app/widgets/auth/loginWidget.dart';

class MapWidget extends StatefulWidget {
  final int currentPlaceNumber;

  MapWidget({this.currentPlaceNumber});

  @override
  _MapWidgetState createState() =>
      _MapWidgetState(currentPlaceNumber: currentPlaceNumber);
}

class _MapWidgetState extends State<MapWidget> {
  final int currentPlaceNumber;
  bool init;

  _MapWidgetState({this.currentPlaceNumber});

  final Set<Polyline> polyLines = {};

  @override
  void initState() {
    super.initState();
    init = false;

    List<LatLng> tile = [];
    tile.add(placesList[currentPlaceNumber].coordinateList.first);
    tile.add(placesList[currentPlaceNumber].coordinateList.first);
    for (int i = 1;
        i < placesList[currentPlaceNumber].coordinateList.length;
        i++) {
      if (placesList[currentPlaceNumber].coordinateList.elementAt(i).longitude <
          tile.elementAt(0).longitude) {
        tile[0] = LatLng(
            tile.elementAt(0).latitude,
            placesList[currentPlaceNumber]
                .coordinateList
                .elementAt(i)
                .longitude);
      }
      if (placesList[currentPlaceNumber].coordinateList.elementAt(i).longitude >
          tile.elementAt(1).longitude) {
        tile[1] = LatLng(
            tile.elementAt(1).latitude,
            placesList[currentPlaceNumber]
                .coordinateList
                .elementAt(i)
                .longitude);
      }
      if (placesList[currentPlaceNumber].coordinateList.elementAt(i).latitude <
          tile.elementAt(0).latitude) {
        tile[0] = LatLng(
            placesList[currentPlaceNumber].coordinateList.elementAt(i).latitude,
            tile.elementAt(0).longitude);
      }
      if (placesList[currentPlaceNumber].coordinateList.elementAt(i).latitude >
          tile.elementAt(1).latitude) {
        tile[1] = LatLng(
            placesList[currentPlaceNumber].coordinateList.elementAt(i).latitude,
            tile.elementAt(1).longitude);
      }
    }
    FirebaseStorage.instance
        .ref("maps/pilis.txt")
        .getDownloadURL()
        .then((path) async {
      http.Response downloadData = await http.get(path);
      if (downloadData.statusCode == 200) {
        List<String> data = downloadData.body.split("\r\n\r\n");
        List<String> coordinates = data.elementAt(3).split("t,d,");
        coordinates.removeAt(0);
        coordinates.elementAt(coordinates.length - 1);
        int polylineId = 0;
        List<LatLng> latLngList = [];
        for (int i = 0; i < coordinates.length; i++) {
          double firstCoordinate =
              double.parse(coordinates.elementAt(i).split(",").elementAt(0));
          double secondCoordinate =
              double.parse(coordinates.elementAt(i).split(",").elementAt(1));
          if (i != 0 &&
              coordinates.elementAt(i).split(",").elementAt(5).contains("1")) {
            List<LatLng> tempLatLngList = latLngList.toList();
            if (checkLines(tile, tempLatLngList)) {
              polyLines.add(Polyline(
                  polylineId: PolylineId((polylineId++).toString()),
                  width: 1,
                  color: Colors.red,
                  points: tempLatLngList));
            }
            latLngList.clear();
            latLngList.add(LatLng(firstCoordinate, secondCoordinate));
          } else {
            latLngList.add(LatLng(firstCoordinate, secondCoordinate));
          }
        }
        if (checkLines(tile, latLngList)) {
          polyLines.add(Polyline(
              polylineId: PolylineId((polylineId++).toString()),
              width: 1,
              color: Colors.red,
              points: latLngList));
        }
        polyLines.add(Polyline(
            polylineId: PolylineId("utvonal"),
            width: 3,
            points: placesList[currentPlaceNumber].coordinateList));
        setState(() {
          init = true;
        });
      }
    });
  }

  bool checkLines(List<LatLng> tile, List<LatLng> list) {
    for (int i = 0; i < list.length; i++) {
      if (list.elementAt(i).latitude > tile.elementAt(0).latitude &&
          list.elementAt(i).latitude < tile.elementAt(1).latitude &&
          list.elementAt(i).longitude > tile.elementAt(0).longitude &&
          list.elementAt(i).longitude < tile.elementAt(1).longitude) {
        return true;
      }
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return !init
        ? Container()
        : Container(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: Stack(
              children: [
                GoogleMap(
                  polylines: polyLines,
                  initialCameraPosition: CameraPosition(
                      target: polyLines.last.points.first, zoom: 17),
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                ),
              ],
            ),
          );
  }

  @override
  void dispose() {
    super.dispose();
  }
}
