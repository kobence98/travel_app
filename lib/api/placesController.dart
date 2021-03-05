import 'dart:math';

import 'package:firebase_database/firebase_database.dart';
import 'package:travel_app/main.dart';
import 'package:travel_app/widgets/auth/loginWidget.dart';
import 'package:vector_math/vector_math.dart';

import '../entities/place.dart';

final databaseReference = FirebaseDatabase.instance.reference();

DatabaseReference savePlace(Place place) {
  var id = databaseReference.child('places/').push();
  id.set(place.toJson());
  return id;
}

void updatePlace(Place place, DatabaseReference id) {
  id.update(place.toJson());
}

Future<List<Place>> getPlaces() async {
  DataSnapshot dataSnapshot = await databaseReference.child('places/').once();
  List<Place> places = [];
  if (dataSnapshot.value != null) {
    dataSnapshot.value.forEach((key, value) {
      Place place = createPlace(value);
      if ((radius == null
          || distance(place.xCoordinate, currentLocation.latitude,
              place.yCoordinate, currentLocation.longitude)/1000 <= radius)
          && (time == null
          || time > (place.hours * 60 + place.minutes))
          && (length == null || place.length < length.toDouble())) {
        place.setId(databaseReference.child('places/' + key));
        places.add(place);
      }
    });
  }
  return places;
}

double distance(double lat1, double lat2, double lon1, double lon2) {
  final int R = 6371;

  double latDistance = radians(lat2 - lat1);
  double lonDistance = radians(lon2 - lon1);
  double a = sin(latDistance / 2) * sin(latDistance / 2) +
      cos(radians(lat1)) *
          cos(radians(lat2)) *
          sin(lonDistance / 2) *
          sin(lonDistance / 2);
  double c = 2 * atan2(sqrt(a), sqrt(1 - a));
  double distance = R * c * 1000;

  return distance;
}
