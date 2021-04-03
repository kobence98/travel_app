import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:gpx/gpx.dart';
import 'package:travel_app/api/placesController.dart';

class Place {
  DatabaseReference id;
  String creatorUId;
  String name;
  Set usersLiked = {};
  int picNumber;
  double xCoordinate;
  double yCoordinate;
  List<CachedNetworkImageProvider> pictures = [];
  List<LatLng> coordinateList = [];
  double length;
  int hours;
  int minutes;
  int levelDiffUp;
  int levelDiffDown;
  String kirtippekLink;

  Place(this.name, this.picNumber, this.xCoordinate, this.yCoordinate,
      this.creatorUId, this.length, this.hours, this.minutes, this.levelDiffUp, this.levelDiffDown, this.kirtippekLink);

  void likePlace(User user) {
    if (this.usersLiked.contains(user.uid)) {
      this.usersLiked.remove(user.uid);
    } else {
      this.usersLiked.add(user.uid);
    }
    this.update();
  }

  void setId(DatabaseReference id) {
    this.id = id;
  }

  Map<String, dynamic> toJson() {
    return {
      'name': this.name,
      'usersLiked': this.usersLiked.toList(),
      'picNumber': this.picNumber,
      'creatorUId': this.creatorUId,
      'xCoordinate': this.xCoordinate,
      'yCoordinate': this.yCoordinate,
      'length': this.length,
      'hours': this.hours,
      'minutes': this.minutes,
      'levelDiffUp': this.levelDiffUp,
      'levelDiffDown': this.levelDiffDown,
      'kirtippekLink': this.kirtippekLink
    };
  }

  int likeNumber() {
    return usersLiked.length;
  }

  void update() {
    updatePlace(this, this.id);
  }

  Future<void> setPictures() async {
    for (int i = 0; i < picNumber; i++) {
      await FirebaseStorage.instance
          .ref(id.path + '/' + i.toString() + '.jpg')
          .getDownloadURL()
          .then((path) => pictures.add(CachedNetworkImageProvider(path)));

    }
  }

  Future<void> setGPX() async {
    Reference ref =
        FirebaseStorage.instance.ref('/' + id.path).child('place.gpx');
    await ref.getData().then((downloadedData) {
      Gpx file = GpxReader().fromString(utf8.decode(downloadedData));
      file.trks.first.trksegs.first.trkpts.forEach((point) {
        coordinateList.add(LatLng(point.lat, point.lon));
      });
    });
  }

  List<LatLng> searchMapLatLngEast(){
    double east = coordinateList.elementAt(0).longitude;
    double west = coordinateList.elementAt(0).longitude;
    double north = coordinateList.elementAt(0).latitude;
    double south = coordinateList.elementAt(0).latitude;
    for(int i = 0; i < coordinateList.length; i++){
      double lon = coordinateList.elementAt(i).longitude;
      double lat = coordinateList.elementAt(i).latitude;
      if(lon < east) east = lon;
      if(lon > west) west = lon;
      if(lat < south) south = lat;
      if(lat > north) north = lat;
    }
    List<LatLng> result = [];
    result.add(LatLng(north, east));
    result.add(LatLng(south, west));
    return result;
  }
}

//hely létrehozása
Place createPlace(record) {
  Map<String, dynamic> attributes = {
    'name': '',
    'usersLiked': [],
    'picNumber': 0,
    'xCoordinate': 0.0,
    'yCoordinate': 0.0,
    'creatorUId': '',
    'length': 0.0,
    'hours': 0,
    'minutes': 0,
    'levelDiffUp': 0,
    'levelDiffDown': 0,
    'kirtippekLink': ''
  };

  record.forEach((key, value) => {attributes[key] = value});

  Place place = new Place(
      attributes['name'],
      attributes['picNumber'],
      attributes['xCoordinate'].toDouble(),
      attributes['yCoordinate'].toDouble(),
      attributes['creatorUId'],
      attributes['length'].toDouble(),
      attributes['hours'],
      attributes['minutes'],
      attributes['levelDiffUp'],
      attributes['levelDiffDown'],
      attributes['kirtippekLink']
  );
  place.usersLiked = Set.from(attributes['usersLiked']);
  return place;
}
