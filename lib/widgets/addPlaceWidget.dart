import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpx/gpx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:popup_menu/popup_menu.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/entities/place.dart';
import 'package:travel_app/main.dart';
import 'package:travel_app/widgets/auth/loginWidget.dart';
import 'package:vector_math/vector_math.dart' as vm;

class AddPlaceWidget extends StatefulWidget {
  @override
  _AddPlaceWidgetState createState() => _AddPlaceWidgetState();
}

class _AddPlaceWidgetState extends State<AddPlaceWidget> {
  final nameController = TextEditingController();
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  List<Image> imagesList;
  List<File> imageFilesList;
  File file;
  int selectedItem;
  List<GlobalKey> btnKeys = [];

  @override
  void initState() {
    super.initState();
    imagesList = [];
    imageFilesList = [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
          itemCount: imagesList.length + 5,
          itemBuilder: (BuildContext context, int index) {
            if (index == 0) {
              return ListTile(
                leading: Icon(Icons.text_format_rounded),
                title: TextField(
                  style: TextStyle(color: Colors.black),
                  controller: nameController,
                  cursorColor: Colors.black,
                  decoration: InputDecoration(
                    hintText: 'Kirándulóhely neve',
                    hintStyle: TextStyle(color: Colors.black.withOpacity(0.5)),
                  ),
                ),
              );
            } else if (index == 1) {
              return ListTile(
                leading: Icon(Icons.edit_road_outlined),
                title: Row(
                  children: [
                    Text("A túra hossza:"),
                    SizedBox(width: 5),
                    Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: hoursController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text("óra"),
                    SizedBox(width: 5),
                    Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: minutesController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text("perc"),
                  ],
                ),
              );
            } else if (index == 2) {
              return ListTile(
                leading: Container(
                  child: InkWell(
                    child: Icon(
                      Icons.add_a_photo_sharp,
                    ),
                  ),
                ),
                title: Text("Kép hozzáadása"),
                onTap: addPicture,
              );
            } else if (index == 3) {
              return ListTile(
                leading: Container(
                  child: InkWell(
                    child: Icon(
                      Icons.add_location_sharp,
                    ),
                  ),
                ),
                title: Text(file == null
                    ? "File hozzáadása"
                    : file.path.split('/').last),
                onTap: addFile,
              );
            } else if (index < imagesList.length + 4) {
              return Container(
                padding: EdgeInsets.all(10),
                height: 200,
                alignment: Alignment.centerLeft,
                child: InkWell(
                  child: imagesList.elementAt(index - 4),
                  key: btnKeys.elementAt(index - 4),
                  onLongPress: () {
                    selectedItem = index - 4;
                    PopupMenu.context = context;
                    PopupMenu menu = PopupMenu(
                      items: [
                        MenuItem(
                            title: 'Törlés',
                            textStyle: TextStyle(fontSize: 20, color: Colors.white)),
                      ],
                      onClickMenu: onDeletePress,
                    );
                    menu.show(widgetKey: btnKeys.elementAt(selectedItem));
                  },
                ),
              );
            } else {
              return ElevatedButton(
                style: ButtonStyle(
                  backgroundColor:
                      MaterialStateProperty.all<Color>(Colors.blue.shade900),
                ),
                child: Text(
                  "Kirándulóhely mentése",
                  style: TextStyle(
                    color: Colors.white,
                  ),
                ),
                onPressed: onSavePress,
              );
            }
          }),
    );
  }

  Future<void> addPicture() async {
    File _image = await ImagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 0,
    );

    setState(() {
      if (_image.path.endsWith('.jpg')) {
        imageFilesList.add(_image);
        imagesList.add(Image.file(
          _image,
          fit: BoxFit.fitHeight,
        ));
        btnKeys.add(GlobalKey());
      } else {
        Fluttertoast.showToast(
            msg: "Nem megfelelő formátum! Jpg szükséges!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
      }
    });
  }

  Future<void> addFile() async {
    File selectedFile = await FilePicker.getFile();
    setState(() {
      if (selectedFile.path.endsWith('.gpx'))
        file = selectedFile;
      else
        Fluttertoast.showToast(
            msg: "Nem megfelelő formátum!",
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.CENTER,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0);
    });
  }

  Future<void> onSavePress() async {
    if(nameController.text.isEmpty
        || minutesController.text.isEmpty
        || hoursController.text.isEmpty
        || imagesList == null
        || file == null
        || imagesList.isEmpty
    ) {
      Fluttertoast.showToast(
          msg: "Minden mezőt töltsél ki!",
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 2,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0);
    }
    else{
      Gpx gpxFile = GpxReader().fromString(file.readAsStringSync());
      List<double> countParams = _countLength(gpxFile);
      double innerLength = countParams.first;
      int up = countParams[1].round();
      int down = countParams[2].round();
      double x = gpxFile.trks.first.trksegs.first.trkpts.first.lat;
      double y = gpxFile.trks.first.trksegs.first.trkpts.first.lon;
      Place place = new Place(
          nameController.text,
          imagesList.length,
          x,
          y,
          loggedInUser.uid,
          innerLength,
          int.parse(hoursController.text),
          int.parse(minutesController.text),
          up,
          down
      );
      place.setId(savePlace(place));

      var dbRef = FirebaseStorage.instance.ref(place.id.path + '/');
      for (int i = 0; i < imageFilesList.length; i++) {
        File image = imageFilesList.elementAt(i);
        await dbRef.child(i.toString() + '.jpg').putFile(image);
      }

      await dbRef.child('place.gpx').putFile(file);

      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    nameController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    super.dispose();
  }

  void onDeletePress(MenuItemProvider provider) {
    setState(() {
      imageFilesList.removeAt(selectedItem);
      imagesList.removeAt(selectedItem);
    });
  }
  
  List<double> _countLength(Gpx gpx){
    List<double> result = [];
    double innerLength = 0;
    double up = 0;
    double down = 0;
    for(int i = 0; i < gpx.trks.first.trksegs.first.trkpts.length; i++){
      if(i < gpx.trks.first.trksegs.first.trkpts.length - 1) {
        var element = gpx.trks.first.trksegs.first.trkpts.elementAt(i);
        var next = gpx.trks.first.trksegs.first.trkpts.elementAt(i + 1);
        innerLength += distance(element.lat, next.lat, element.lon, next.lon, element.ele, next.ele);
        double diff = next.ele - element.ele;
        if(diff < 0){
          down += diff;
        }
        else{
          up += diff;
        }
      }
    }
    result.add(double.parse((innerLength / 1000).toStringAsFixed(1)));
    result.add(up);
    result.add(down);
    return result;
  }

  double distance(double lat1, double lat2, double lon1,
      double lon2, double el1, double el2) {

    final int R = 6371; // Radius of the earth

    double latDistance = vm.radians(lat2 - lat1);
    double lonDistance = vm.radians(lon2 - lon1);
    double a = sin(latDistance / 2) * sin(latDistance / 2)
        + cos(vm.radians(lat1)) * cos(vm.radians(lat2))
            * sin(lonDistance / 2) * sin(lonDistance / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    double distance = R * c * 1000; // convert to meters

    double height = el1 - el2;

    distance = pow(distance, 2) + pow(height, 2);

    return sqrt(distance);
  }
}
