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

  void backupFetch() async {
    final backup = await SharedPreferences.getInstance();
    globals.NoteList = backup.getStringList('storage') ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Notes Manager"),
      ),
      body: ListView.builder(
        itemCount: globals.NoteList.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text('${globals.NoteList[index]}')
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
                  onPressed: () async {
                    if(_formKey.currentState.validate()) {
                      globals.noteTile = note;
                      globals.NoteList.add(note);
                      final backup = await SharedPreferences.getInstance();
                      backup.setStringList('storage', globals.NoteList);
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

