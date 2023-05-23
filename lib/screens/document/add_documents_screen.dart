import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_citizen_app/screens/document/view_documents_screen.dart';
import 'package:senior_citizen_app/widgets/app_default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:senior_citizen_app/models/image.dart';

class AddDocuments extends StatefulWidget {
  static const String id = 'Add_Documents_Screen';
  @override
  _AddDocumentsState createState() => _AddDocumentsState();
}

class _AddDocumentsState extends State<AddDocuments> {
  TextEditingController nameController;
  bool imageLoaded, imageUploading;
  File _image;
  final picker = ImagePicker();
  String userId;
  Map<String, dynamic> allImages;
  ImageModel imageModel;
  @override
  void initState() {
    imageModel = ImageModel();
    nameController = TextEditingController();
    getCurrentUser();
    super.initState();
    imageLoaded = false;
    imageUploading = false;
    allImages = Map<String, dynamic>();
  }

  Future getImage(String method) async {
    var pickedFile;
    if (method == 'camera')
      pickedFile = await picker.getImage(source: ImageSource.camera);
    else
      pickedFile = await picker.getImage(source: ImageSource.gallery);

    setState(() {
      _image = File(pickedFile.path);
      imageLoaded = true;
    });
  }

  getAllImageData() async {
    var imageData = await FirebaseFirestore.instance
        .collection('documents')
        .doc(userId)
        .collection('file')
        .get();
    print('Image ${imageData.docs}');
    if (imageData.docs.length != 0) {
      setState(() {
        allImages = imageModel.getData(imageData.docs);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: ElderlyAppBar(),
      body: !imageUploading
          ? ListView(children: <Widget>[
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomCenter,
                children: <Widget>[
                  Container(
                    height: MediaQuery.of(context).size.height / 2.5,
                    decoration: BoxDecoration(
                      color: Color(0xff42495D),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        SizedBox(
                          height: 10,
                        ),
                        FaIcon(
                          FontAwesomeIcons.cloudUploadAlt,
                          color: Colors.white,
                          size: 90,
                        ),
                        Text(
                          'Upload Documents',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 25,
                              fontWeight: FontWeight.bold),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(
                            'Add your documents here and have them everywhere you go.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: -35,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await getImage('camera');
                      },
                      style: ElevatedButton.styleFrom(
                        padding:
                            EdgeInsets.symmetric(vertical: 20, horizontal: 35),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        primary: Colors.amber.shade700,
                      ),
                      icon: Icon(Icons.camera_alt, color: Colors.white),
                      label: Text(
                        'Use Camera',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 35,
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  'OR',
                  textAlign: TextAlign.center,
                ),
              ),
              GestureDetector(
                onTap: () async {
                  await getImage('gallery');
                },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Icon(
                      Icons.photo_library,
                      size: 40,
                      color: Colors.indigo,
                    ),
                    SizedBox(
                      width: 8,
                    ),
                    Text(
                      'Select from Gallery',
                      style: TextStyle(
                          color: Colors.indigo,
                          fontWeight: FontWeight.bold,
                          fontSize: 19),
                    )
                  ],
                ),
              ),
              SizedBox(
                height: 8,
              ),
              imageLoaded
                  ? Column(
                      children: <Widget>[
                        Padding(
                          padding: EdgeInsets.all(10.0),
                          child: TextField(
                            style: TextStyle(fontSize: 18),
                            decoration: InputDecoration(
                                contentPadding: EdgeInsets.all(5),
                                border: OutlineInputBorder(),
                                enabledBorder: OutlineInputBorder(),
                                focusedBorder: OutlineInputBorder(),
                                helperText: 'Document Name',
                                hintText: ' Add Name to search easily'),
                            controller: nameController,
                          ),
                        ),
                        ElevatedButton(
                          child: Text(
                            'Upload Image',
                            style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                          style: ElevatedButton.styleFrom(
                            padding: EdgeInsets.symmetric(
                                horizontal: 30, vertical: 15),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15)),
                            primary: Colors.green,
                          ),
                          onPressed: () async {
                            if (nameController.text.isEmpty)
                              nameController.value =
                                  TextEditingValue(text: 'Document');
                            await uploadFile(nameController.text);
                          },
                        ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 30.0),
                        child: Text(
                          'Add Image to start upload.',
                          style: TextStyle(fontSize: 22),
                        ),
                      ),
                    ),
            ])
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text('Uploading Document'),
                  ),
                ),
                Center(
                  child: CircularProgressIndicator(),
                )
              ],
            ),
    );
  }

  Future uploadFile(String name) async {
    setState(() {
      imageUploading = true;
    });
    await getAllImageData();
    if (!allImages.containsKey(name)) {
      String fileName = name, imageUrl;
      Reference reference =
          FirebaseStorage.instance.ref().child(userId + '/' + fileName);
      UploadTask uploadTask = reference.putFile(_image);
      TaskSnapshot storageTaskSnapshot =
          await uploadTask.whenComplete(() => null);
      storageTaskSnapshot.ref.getDownloadURL().then((downloadUrl) async {
        print('Url ${downloadUrl}');
        imageUrl = downloadUrl;
        await updateData(fileName, imageUrl);
        Navigator.pop(context);
      }, onError: (err) {
        showDialog(
            context: context,
            builder: (context) {
              return Dialog(
                child: Text('Upload Failed'),
                insetPadding: EdgeInsets.all(8),
              );
            });
      });
    } else {
      setState(() {
        imageUploading = false;
      });
      showDialog(
          context: context,
          builder: (context) {
            return Dialog(
              child: Text('Document with same name exists.'),
              insetPadding: EdgeInsets.all(8),
            );
          });
    }
  }

  final FirebaseAuth _auth = FirebaseAuth.instance;

  void getCurrentUser() {
    _auth.authStateChanges().listen((User user) {
      if (user == null) {
        print('No user is currently signed in.');
      } else {
        print('User ${user.uid} is currently signed in.');
        setState(() {
          userId = user.uid;
        });
      }
    });
  }
  // getCurrentUser() async {
  //   await FirebaseAuth.instance.currentUser().then((user) {
  //     setState(() {
  //       userId = user.uid;
  //     });
  //   });
  // }

  updateData(String name, String value) async {
    Map<String, dynamic> data = Map<String, dynamic>();
    data['name'] = name;
    data['url'] = value;
    await FirebaseFirestore.instance
        .collection('documents')
        .doc(userId)
        .collection('file')
        .add(data);
    setState(() {
      imageUploading = false;
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    super.dispose();
  }
}
