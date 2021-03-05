import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:gpx/gpx.dart';
import 'package:image_picker/image_picker.dart';
import 'package:travel_app/api/placesController.dart';
import 'package:travel_app/entities/place.dart';
import 'package:travel_app/main.dart';

class AddPlaceWidget extends StatefulWidget {
  @override
  _AddPlaceWidgetState createState() => _AddPlaceWidgetState();
}

class _AddPlaceWidgetState extends State<AddPlaceWidget> {
  final nameController = TextEditingController();
  final lengthController = TextEditingController();
  final hoursController = TextEditingController();
  final minutesController = TextEditingController();
  final levelDiffController = TextEditingController();
  List<Image> imagesList;
  List<File> imageFilesList;
  File file;

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
          itemCount: imagesList.length + 6,
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
                leading: Icon(Icons.text_format_rounded),
                title: Row(children: [
                  Text("Szintkülönbség:"),
                  SizedBox(width: 5),
                  Flexible(
                    child: TextField(
                      style: TextStyle(color: Colors.black),
                      controller: levelDiffController,
                      cursorColor: Colors.black,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 5),
                  Text("m"),
                ]),
              );
            } else if (index == 2) {
              return ListTile(
                leading: Icon(Icons.edit_road_outlined),
                title: Row(
                  children: [
                    Text("A túra hossza:"),
                    SizedBox(width: 5),
                    Flexible(
                      child: TextField(
                        style: TextStyle(color: Colors.black),
                        controller: lengthController,
                        cursorColor: Colors.black,
                        keyboardType: TextInputType.number,
                      ),
                    ),
                    SizedBox(width: 5),
                    Text("km"),
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
            } else if (index == 3) {
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
            } else if (index == 4) {
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
            } else if (index < imagesList.length + 5) {
              return Container(
                padding: EdgeInsets.all(10),
                height: 200,
                alignment: Alignment.centerLeft,
                child: imagesList.elementAt(index - 5),
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
      imageQuality: 70,
    );

    setState(() {
      if (_image.path.endsWith('.jpg')) {
        imageFilesList.add(_image);
        imagesList.add(Image.file(
          _image,
          fit: BoxFit.fitHeight,
        ));
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
    Gpx gpxFile = GpxReader().fromString(file.readAsStringSync());
    double x = gpxFile.trks.first.trksegs.first.trkpts.first.lat;
    double y = gpxFile.trks.first.trksegs.first.trkpts.first.lon;
    Place place = new Place(
        nameController.text,
        imagesList.length,
        x,
        y,
        loggedInUser.uid,
        double.parse(lengthController.text),
        int.parse(hoursController.text),
        int.parse(minutesController.text),
        int.parse(levelDiffController.text));
    place.setId(savePlace(place));

    var dbRef = FirebaseStorage.instance.ref(place.id.path + '/');
    for (int i = 0; i < imageFilesList.length; i++) {
      File image = imageFilesList.elementAt(i);
      await dbRef.child(i.toString() + '.jpg').putFile(image);
    }

    await dbRef.child('place.gpx').putFile(file);

    Navigator.of(context).pop();
  }

  @override
  void dispose() {
    nameController.dispose();
    lengthController.dispose();
    hoursController.dispose();
    minutesController.dispose();
    levelDiffController.dispose();
    super.dispose();
  }
}
