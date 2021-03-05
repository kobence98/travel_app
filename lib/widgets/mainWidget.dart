import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/main.dart';

import 'auth/loginWidget.dart';
import 'menuWidget.dart';
import 'onePictureWidget.dart';

bool likeRefresh;
var mainWidget;
bool changeSearchSettings;

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  PageController _pageControllerA;
  PageController _pageControllerB;

  @override
  void initState() {
    super.initState();
    likeRefresh = false;
    mainWidget = this;
    changeSearchSettings = false;
  }

  @override
  Widget build(BuildContext context) {
    _pageControllerA = new PageController(initialPage: 0);
    _pageControllerB = new PageController(initialPage: 1);
    if (!likeRefresh) {
      if (!changeSearchSettings) {
        placesList = null;
      }
      else{
        placesList.clear();
      }
      getPlaces().then((places) {
        if (places.isNotEmpty) {
          placesList = places;
          if(bestPlaces)
            placesList.sort((a, b) => b.likeNumber().compareTo(a.likeNumber()));
          if (allLiked)
            placesList.removeWhere(
                (place) => !place.usersLiked.contains(loggedInUser.uid));
          placesList.forEach((place) {
            place.setPictures().whenComplete(() {
              if (place == placesList.last) {
                setState(() {
                  likeRefresh = true;
                });
              }
            });
          });
        }
      });
    } else {
      likeRefresh = false;
    }
    return Scaffold(
      body: placesList == null
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/loading.gif"),
                  fit: BoxFit.fitWidth,
                ),
                color: Colors.black,
              ),
            )
          : PageView.builder(
              itemCount: placesList.isNotEmpty ? placesList.length : 1,
              controller: _pageControllerA,
              scrollDirection: Axis.vertical,
              itemBuilder: (BuildContext context, int indexA) {
                return PageView.builder(
                  itemCount: placesList.isNotEmpty
                      ? placesList[indexA].picNumber + 1
                      : 1,
                  controller: _pageControllerB,
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (BuildContext context, int indexB) {
                    if (placesList.isEmpty) {
                      indexA = 0;
                    }
                    if (changeSearchSettings) {
                      indexB = 0;
                      changeSearchSettings = false;
                    }
                    if (indexB == 0) {
                      return MenuWidget();
                    } else {
                      return OnePictureWidget(
                        currentPlaceNumber: indexA,
                        currentPictureId: indexB - 1,
                      );
                    }
                  },
                );
              },
            ),
    );
  }

  @override
  void dispose() {
    _pageControllerA.dispose();
    _pageControllerB.dispose();
    super.dispose();
  }
}
