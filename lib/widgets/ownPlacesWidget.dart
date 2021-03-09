import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/entities/place.dart';

List<Place> ownPlaces;

class OwnPlacesWidget extends StatefulWidget {
  @override
  _OwnPlacesWidgetState createState() => _OwnPlacesWidgetState();
}

class _OwnPlacesWidgetState extends State<OwnPlacesWidget> {
  var thisWidget;

  @override
  void initState() {
    getOwnPlaces().then((places) {
      setState(() {
        ownPlaces = places;
      });
    });
    super.initState();
    thisWidget = this;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ownPlaces == null
          ? Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/images/loading.gif"),
                  fit: BoxFit.fitWidth,
                ),
                color: Colors.black,
              ),
            )
          : Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: ownPlaces.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      leading: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () {
                          onDelete(index);
                        },
                      ),
                      title: Text(ownPlaces.elementAt(index).name),
                    );
                  },
                ),
                ElevatedButton(onPressed: onQuit, child: Text("Vissza")),
              ],
            ),
    );
  }

  void onQuit() {
    Navigator.of(context).pop();
  }

  void onDelete(int index) {
    showDialog(
        context: context,
        builder: (_) => new AlertDialog(
              content: new Text(
                  "Bitosan ki akarod törölni ezt a helyet? Ez a művelet nem vonható vissza!"),
              actions: [
                TextButton(
                  child: Text('Igen!'),
                  onPressed: () {
                    Navigator.of(context).pop();
                    ownPlaces.elementAt(index).id.remove().whenComplete(() {
                      FirebaseStorage.instance
                          .ref(ownPlaces.elementAt(index).id.path)
                          .listAll()
                          .asStream()
                          .forEach((element) {
                        element.items.forEach((el) {
                          el.delete();
                        });
                      }).whenComplete(() {
                        thisWidget.setState(() {
                          ownPlaces.removeAt(index);
                        });
                      });
                    });
                  },
                ),
                TextButton(
                  child: Text('Mégse'),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            ));
  }
}
