import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  NotificationService();

  FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin;
  String navigationActionId = 'id_3';

  void initialize() async {
    this.flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
    var android = AndroidInitializationSettings('@mipmap/ic_launcher');
    var ios = DarwinInitializationSettings(
        onDidReceiveLocalNotification: this.onDidReceiveLocalNotification);
    var initSetting = InitializationSettings(android: android, iOS: ios);
    await flutterLocalNotificationsPlugin.initialize(
      initSetting,
      onDidReceiveNotificationResponse:
          (NotificationResponse notificationResponse) {
        switch (notificationResponse.notificationResponseType) {
          case NotificationResponseType.selectedNotification:
            // selectNotificationStream.add(notificationResponse.payload);
            break;
          case NotificationResponseType.selectedNotificationAction:
            if (notificationResponse.actionId == navigationActionId) {
              // selectNotificationStream.add(notificationResponse.payload);
            }
            break;
        }
      },
      // onSelectNotification: this.onNotificationSelect
    );
  }

  showNotification(
      {@required int id,
      @required String title,
      @required String body,
      String ticker}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Saathi', 'Saathi System',
        channelDescription: 'The Saathi Application',
        importance: Importance.max,
        priority: Priority.high,
        ticker: ticker ?? 'ticker');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin
        .show(id, title, body, platformChannelSpecifics, payload: 'item x');
  }

  scheduleAppoinmentNotification(
      {@required int id,
      @required String title,
      @required String body,
      @required DateTime dateTime}) async {
    var scheduledNotificationDateTime = dateTime;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Saathi Appoinment', 'Saathi Appoinment Reminder',
        channelDescription: 'Saathi Appoinment Reminder Notification');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(id, title, body,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  scheduleNotification(
      {@required int id,
      @required String title,
      @required String body,
      @required DateTime dateTime}) async {
    var scheduledNotificationDateTime = dateTime;
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Saathi', 'Saathi System',
        channelDescription: 'Saathi Notification');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.schedule(id, title, body,
        scheduledNotificationDateTime, platformChannelSpecifics);
  }

  periodicNotification(
      {@required int id,
      @required String title,
      @required String body,
      @required DateTime dateTime}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeating channel id', 'repeating channel name',
        channelDescription: 'repeating description');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.periodicallyShow(0, 'repeating title',
        'repeating body', RepeatInterval.everyMinute, platformChannelSpecifics);
  }

  dailyNotification() async {
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'repeatDailyAtTime channel id', 'repeatDailyAtTime channel name',
        channelDescription: 'repeatDailyAtTime description');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        0,
        'show daily title',
        'Daily notification shown at approximately ',
        time,
        platformChannelSpecifics);
  }

  dailyMedicineNotification(
      {@required int id,
      @required String title,
      @required String body,
      @required Time time}) async {
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'Saathi Med', 'Saathi Medicine Reminder',
        channelDescription: 'Saathi Medicine Reminder Notification');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showDailyAtTime(
        id, title, body, time, platformChannelSpecifics);
  }

  weeklyNotification() async {
    var time = Time(10, 0, 0);
    var androidPlatformChannelSpecifics = AndroidNotificationDetails(
        'show weekly channel id', 'show weekly channel name',
        channelDescription: 'show weekly description');
    // var iOSPlatformChannelSpecifics = IOSNotificationDetails();
    var platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);
    await flutterLocalNotificationsPlugin.showWeeklyAtDayAndTime(
        0,
        'show weekly title',
        'Weekly notification shown on Monday at approximately',
        Day.monday,
        time,
        platformChannelSpecifics);
  }

  notificationDetails() async {
    var notificationAppLaunchDetails =
        await flutterLocalNotificationsPlugin.getNotificationAppLaunchDetails();
    print(notificationAppLaunchDetails.didNotificationLaunchApp);
    print(notificationAppLaunchDetails.notificationResponse);
    return notificationAppLaunchDetails;
  }

  Future onNotificationSelect(String payload) async {
    debugPrint("PAYLOAD : " + payload);

    return true;
  }

  Future onDidReceiveLocalNotification(
      int id, String title, String body, String payload) async {
//    didReceiveLocalNotificationSubject.add(ReceivedNotification(
//        id: id, title: title, body: body, payload: payload));
  }

  Future<void> deleteNotification(int id) async {
    flutterLocalNotificationsPlugin.cancel(id);
  }
}

class ReceivedNotification {
  final int id;
  final String title;
  final String body;
  final String payload;

  ReceivedNotification({
    @required this.id,
    @required this.title,
    @required this.body,
    @required this.payload,
  });
}
