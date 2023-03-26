import 'package:senior_citizen_app/models/note.dart';
import 'package:senior_citizen_app/others/database_helper.dart';
import 'package:senior_citizen_app/widgets/app_default.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
// import 'package:sweet_alert_dialogs/sweet_alert_dialogs.dart';

class NoteDetail extends StatefulWidget {
  static const String id = 'Note_Edit_Screen';
  final String appBarTitle;
  final Note note;

  NoteDetail(this.note, this.appBarTitle);

  @override
  State<StatefulWidget> createState() {
    return NoteDetailState(this.note, this.appBarTitle);
  }
}

class NoteDetailState extends State<NoteDetail> {
  DatabaseHelper helper = DatabaseHelper();

  String appBarTitle;
  Note note;
  bool isReminder = false;
  TextEditingController titleController;
  TextEditingController descriptionController;
  Color color = Colors.blue;
  Icon icon = Icon(Icons.add_alert);
  NoteDetailState(this.note, this.appBarTitle);

  @override
  initState() {
    titleController = TextEditingController(text: note.title);
    descriptionController = TextEditingController(text: note.description);
    _checkForReminder();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    TextStyle textStyle = Theme.of(context).textTheme.bodyText1;

    return WillPopScope(
        onWillPop: () async {
          // bool value = await _save();
          // return value;
          if (note !=
              Note(
                  titleController.text,
                  DateFormat.yMMMd().format(DateTime.now()),
                  DateFormat.yMMMd().format(DateTime.now()),
                  2,
                  descriptionController.text)) {
            return showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Note Not Saved"),
                    content: Text('Changes will be discarded '),
                    // alertType: RichAlertType.WARNING,
                    actions: <Widget>[
                      TextButton(
                        child: Text("OK"),
                        onPressed: () {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                      ),
                      TextButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.pop(context);
                        },
                      ),
                    ],
                  );
                });
          } else
            return true;
        },
        child: Scaffold(
          appBar: ElderlyAppBar(),
          drawer: AppDrawer(),
          bottomNavigationBar: Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: <Widget>[
                IconButton(
                  icon: Icon(
                    Icons.delete_outline,
                    color: Colors.red,
                  ),
                  onPressed: () {
                    setState(() {
                      _delete();
                    });
                  },
                ),
                Text(note.date),
                IconButton(
                  icon: icon,
                  color: color,
                  onPressed: () {
                    setState(() {
                      note.date = DateFormat.yMMMd()
                          .format(DateTime.now().add(Duration(days: 1)));
                    });
                  },
                ),
              ],
            ),
          ),
          body: Padding(
            padding:
                EdgeInsets.only(top: 10.0, left: 10.0, right: 10.0, bottom: 10),
            child: Material(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              elevation: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView(
                  children: <Widget>[
                    Padding(
                      padding: EdgeInsets.only(
                          left: 8, right: 8, top: 15.0, bottom: 0),
                      child: TextField(
                        controller: titleController,
                        style: textStyle.copyWith(fontSize: 21),
                        onChanged: (value) {
                          updateTitle();
                        },
                        decoration: InputDecoration(
                          hintText: 'Title',
                          labelStyle: textStyle.copyWith(fontSize: 21),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          left: 8, right: 8, top: 0, bottom: 15.0),
                      child: TextField(
                        controller: descriptionController,
                        style: textStyle.copyWith(fontSize: 18),
                        onChanged: (value) {
                          updateDescription();
                        },
                        minLines: 5,
                        maxLines: 10,
                        decoration: InputDecoration(
                          hintText: 'Note',
                          labelStyle: textStyle.copyWith(fontSize: 18),
                          border: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          disabledBorder: InputBorder.none,
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                          primary: Colors.green,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15)),
                          padding: EdgeInsets.symmetric(
                              horizontal: 40, vertical: 15),
                          textStyle: TextStyle(color: Colors.white)),
                      label: Text('Save'),
                      icon: Icon(Icons.save),
                      onPressed: () async {
                        setState(() {
                          note.title = titleController.text;
                          note.description = descriptionController.text;
                        });
                        _save();
                        // Navigator.pop(context, true);
                      },
                    )
                  ],
                ),
              ),
            ),
          ),
        ));
  }

  void moveToLastScreen() {
    Navigator.pop(context, true);
  }

  void updateTitle() {
    note.title = titleController.text;
  }

  void updateDescription() {
    note.description = descriptionController.text;
  }

  void _save() async {
    int result;
    // updateDescription();
    // updateTitle();
    if (note.title.isNotEmpty && note.description.isNotEmpty) {
      if (note.id != null) {
        result = await helper.updateNote(note);
      } else {
        note.date = DateFormat.yMMMd().format(DateTime.now());
        note.dateCreated = note.date;
        result = await helper.insertNote(note);
      }

      if (result != 0) {
        // showDialogBox('Note Saved ', note.title);
        _showAlertDialog('Status', 'Note Saved Successfully');
        //  await Navigator.push(context, MaterialPageRoute(builder: (context) {
        //    return MedicineReminder();
        //  }));

        Navigator.pop(context, true);
      } else {
        _showAlertDialog('Status', 'Problem Saving Note');
      }
      // moveToLastScreen();
    }
  }

  void _delete() async {
    if (note.id == null) {
      _showAlertDialog('Status', 'No Note was deleted');
      return;
    }

    int result = await helper.deleteNote(note.id);
    if (result != 0) {
      // showDialogBox('Deleted Successfully', note.title);
      _showAlertDialog('Status', 'Note Deleted Successfully');
      //  await Navigator.push(context, MaterialPageRoute(builder: (context) {
      //    return MedicineReminder();
      //  }));

      Navigator.pop(context);
    } else {
      _showAlertDialog('Status', 'Error Occurred while Deleting Note');
    }
    moveToLastScreen();
  }

  void _showAlertDialog(String title, String message) {
    AlertDialog alertDialog = AlertDialog(
      title: Text(title),
      content: Text(message),
    );
    showDialog(context: context, builder: (_) => alertDialog);
  }

  showDialogBox(String message, String noteName) {
    return showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(noteName),
            content: Text(message),
            // alertType: RichAlertType.SUCCESS,
            actions: <Widget>[
              ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.green,
                      textStyle: TextStyle(color: Colors.white)),
                  onPressed: () => Navigator.pop(context),
                  icon: Icon(Icons.chevron_right),
                  label: Text('Continue'))
            ],
          );
        });
  }

  @override
  void dispose() {
    titleController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  _checkForReminder() {
    setState(() {
      if (note.date == note.dateCreated) {
        icon = Icon(Icons.notifications_off);
        color = Colors.blue;
        isReminder = false;
      } else {
        color = Colors.green;
        icon = Icon(Icons.notification_important);
        isReminder = true;
      }
    });
    return isReminder;
  }
}
