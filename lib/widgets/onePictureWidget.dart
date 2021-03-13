import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:like_button/like_button.dart';
import 'package:travel_app/main.dart';
import 'package:travel_app/widgets/mainWidget.dart';
import 'package:travel_app/widgets/picDataWidget.dart';

import 'auth/loginWidget.dart';

class OnePictureWidget extends StatefulWidget {
  final int currentPlaceNumber;
  final int currentPictureId;

  OnePictureWidget({this.currentPlaceNumber, this.currentPictureId});

  @override
  _OnePictureWidgetState createState() => _OnePictureWidgetState(
      currentPlaceNumber: currentPlaceNumber,
      currentPictureId: currentPictureId);
}

class _OnePictureWidgetState extends State<OnePictureWidget> {
  int currentPlaceNumber;
  int currentPictureId;
  LikeButton likeButton;

  _OnePictureWidgetState({this.currentPlaceNumber, this.currentPictureId});

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Column(
        children: [
          Flexible(
            child: Row(
              children: [
                Container(
                  width: 70,
                ),
                Container(
                  width: MediaQuery.of(context).size.width - 140,
                  alignment: Alignment.center,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      InkWell(
                        child: Text(
                          "Legjobbak",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: bestPlaces
                                ? FontWeight.bold
                                : FontWeight.normal,
                            fontSize: 20,
                          ),
                        ),
                        onTap: () {
                          if (!bestPlaces) {
                            mainWidget.setState(() {
                              bestPlaces = true;
                            });
                          }
                        },
                      ),
                      Text(
                        " | ",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                      InkWell(
                        child: Text(
                          "Újak",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: bestPlaces
                                ? FontWeight.normal
                                : FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                        onTap: () {
                          if (bestPlaces) {
                            mainWidget.setState(() {
                              bestPlaces = false;
                            });
                          }
                        },
                      ),
                    ],
                  ),
                ),
                Container(
                  alignment: Alignment.centerRight,
                  width: 70,
                  child: Container(
                    height: 50,
                    width: 50,
                    child: _allLikeButton(),
                  ),
                ),
              ],
            ),
            flex: 1,
          ),
          Flexible(
            child: InkWell(
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: (MediaQuery.of(context).size.height - 50) / 8 * 7,
              ),
              onLongPress: () {
                _picData(currentPlaceNumber);
              },
              onDoubleTap: () {
                onLikeButtonTapped(likeButton.isLiked);
              },
            ),
            flex: 7,
          ),
          Flexible(
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: (MediaQuery.of(context).size.height - 50) / 8,
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
              ),
              child: new Row(
                children: <Widget>[
                  new Container(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: new Text(
                        placesList[currentPlaceNumber].name,
                        style: TextStyle(fontSize: 30.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    width: MediaQuery.of(context).size.width / 5 * 4,
                  ),
                  new Container(
                    child: _likeButton(),
                    width: MediaQuery.of(context).size.width / 5,
                  ),
                ],
              ),
            ),
            flex: 1,
          ),
        ],
      ),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: placesList[currentPlaceNumber].pictures[currentPictureId],
              fit: BoxFit.cover),
          color: Colors.white),
    );
  }

  Future<bool> onLikeButtonTapped(bool isLiked) async {
    setState(() {
      placesList.elementAt(currentPlaceNumber).likePlace(loggedInUser);
      likeRefresh = true;
    });
    return !isLiked;
  }

  Widget _likeButton() {
    likeButton = new LikeButton(
      isLiked: placesList
          .elementAt(currentPlaceNumber)
          .usersLiked
          .contains(loggedInUser.uid),
      likeCount: placesList[currentPlaceNumber].likeNumber(),
      size: 30.0,
      circleColor:
          CircleColor(start: Color(0xFFF44336), end: Color(0xFFF44336)),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Color(0xFFF44336),
        dotSecondaryColor: Color(0xFFF44336),
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.favorite,
          color: isLiked ? Colors.red : Colors.white,
          size: 30.0,
        );
      },
      countBuilder: (int count, bool isLiked, String text) {
        var color = isLiked ? Colors.red : Colors.grey;
        Widget result;
        if (count == 0) {
          result = Text(
            "-",
            style: TextStyle(color: color),
          );
        } else
          result = Text(
            placesList[currentPlaceNumber].likeNumber().toString(),
            style: TextStyle(color: color),
          );
        return result;
      },
      onTap: onLikeButtonTapped,
    );
    return likeButton;
  }

  Future<bool> onAllLikeButtonTapped(bool isLiked) async {
    mainWidget.setState(() {
      allLiked = !allLiked;
    });
    return !isLiked;
  }

  Widget _allLikeButton() {
    likeButton = new LikeButton(
      isLiked: allLiked,
      size: 30.0,
      circleColor:
          CircleColor(start: Color(0xFFF44336), end: Color(0xFFF44336)),
      bubblesColor: BubblesColor(
        dotPrimaryColor: Color(0xFFF44336),
        dotSecondaryColor: Color(0xFFF44336),
      ),
      likeBuilder: (bool isLiked) {
        return Icon(
          Icons.favorite,
          color: isLiked ? Colors.red : Colors.white,
          size: 30.0,
        );
      },
      onTap: onAllLikeButtonTapped,
    );
    return likeButton;
  }

  void _picData(int currentPlaceNumber) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (BuildContext context) {
          return PicDataWidget(
            currentPlaceNumber: currentPlaceNumber,
          );
        },
      ),
    );
  }
}
