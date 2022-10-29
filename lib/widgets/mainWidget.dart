import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:preload_page_view/preload_page_view.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/helper/customScrollPhysics.dart';
import 'package:travel_app/main.dart';

import 'auth/loginWidget.dart';
import 'menuWidget.dart';
import 'onePictureWidget.dart';

late bool likeRefresh;
var mainWidget;
late String name;
late bool searchByName;
late bool notAnyPlaces;
late bool allLiked;
late bool bestPlaces;
int? maxRadius;
int? maxTime;
int? maxLength;
int? minRadius;
int? minTime;
int? minLength;
late bool bestOrNew;

class MainWidget extends StatefulWidget {
  @override
  _MainWidgetState createState() => _MainWidgetState();
}

class _MainWidgetState extends State<MainWidget> {
  late PreloadPageController _pageControllerA;
  late PreloadPageController _pageControllerB;
  late bool isInitialPage;

  @override
  void initState() {
    super.initState();
    isInitialPage = false;
    likeRefresh = false;
    mainWidget = this;
    searchByName = false;
    notAnyPlaces = false;
    allLiked = false;
    bestPlaces = true;
    maxRadius = 100;
    minRadius = 0;
    bestOrNew = false;
  }

  @override
  Widget build(BuildContext context) {
    _pageControllerA = new PreloadPageController(initialPage: 0);
    _pageControllerB = new PreloadPageController(initialPage: 1);
    if (!likeRefresh) {
      if (!notAnyPlaces) {
        if (!bestOrNew) placesList = null;
      } else {
        placesList!.clear();
      }
      if (!bestOrNew) {
        getPlaces().then((places) {
          if (places.isNotEmpty) {
            placesList = places;
            if (searchByName) {
              searchByName = false;
            } else {
              if (allLiked)
                placesList!.removeWhere(
                    (place) => !place.usersLiked.contains(loggedInUser.uid));
            }
            placesList!.forEach((place) {
              place.setPictures().whenComplete(() {
                if (placesList!.isEmpty ||
                    (((placesList!.length < 5 && place == placesList!.last) ||
                            place == placesList!.elementAt(5)) &&
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
              searchByName = false;
            });
          }
        });
      }
      else{
        if (bestPlaces)
          placesList!
              .sort((a, b) => b.likeNumber().compareTo(a.likeNumber()));
        else{
          placesList = placesList!.reversed.toList();
        }
        bestOrNew = false;
      }
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
            : PreloadPageView.builder(
                physics: CustomScrollPhysics(),
                preloadPagesCount:
                    placesList!.isNotEmpty ? placesList!.length - 1 : 0,
                itemCount: placesList!.isNotEmpty ? placesList!.length : 1,
                controller: _pageControllerA,
                scrollDirection: Axis.vertical,
                itemBuilder: (BuildContext context, int indexA) {
                  return PreloadPageView.builder(
                    preloadPagesCount: placesList!.isNotEmpty
                        ? placesList![indexA].picNumber - 2
                        : 0,
                    itemCount: placesList!.isNotEmpty
                        ? placesList![indexA].picNumber + 1
                        : 1,
                    controller: _pageControllerB,
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (BuildContext context, int indexB) {
                      if (placesList!.isEmpty) {
                        indexA = 0;
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
      showDialog(
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
                  ));
      return Future.value(false);
    }
  }

  @override
  void dispose() {
    _pageControllerA.dispose();
    _pageControllerB.dispose();
    super.dispose();
  }
}
