import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_citizen_app/models/tracker.dart';
import 'package:senior_citizen_app/screens/trackers/blood_pressure/blood_pressure_tracker_screen.dart';
import 'package:senior_citizen_app/widgets/app_default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AddBloodPressureScreen extends StatefulWidget {
  @override
  _AddBloodPressureScreenState createState() => _AddBloodPressureScreenState();
}

class _AddBloodPressureScreenState extends State<AddBloodPressureScreen> {
  final _trackerKey = GlobalKey<FormState>();
  TextEditingController diastolic, notes, systolic, pulse;
  BloodPressureTracker bloodPressureTracker;

  @override
  void initState() {
    bloodPressureTracker = BloodPressureTracker();
    diastolic = TextEditingController(text: '');
    systolic = TextEditingController(text: '');
    pulse = TextEditingController(text: '');
    notes = TextEditingController(text: '');
    super.initState();
    getCurrentUser();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: Container(
                margin: EdgeInsets.fromLTRB(20, 15, 20, 0),
                child: Text(
                  'Add Blood Pressure Data',
                  style: TextStyle(
                    fontSize: 28,
                    color: Color(0xff3d5afe),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 15,
            ),
            Form(
              key: _trackerKey,
              child: Column(
                children: <Widget>[
                  Container(
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: diastolic,
                      decoration: InputDecoration(
                        hintText: 'Diastolic in mm/Hg',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _trackerKey.currentState.validate();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter value';
                        } else {
                          if (!isNumeric(value)) {
                            return 'Enter numeric value';
                          }

                          return null;
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: systolic,
                      decoration: InputDecoration(
                        hintText: 'Systolic in mm/hg',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _trackerKey.currentState.validate();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter value';
                        } else {
                          if (!isNumeric(value)) {
                            return 'Enter numeric value';
                          }

                          return null;
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      keyboardType: TextInputType.number,
                      controller: pulse,
                      decoration: InputDecoration(
                        hintText: 'Pulse in bpm',
                        border: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _trackerKey.currentState.validate();
                      },
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter value';
                        } else {
                          if (!isNumeric(value)) {
                            return 'Enter numeric value';
                          }

                          return null;
                        }
                      },
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(15),
                    child: TextFormField(
                      onChanged: (v) {
                        _trackerKey.currentState.validate();
                      },
                      controller: notes,
                      decoration: InputDecoration(
                        hintText: 'Notes about Blood Pressure ',
                        border: OutlineInputBorder(),
                        disabledBorder: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(),
                        focusedBorder: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value.isEmpty) {
                          return 'Please enter value';
                        }

                        return null;
                      },
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: 15,
            ),
            ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                    primary: Color(0xff3d5afe),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                    textStyle: TextStyle(color: Colors.white)),
                onPressed: () async {
                  _trackerKey.currentState.validate();
                  await saveData();
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => BloodPressureTrackerScreen()));
                },
                icon: Icon(Icons.add),
                label: Text('Add Data')),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Recommended value .'),
            )
          ],
        ),
      ),
      appBar: ElderlyAppBar(),
      drawer: AppDrawer(),
    );
  }

  saveData() async {
    bloodPressureTracker.bloodPressure = BloodPressure(
        diastolic: int.parse(diastolic.text),
        systolic: int.parse(systolic.text),
        pulse: int.parse(pulse.text),
        notes: notes.text,
        dateTime: DateTime.now());
    await FirebaseFirestore.instance
        .collection('tracker')
        .doc(userId)
        .collection('blood_pressure')
        .add(bloodPressureTracker.toMap());
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

  String userId;
}

bool isNumeric(String s) {
  if (s == null) {
    return false;
  }
  return int.tryParse(s) != null;
}
