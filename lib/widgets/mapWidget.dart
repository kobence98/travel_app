import 'dart:collection';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
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

  _MapWidgetState({this.currentPlaceNumber});

  Set<Polyline> polyLines;

  @override
  void initState() {
    super.initState();
    polyLines = new HashSet();
    polyLines.add(Polyline(
        polylineId: PolylineId("utvonal"),
        width: 2,
        points: placesList[currentPlaceNumber].coordinateList));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height,
      width: MediaQuery.of(context).size.width,
      child: Stack(
        children: [
          GoogleMap(
            polylines: polyLines,
            initialCameraPosition:
                CameraPosition(target: polyLines.first.points.first, zoom: 17),
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
