import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/helper/customScrollPhysics.dart';
import 'package:travel_app/main.dart';

import 'auth/loginWidget.dart';
import 'menuWidget.dart';
import 'onePictureWidget.dart';

bool likeRefresh;
var mainWidget;
String name;
bool searchByName;
bool allLiked;
bool bestPlaces;
int maxRadius;
int maxTime;
int maxLength;
int minRadius;
int minTime;
int minLength;
bool loaded;

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  PreloadPageController _pageControllerA;
  PreloadPageController _pageControllerB;
  bool isInitialPage;

  @override
  void initState() {
    super.initState();
    isInitialPage = false;
    likeRefresh = false;
    searchByName = false;
    allLiked = false;
    bestPlaces = true;
    maxRadius = 10;
    minRadius = 0;
    loaded = false;
  }

  @override
  Widget build(BuildContext context) {
    mainWidget = this;
    _pageControllerA = new PreloadPageController(initialPage: 0);
    _pageControllerB = new PreloadPageController(initialPage: 1);
    //
    if (!loaded) {
      if (likeRefresh) {
        likeRefresh = false;
        loaded = true;
      } else if (allLiked) {
        placesList.removeWhere(
            (place) => !place.usersLiked.contains(loggedInUser.uid));
        loaded = true;
      } else {
        placesList = [];
        getPlaces().then((places) {
          searchByName = false;
          if (places.isNotEmpty) {
            placesList = places;
            if (bestPlaces) {
              placesList
                  .sort((a, b) => b.likeNumber().compareTo(a.likeNumber()));
            }
            //ha név szerint keresnénk akkor azt vissza kell állítani utána
            placesList.forEach((place) {
              place.setPictures().whenComplete(() {
                if (placesList.length < 2 || (place == placesList.elementAt(1) &&
                    place.pictures.length == place.picNumber)) {
                  setState(() {
                    loaded = true;
                  });
                }
              });
            });
          } else {
            setState(() {
              loaded = true;
              placesList = [];
            });
          }
        });
      }
    }
    return WillPopScope(
      child: Scaffold(
        body: !loaded
            ? Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/images/loading.gif"),
                    fit: BoxFit.fitWidth,
                  ),
                  color: Colors.black,
                ),
              )
            : PreloadPageView.builder(
                physics: CustomScrollPhysics(),
                preloadPagesCount:
                    placesList.isNotEmpty ? placesList.length - 1 : 0,
                itemCount: placesList.isNotEmpty ? placesList.length : 1,
                controller: _pageControllerA,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int indexA) {
                  return PreloadPageView.builder(
                    preloadPagesCount: placesList.isNotEmpty
                        ? placesList[indexA.round()].picNumber - 2
                        : 0,
                    itemCount: placesList.isNotEmpty
                        ? placesList[indexA.round()].picNumber + 1
                        : 1,
                    controller: _pageControllerB,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int indexB) {
                      loaded = false;
                      if (placesList.isEmpty) {
                        indexA = 0;
                      }
                      if (indexB.round() == 0) {
                        isInitialPage = false;
                        return MenuWidget();
                      } else {
                        if (indexB.round() > 1)
                          isInitialPage = false;
                        else
                          isInitialPage = true;
                        return OnePictureWidget(
                          currentPlaceNumber: indexA.round(),
                          currentPictureId: indexB.round() - 1,
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
