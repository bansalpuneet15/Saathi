import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:jitsi_meet/jitsi_meet.dart';
import 'package:senior_citizen_app/models/user.dart';
import 'package:senior_citizen_app/widgets/app_default.dart';
import 'package:http/http.dart' as http;
import 'package:senior_citizen_app/screens/home/home_screen.dart';
import 'package:flutter/material.dart';
// import 'package:jitsi_meet_wrapper/jitsi_meet_wrapper.dart
import 'package:jitsi_meet/jitsi_meeting_listener.dart';
import 'package:flutter_sms/flutter_sms.dart';

class VideoCall extends StatefulWidget {
  final String userID;

  const VideoCall({Key key, this.userID}) : super(key: key);
  @override
  _VideoCallState createState() => _VideoCallState();
}

class _VideoCallState extends State<VideoCall> {
  final serverText = TextEditingController();
  TextEditingController roomText;
  TextEditingController subjectText =
      TextEditingController(text: "Urgent Video Call");
  TextEditingController nameText = TextEditingController(text: "");
  TextEditingController emailText = TextEditingController(text: "");
  TextEditingController iosAppBarRGBAColor =
      TextEditingController(text: "#0080FF80"); //transparent blue
  var isAudioOnly = false;
  var isAudioMuted = false;
  var isVideoMuted = false;
  final List<String> recipients = [];
  String messageUrl;

  @override
  void initState() {
    super.initState();
    roomText = TextEditingController(text: widget.userID);
    JitsiMeet.addListener(JitsiMeetingListener(
        onConferenceWillJoin: _onConferenceWillJoin,
        onConferenceJoined: _onConferenceJoined,
        onConferenceTerminated: _onConferenceTerminated,
        onError: _onError));
  }

