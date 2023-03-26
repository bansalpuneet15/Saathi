import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_citizen_app/models/relative.dart';
import 'package:senior_citizen_app/screens/relatives/relative_text_box.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:senior_citizen_app/widgets/app_default.dart';
import '../profile/profile_screen.dart';

class EditRelativesScreen extends StatefulWidget {
  static const String id = 'Edit_Relatives_Screen';
  final String documentID;
  EditRelativesScreen(this.documentID);
  @override
  _EditRelativesScreenState createState() => _EditRelativesScreenState();
}

class _EditRelativesScreenState extends State<EditRelativesScreen> {
  String userId;

  @override
  void initState() {
    getCurrentUser();
    super.initState();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: AppDrawer(),
      appBar: ElderlyAppBar(),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('profile')
              .doc(userId)
              .collection('relatives')
              .doc(widget.documentID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              Relative relative = Relative();
              relative = relative.getData(snapshot.data);
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.only(top: 25.0, bottom: 10),
                      child: Center(
                        child: Text(
                          'Edit Relatives Details',
                          style: TextStyle(fontSize: 30, color: Colors.amber),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: RelativeTextBox(
                          name: 'name',
                          value: relative.name,
                          title: 'Name ',
                          documentID: widget.documentID,
                        )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: RelativeTextBox(
                          name: 'email',
                          value: relative.email,
                          title: 'email address',
                          documentID: widget.documentID,
                        )),
                    Padding(
                        padding: const EdgeInsets.fromLTRB(8.0, 0, 0, 0),
                        child: RelativeTextBox(
                          name: 'phoneNumber',
                          value: relative.phoneNumber,
                          title: 'phone number',
                          documentID: widget.documentID,
                        )),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          padding: EdgeInsets.symmetric(
                              vertical: 12, horizontal: 40),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        ),
                        child: Text(
                          'Save Changes',
                          style: TextStyle(color: Colors.white),
                        )),
                  ],
                ),
              );
            } else {
              return SizedBox();
            }
          }),
    );
  }
}
