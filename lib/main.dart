// import 'package:flutter/material.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         // This is the theme of your application.
//         //
//         // Try running your application with "flutter run". You'll see the
//         // application has a blue toolbar. Then, without quitting the app, try
//         // changing the primarySwatch below to Colors.green and then invoke
//         // "hot reload" (press "r" in the console where you ran "flutter run",
//         // or simply save your changes to "hot reload" in a Flutter IDE).
//         // Notice that the counter didn't reset back to zero; the application
//         // is not restarted.
//         primarySwatch: Colors.blue,
//       ),
//       home: const MyHomePage(title: 'Flutter Demo Home Page'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   const MyHomePage({super.key, required this.title});

//   // This widget is the home page of your application. It is stateful, meaning
//   // that it has a State object (defined below) that contains fields that affect
//   // how it looks.

//   // This class is the configuration for the state. It holds the values (in this
//   // case the title) provided by the parent (in this case the App widget) and
//   // used by the build method of the State. Fields in a Widget subclass are
//   // always marked "final".

//   final String title;

//   @override
//   State<MyHomePage> createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   int _counter = 0;

//   void _incrementCounter() {
//     setState(() {
//       // This call to setState tells the Flutter framework that something has
//       // changed in this State, which causes it to rerun the build method below
//       // so that the display can reflect the updated values. If we changed
//       // _counter without calling setState(), then the build method would not be
//       // called again, and so nothing would appear to happen.
//       _counter++;
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     // This method is rerun every time setState is called, for instance as done
//     // by the _incrementCounter method above.
//     //
//     // The Flutter framework has been optimized to make rerunning build methods
//     // fast, so that you can just rebuild anything that needs updating rather
//     // than having to individually change instances of widgets.
//     return Scaffold(
//       appBar: AppBar(
//         // Here we take the value from the MyHomePage object that was created by
//         // the App.build method, and use it to set our appbar title.
//         title: Text(widget.title),
//       ),
//       body: Center(
//         // Center is a layout widget. It takes a single child and positions it
//         // in the middle of the parent.
//         child: Column(
//           // Column is also a layout widget. It takes a list of children and
//           // arranges them vertically. By default, it sizes itself to fit its
//           // children horizontally, and tries to be as tall as its parent.
//           //
//           // Invoke "debug painting" (press "p" in the console, choose the
//           // "Toggle Debug Paint" action from the Flutter Inspector in Android
//           // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
//           // to see the wireframe for each widget.
//           //
//           // Column has various properties to control how it sizes itself and
//           // how it positions its children. Here we use mainAxisAlignment to
//           // center the children vertically; the main axis here is the vertical
//           // axis because Columns are vertical (the cross axis would be
//           // horizontal).
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             const Text(
//               'You have pushed the button this many times:',
//             ),
//             Text(
//               '$_counter',
//               style: Theme.of(context).textTheme.headline4,
//             ),
//           ],
//         ),
//       ),
//       floatingActionButton: FloatingActionButton(
//         onPressed: _incrementCounter,
//         tooltip: 'Increment',
//         child: const Icon(Icons.add),
//       ), // This trailing comma makes auto-formatting nicer for build methods.
//     );
//   }
// }

import 'package:senior_citizen_app/models/appoinment.dart';
import 'package:senior_citizen_app/models/reminder.dart';
import 'package:senior_citizen_app/others/auth.dart';
import 'package:senior_citizen_app/resources/service_locator.dart';
import 'package:senior_citizen_app/screens/appointment_reminder/appointment_decision_screen.dart';
import 'package:senior_citizen_app/screens/appointment_reminder/appointment_detail_screen.dart';
import 'package:senior_citizen_app/screens/appointment_reminder/appointment_reminder_screen.dart';
import 'package:senior_citizen_app/screens/document/add_documents_screen.dart';
import 'package:senior_citizen_app/screens/document/view_documents_screen.dart';
import 'package:senior_citizen_app/screens/home/home_screen.dart';
import 'package:senior_citizen_app/screens/hospital/nearby_hospital_screen.dart';
import 'package:senior_citizen_app/screens/loading/loading_screen.dart';
import 'package:senior_citizen_app/screens/loading/onBoarding_screen.dart';
import 'package:senior_citizen_app/screens/login/initial_setup_screen.dart';
import 'package:senior_citizen_app/screens/login/login_screen.dart';
import 'package:senior_citizen_app/screens/medicine_reminder/medicine_reminder.dart';
import 'package:senior_citizen_app/screens/medicine_reminder/reminder_detail.dart';
import 'package:senior_citizen_app/screens/notes/note_home_screen.dart';
import 'package:senior_citizen_app/screens/pages/heart_rate_screen.dart';
import 'package:senior_citizen_app/screens/pages/image_label.dart';
import 'package:senior_citizen_app/screens/profile/profile_edit_screen.dart';
import 'package:senior_citizen_app/screens/profile/profile_screen.dart';
import 'package:senior_citizen_app/screens/relatives/contact_relatives_screen.dart';
import 'package:senior_citizen_app/screens/relatives/edit_relatives.dart';
import 'package:flutter/material.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:senior_citizen_app/others/notification_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

NotificationAppLaunchDetails notificationAppLaunchDetails;
NotificationService notificationService;
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  notificationService = NotificationService();
  notificationService.initialize();
  notificationAppLaunchDetails =
      await notificationService.notificationDetails();

  setupLocator();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FlutterDownloader.initialize(debug: false);
  runApp(ElderlyApp());
}

class ElderlyApp extends StatelessWidget {
  Reminder reminder;
  @override
  Widget build(BuildContext context) {
    precacheImage(AssetImage('lib/resources/images/loadingimage.jpg'), context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Saathi',
      initialRoute: LoadingScreen.id,
      routes: {
        HomeScreen.id: (context) => HomeScreen(),
        HeartRateScreen.id: (context) => HeartRateScreen(),
        ProfileScreen.id: (context) => ProfileScreen(),
        MedicineReminder.id: (context) => MedicineReminder(),
        LoadingScreen.id: (context) => LoadingScreen(
              auth: Auth(),
            ),
        ContactScreen.id: (context) => ContactScreen(),
        LoginScreen.id: (context) => LoginScreen(
              auth: Auth(),
            ),
        ProfileEdit.id: (context) => ProfileEdit(),
        NoteList.id: (context) => NoteList(),
        ReminderDetail.id: (context) => ReminderDetail(reminder, ''),
        NearbyHospitalScreen.id: (context) => NearbyHospitalScreen(),
        InitialSetupScreen.id: (context) => InitialSetupScreen(),
        EditRelativesScreen.id: (context) => EditRelativesScreen(''),
        AppoinmentReminder.id: (context) => AppoinmentReminder(),
        AppoinmentDetail.id: (context) => AppoinmentDetail(
              Appoinment('', '', '', '', 999999, false),
              '',
            ),
        ViewDocuments.id: (context) => ViewDocuments(),
        AddDocuments.id: (context) => AddDocuments(),
        ImageLabel.id: (context) => ImageLabel(),
        AppoinmentDecision.id: (context) =>
            AppoinmentDecision(Appoinment('', '', '', '', 999999, false)),
        OnBoardingScreen.id: (context) => OnBoardingScreen(),
      },
      theme: ThemeData(
          fontFamily: GoogleFonts.lato().fontFamily,
          scaffoldBackgroundColor: Colors.white,
          primaryColor: Colors.white,
          textTheme:
              TextTheme().apply(fontFamily: GoogleFonts.lato().fontFamily)),
    );
  }
}
