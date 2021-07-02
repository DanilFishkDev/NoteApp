import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App Simplistic',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.deepOrange,
        // This makes the visual density adapt to the platform that you run
        // the app on. For desktop platforms, the controls will be smaller and
        // closer together (more dense) than on mobile platforms.
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => NoteCreator(),
        '/entry': (context) => NoteEnter(),
      }
    );
  }
}

class NoteCreator extends StatefulWidget {

  @override
  _NoteCreatorState createState() => _NoteCreatorState();
}

class _NoteCreatorState extends State<NoteCreator> {

  @override
  void initState() {
    super.initState();
    backupFetch();
  }

  void backupFetch() async {
    final backup = await SharedPreferences.getInstance();
    setState(() {
      globals.NoteList = backup.getStringList('storage') ?? 0;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes Manager"),
      ),
      body: ListView.builder(
        itemCount: globals.NoteList.length * 2,
        itemBuilder: (context, i) {
          if (i.isOdd) return Divider();
          final index = i ~/ 2;
          return ListTile(
            title: Text('${globals.NoteList[index]}'),
            trailing: ElevatedButton(
              onPressed: () {
                void noteDeletion() async {
                  final backup = await SharedPreferences.getInstance();
                  setState(() {
                    globals.NoteList.removeAt(index);
                    backup.setStringList('storage', globals.NoteList);
                  });
                }
                noteDeletion();
                Navigator.pop(context);
                Navigator.pushNamed(context, '/');
              },
              child: const Icon(Icons.remove),
            )
          );
        }
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
         Navigator.pushNamed(context, '/entry');
        },
        child: const Icon(Icons.assignment_sharp),
        backgroundColor: Colors.greenAccent,
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepOrangeAccent,
              ),
              child: Text('Menu'),
            ),
            ListTile(
              title: Text('Profile'),
              onTap: () {
                //alertDialog with options Sign Up and Sign In (if user not yet logged in) or
                //alertDielog with option Logout if user in account.
              }
            ),
            ListTile(
              title: Text('Save in file'),
              onTap: () {
                //saving notes in file (only with login working)
              }
            ),
            ListTile(
              title: Text('Clear the notes'),
              onTap: () {
                //remove the notes from app (with alertDialog for confirmation the action)
              }
            ),
            ListTile(
              title: Text('Options'),
              onTap: () {
                //new screen with options such as dark theme, fonts etc
              }
            )
          ]
        )
      )
    );
  }
}

class NoteEnter extends StatefulWidget {
  @override
  _NoteEnterState createState() => _NoteEnterState();
}

class _NoteEnterState extends State<NoteEnter> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter your note!")),
      body: noteEntry(),
    );
  }
}



class noteEntry extends StatefulWidget {

  noteEntry({Key key}) : super(key: key);

  @override
  _noteEntryState createState() => _noteEntryState();
}

class _noteEntryState extends State<noteEntry> {

  final _formKey = GlobalKey<FormState>();
  String note;


  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TextFormField(
            decoration: const InputDecoration(
              icon: Icon(Icons.assignment_outlined),
              labelText: "Enter the note",
            ),
            validator: (String value) {
              note = value;
              if(value.isEmpty) {
                return "Please type the note in order to add new note, else press the Back button";
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: () {
                    if(_formKey.currentState.validate()) {
                      globals.noteTile = note;
                      void dataSaving() async {
                        final backup = await SharedPreferences.getInstance();
                        setState(() {
                          globals.NoteList.add(note);
                          backup.setStringList('storage', globals.NoteList);
                        });
                      };
                      dataSaving();
                      Navigator.pop(context);
                      Navigator.pop(context);
                      Navigator.pushNamed(context, '/');
                    }
                  },
                  child: Text("Add"),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: ElevatedButton(
                    onPressed: () {
                        Navigator.pop(context);
                    },
                    child: Text('Back'),
                  )
                )
              ]
            )
          )
        ]
      )
    );
  }
}

