import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:senior_citizen_app/models/relative.dart';
import 'package:senior_citizen_app/models/user.dart';
import 'package:senior_citizen_app/widgets/app_default.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_sms/flutter_sms.dart';

class LinkRelative extends StatefulWidget {
  @override
  _LinkRelativeState createState() => _LinkRelativeState();
}

class _LinkRelativeState extends State<LinkRelative> {
  String userId;
  UserProfile userProfile;
  bool relativesFound = false;
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
  void initState() {
    super.initState();
    getCurrentUser();
    userProfile = UserProfile(userId);
  }

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
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<Widget> relativeCards = List<Widget>();
              var data = snapshot.data.docs;
              if (data != null) {
                if (data.length > 0) relativesFound = true;
                userProfile.getAllRelatives(data);
                for (var relative in userProfile.relatives) {
                  relativeCards.add(LinkCard(
                    relative: relative,
                    userID: userId,
                    documentID: relative.documentID,
                    data: relative.toMap(),
                    recipients: [relative.phoneNumber],
                  ));
                }
                return ListView(
                  children: <Widget>[
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        'Link Relatives',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 25),
                      ),
                    ),
                    Column(
                      children: relativeCards,
                    ),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                          'Showing linked here does not mean that your accounts are linked . Please make sure that relative account is linked using the code sent . '),
                    )
                  ],
                );
              } else {
                relativesFound = false;
                return Center(
                  child: Text('No relative Added.'),
                );
              }
            } else
              return CircularProgressIndicator();
          }),
    );
  }
}

class LinkCard extends StatelessWidget {
  const LinkCard({
    Key key,
    @required this.relative,
    this.userID,
    this.documentID,
    this.data,
    this.recipients,
  }) : super(key: key);

  final Relative relative;
  final String userID, documentID;
  final Map<String, dynamic> data;

  final List<String> recipients;

  @override
  Widget build(BuildContext context) {
    String buttonText = 'Link';
    Color buttonColor = Colors.orangeAccent;
    bool linked = false;
    if (relative.uid == '' || relative.uid.isEmpty || relative.uid == null) {
      linked = false;
    } else {
      linked = true;
      buttonColor = Colors.green;
      buttonText = 'Linked';
    }
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      margin: EdgeInsets.all(8),
      child: ListTile(
        title: Text(relative.name),
        subtitle: Text(relative.phoneNumber),
        trailing: ElevatedButton.icon(
            onPressed: !linked
                ? () async {
                    data['uid'] = userID;

                    recipients.add(relative.phoneNumber);
                    await _sendSMS(
                        'Message from Saathi : Please copy the below code to link your account.\n'
                                'Code : ' +
                            userID,
                        recipients);
                    await FirebaseFirestore.instance
                        .collection('profile')
                        .doc(userID)
                        .collection('relatives')
                        .doc(documentID)
                        .update(data);
                  }
                : () async {
                    data['uid'] = '';
                    await FirebaseFirestore.instance
                        .collection('profile')
                        .doc(userID)
                        .collection('relatives')
                        .doc(documentID)
                        .update(data);
                  },
            style: ElevatedButton.styleFrom(
                primary: buttonColor,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                textStyle: TextStyle(color: Colors.white)),
            icon: Icon(Icons.person_add),
            label: Text(buttonText)),
      ),
    );
  }

  _sendSMS(String message, List<String> recipients) async {
    String _result = await sendSMS(message: message, recipients: recipients)
        .catchError((onError) {
      print(onError);
    });

    print(_result);
  }
}
