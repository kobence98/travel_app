import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/helper/customScrollPhysics.dart';
import 'package:travel_app/main.dart';

import 'auth/loginWidget.dart';
import 'menuWidget.dart';
import 'onePictureWidget.dart';

bool likeRefresh;
var mainWidget;
bool changeSearchSettings;
String name;
bool searchByName;
bool notAnyPlaces;

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  PageController _pageControllerA;
  PageController _pageControllerB;
  bool isInitialPage;

  @override
  void initState() {
    super.initState();
    isInitialPage = false;
    likeRefresh = false;
    mainWidget = this;
    changeSearchSettings = false;
    searchByName = false;
    notAnyPlaces = false;
  }

  @override
  Widget build(BuildContext context) {
    _pageControllerA = new PageController(initialPage: 0);
    _pageControllerB = new PageController(initialPage: 1);
    if (!likeRefresh) {
      if (!changeSearchSettings && !notAnyPlaces) {
        placesList = null;
      } else {
        placesList.clear();
      }
      getPlaces().then((places) {
        if (places.isNotEmpty) {
          placesList = places;
          if (searchByName) {
            searchByName = false;
          } else {
            if (bestPlaces)
              placesList
                  .sort((a, b) => b.likeNumber().compareTo(a.likeNumber()));
            if (allLiked)
              placesList.removeWhere(
                  (place) => !place.usersLiked.contains(loggedInUser.uid));
          }
          placesList.forEach((place) {
            place.setPictures().whenComplete(() {
              if (placesList.isEmpty ||
                  (place == placesList.last &&
                      place.pictures.length == place.picNumber)) {
                setState(() {
                  likeRefresh = true;
                });
              }
            });
          });
        } else {
          setState(() {
            notAnyPlaces = true;
            placesList = [];
          });
        }
      });
    } else {
      likeRefresh = false;
    }
    return WillPopScope(
      child: Scaffold(
        body: placesList == null && !notAnyPlaces
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
                        isInitialPage = false;
                        return MenuWidget();
                      } else {
                        if (indexB > 1)
                          isInitialPage = false;
                        else
                          isInitialPage = true;
                        return OnePictureWidget(
                          currentPlaceNumber: indexA,
                          currentPictureId: indexB - 1,
                        );
                      }
                    },
                    physics: const CustomScrollPhysics(),
                  );
                },
              ),
      ),
      onWillPop: _onWillPop,
    );
  }

  Future<bool> _onWillPop() {
    if (!isInitialPage) {
      _pageControllerB.animateToPage(
        1,
        duration: Duration(milliseconds: 1000),
        curve: Curves.easeInOutExpo,
      );

      return Future.value(false);
    } else {
      return showDialog(
              context: context,
              builder: (_) => new AlertDialog(
                    content:
                        new Text("Bitosan ki akarsz lépni az alkalmazásból?"),
                    actions: [
                      TextButton(
                        child: Text('Igen!'),
                        onPressed: () {
                          Navigator.of(context).pop(true);
                        },
                      ),
                      TextButton(
                        child: Text('Mégse'),
                        onPressed: () {
                          Navigator.of(context).pop(false);
                        },
                      ),
                    ],
                  )) ??
          false;
    }
  }

  @override
  void dispose() {
    _pageControllerA.dispose();
    _pageControllerB.dispose();
    super.dispose();
  }
}