  @override
  void dispose() {
    super.dispose();
    serverText.dispose();
    roomText.dispose();
    subjectText.dispose();
    nameText.dispose();
    emailText.dispose();
    JitsiMeet.removeAllListeners();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ElderlyAppBar(),
      drawer: AppDrawer(),
      body: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('profile')
              .doc(widget.userID)
              .snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              UserProfile userProfile = UserProfile(widget.userID);
              print('snapshot ${snapshot.data.data()}');
              userProfile.setData(snapshot.data.data());
              roomText.value = TextEditingValue(text: userProfile.uid);
              nameText.value = TextEditingValue(text: userProfile.userName);
              emailText.value = TextEditingValue(text: userProfile.email);
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    CheckboxListTile(
                      title: Text("Audio Only"),
                      value: isAudioOnly,
                      onChanged: _onAudioOnlyChanged,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    CheckboxListTile(
                      title: Text("Audio Muted"),
                      value: isAudioMuted,
                      onChanged: _onAudioMutedChanged,
                    ),
                    SizedBox(
                      height: 16.0,
                    ),
                    CheckboxListTile(
                      title: Text("Video Muted"),
                      value: isVideoMuted,
                      onChanged: _onVideoMutedChanged,
                    ),
                    Divider(
                      height: 48.0,
                      thickness: 2.0,
                    ),
                    FutureBuilder(
                        future: FirebaseFirestore.instance
                            .collection('profile')
                            .doc(widget.userID)
                            .collection('relatives')
                            .get(),
                        builder: (context, snapshot) {
                          if (snapshot.hasData) {
                            print('hasdata ${snapshot.hasData}');
                            return SizedBox(
                              height: 64.0,
                              width: double.maxFinite,
                              child: ElevatedButton(
                                onPressed: () async {
                                  print("data ${snapshot.data.docs}");
                                  for (var data in snapshot.data.docs) {
                                    print('data1 ${data.data()}');
                                    if (data['uid'] != '') {
                                      print('number ${data['phoneNumber']}');
                                      recipients.add(data['phoneNumber']);
                                    }
                                  }
                                  print('Recipients ${recipients}');
                                  await _joinMeeting();
                                  for (var relative in recipients)
                                    sendSMS(relative);
                                },
                                child: Text(
                                  "Start now",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                              ),
                            );
                          } else
                            return SizedBox(
                              height: 64.0,
                              width: double.maxFinite,
                              child: ElevatedButton(
                                onPressed: () async {
                                  for (var data in snapshot.data.docs) {
                                    print('data1 ${data.data()}');
                                    if (data['uid'] != '') {
                                      print('number ${data['phoneNumber']}');
                                      recipients.add(data['phoneNumber']);
                                    }
                                  }
                                  print('Recipients ${recipients}');
                                  await _joinMeeting();
                                  for (var relative in recipients)
                                    sendSMS(relative);
                                },
                                child: Text(
                                  "Start now",
                                  style: TextStyle(color: Colors.white),
                                ),
                                style: ElevatedButton.styleFrom(
                                    primary: Colors.blue),
                              ),
                            );
                        }),
                    SizedBox(
                      height: 48.0,
                    ),
                  ],
                ),
              );
            } else
              return CircularProgressIndicator();
          }),
    );
  }

  _onAudioOnlyChanged(bool value) {
    setState(() {
      isAudioOnly = value;
    });
  }

  _onAudioMutedChanged(bool value) {
    setState(() {
      isAudioMuted = value;
    });
  }

  _onVideoMutedChanged(bool value) {
    setState(() {
      isVideoMuted = value;
    });
  }

  _joinMeeting() async {
    String serverUrl =
        serverText.text?.trim()?.isEmpty ?? "" ? null : serverText.text;
    try {
      var options = JitsiMeetingOptions()
        ..room = roomText.text
        ..serverURL = serverUrl
        ..subject = subjectText.text
        ..userDisplayName = nameText.text
        ..userEmail = emailText.text
        ..iosAppBarRGBAColor = iosAppBarRGBAColor.text
        ..audioOnly = isAudioOnly
        ..audioMuted = isAudioMuted
        ..videoMuted = isVideoMuted;

      debugPrint("Jitsi MeetingOptions: $options");
      await JitsiMeet.joinMeeting(options,
          listener: JitsiMeetingListener(onConferenceWillJoin: ({message}) {
            debugPrint("${options.room} will join with message: $message");
          }, onConferenceJoined: ({message}) {
            debugPrint("${options.room} joined with message: $message");
          }, onConferenceTerminated: ({message}) {
            debugPrint("${options.room} terminated with message: $message");
          }));
    } catch (error) {
      debugPrint("error: $error");
    }
  }

  void _onConferenceWillJoin({message}) {
    setState(() {
      messageUrl = message['url'];
    });
    debugPrint("_onConferenceWillJoin broad-casted with message: $message");
  }

  void _onConferenceJoined({message}) {
    debugPrint("_onConferenceJoined broad-casted with message: $message");
  }

  void _onConferenceTerminated({message}) {
    debugPrint("_onConferenceTerminated broad-casted with message: $message");
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
      return HomeScreen();
    }));
  }

  _onError(error) {
    debugPrint("_onError broadcasted: $error");
  }

  sendSMS(String number) async {
    var cred =
        'AC48c6cbf3c91252d89de30f89ca9c7bb4:bfa0212a38c0f62a6112788aba44ac6f';

    var bytes = utf8.encode(cred);

    var base64Str = base64.encode(bytes);
    print('number2: +91${number}');
    Uri url = Uri.parse(
        'https://api.twilio.com/2010-04-01/Accounts/AC48c6cbf3c91252d89de30f89ca9c7bb4/Messages.json');

    var response = await http.post(url, headers: {
      'Authorization': 'Basic $base64Str'
    }, body: {
      'From': '+16089252165',
      'To': '+91$number',
      'Body':
          'Open Saathi Sampark application and come in for urgent video call or Use the link: "https://meet.jit.si/${widget.userID}".'
    });

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  }
}
