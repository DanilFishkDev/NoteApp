import 'package:flutter/material.dart';
import 'globals.dart' as globals;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';

void main() async {
  await Hive.initFlutter();
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
        '/usrNotes': (context) => userNoteEnter(),
        '/register': (context) => toRegister(),
        '/login': (context) => toLogin(),
        '/userNoteEntry': (context) => userNoteCreate(),
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
                loginDialog(context);
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

loginDialog(BuildContext context) {
  Widget Register = TextButton(
    onPressed: () {
     Navigator.pushNamed(context, '/register');
    },
    child: Text('Sign Up'),
  );

  Widget Login = TextButton(
    onPressed: () {
      Navigator.pushNamed(context, '/login');
    },
    child: Text('Sign In'),
  );

  Widget alert = AlertDialog(
    title: Text('Welcome'),
    content: Column(
      children: <Widget>[
        Text('Welcome to NoteManager'),
        Text('If you are new create the account with sign up option'),
        Text('If you already have an account you can login with sign in option or'),
      ]
    ),
    actions: [
      Register,
      Login
    ]
  );

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return alert;
    }
  );
}

class toRegister extends StatefulWidget {
  @override
  _toRegisterState createState() => _toRegisterState();
}

class _toRegisterState extends State<toRegister> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Registration instance")),
      body: signUp(),
    );
  }
}


class signUp extends StatefulWidget {

  signUp({Key key}) : super(key: key);

  @override
  _signUpState createState() => _signUpState();
}

class _signUpState extends State<signUp> {

  final _formKey = GlobalKey<FormState>();

  String username;
  String pwd;
  List<String> userNotes = [];

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.account_box),
                    labelText: "Create your username for your new account",
                    hintText: "Enter your name",
                  ),
                  validator: (String value) {
                    username = value;
                    if(value.isEmpty) {
                      return "Please type the name";
                    }
                    return null;
                  }
              ),
              TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.account_box),
                    labelText: "Come up with your password",
                    hintText: "Type the password",
                  ),
                  validator: (String value) {
                    pwd = value;
                    if(value.isEmpty) {
                      return "Please type the name";
                    }
                    return null;
                  }
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_formKey.currentState.validate()) {
                        var user = await Hive.openBox(username);
                        user.put('name', username);
                        user.put('password', pwd);
                        user.put('notes', userNotes);
                        Navigator.pop(context);
                        Navigator.pop(context);
                      }
                    },
                    child: Text("Sign Up"),
                  )
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {

                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/');

                    },
                    child: Text("Back to main screen"),
                  )
              )
            ]
        )
    );
  }
}

class toLogin extends StatefulWidget {
  @override
  _toLoginState createState() => _toLoginState();
}

class _toLoginState extends State<toLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Logging in session")),
      body: login(),
    );
  }
}



class login extends StatefulWidget {

  login({Key key}) : super(key: key);

  @override
  _loginState createState() => _loginState();
}

class _loginState extends State<login> {

  final _formKey = GlobalKey<FormState>();

  String login;
  String pass;

  @override
  Widget build(BuildContext context) {
    return Form(
        key: _formKey,
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.account_box),
                    labelText: "Enter your username",
                    hintText: "Type your name that you entered in sign Up form",
                  ),
                  validator: (String value) {
                    login = value;
                    if(value.isEmpty) {
                      return "Please type the username";
                    }
                    return null;
                  }
              ),
              TextFormField(
                  decoration: const InputDecoration(
                    icon: Icon(Icons.account_box),
                    labelText: "Enter the password",
                    hintText: "Type the password related to your profile",
                  ),
                  validator: (String value) {
                    pass = value;
                    if(value.isEmpty) {
                      return "Please type password";
                    }
                    return null;
                  }
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: () async {
                      if(_formKey.currentState.validate()) {
                        var registered = await Hive.openBox(login);
                        var regName = registered.get('name');
                        if (regName == null) {
                          loginError(context);
                        } else {
                          var regPwd = registered.get('password');
                          if(regPwd == pass) {
                            void usernameSave() async {
                              final usrSave = await SharedPreferences.getInstance();
                              setState(() {
                                usrSave.setString('names', login);
                              });
                            };
                            usernameSave();
                            Navigator.pushNamed(context, '/usrNotes');
                          } else {
                            loginError(context);
                          }
                        }
                      }
                    },
                    child: Text("Sign In"),
                  )
              ),
              Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                  child: ElevatedButton(
                    onPressed: ()  {
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/');
                    },
                    child: Text("Back to main screen"),
                  )
              )
            ]
        )
    );
  }
}

loginError(BuildContext context) {
  Widget ret = TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: Text('Try again'),
  );
  Widget toReg = TextButton(
    onPressed: () {
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pop(context);
      Navigator.pushNamed(context, '/register');
    },
    child: Text('Sign Up'),
  );
  Widget alert = AlertDialog(
    title: Text('Whooooops!'),
    content: Column(
      children: <Widget>[
        Text('It seems to be that you'),
        Text('put the wrong username or'),
        Text('password.'),
        Text('Please make sure to check'),
        Text('your login data and sign in'),
        Text('Dont have an account?'),
        Text('Then you can go sign up'),
      ]
    ),
    actions: [
      ret,
      toReg
    ]
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      }
  );
}

class userNoteEnter extends StatefulWidget {
  @override
  _userNoteEnterState createState() => _userNoteEnterState();
}

class _userNoteEnterState extends State<userNoteEnter> {


  @override
  void initState() {
    super.initState();
    loadUserData();
  }

  void loadUserData() async {
    final usrSave = await SharedPreferences.getInstance();
    setState(() {
      globals.nickname = usrSave.getString('names') ?? 0;
    });
    globals.account = await Hive.openBox(globals.nickname);
    globals.userNotes = globals.account.get('notes');
  }

  var usrnam = globals.account.get('name');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("user Notes Handler"),
        ),

        body: ListView.builder(

            itemCount: globals.userNotes.length * 2,
            itemBuilder: (context, i) {
              if(globals.userNotes.length == null) {
                return null;
              } else {
                if (i.isOdd) return Divider();
                final index = i ~/ 2;
                return ListTile(
                    title: Text('${globals.userNotes[index]}'),
                    trailing: ElevatedButton(
                      onPressed: () {
                        void noteDeletion() async {

                          globals.userNotes.removeAt(index);
                          globals.account.put('notes', globals.userNotes);

                        }
                        noteDeletion();
                        Navigator.pop(context);
                        Navigator.pushNamed(context, '/');
                      },
                      child: const Icon(Icons.remove),
                    )
                );
              }

            }
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.pushNamed(context, '/userNoteEntry');
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
                      title: Text('Logout'),
                      onTap: () {
                        logoutDialog(context);
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

logoutDialog(BuildContext context) {
  Widget logout = TextButton(
    onPressed: () async {
      await globals.account.close();
      userDataRem() async {
        final usrSave = await SharedPreferences.getInstance();
          usrSave.setString('names', '');
          globals.nickname = '';
      };
      userDataRem();
      Navigator.pushNamed(context, '/');
    },
    child: Text('YES'),
  );
  Widget back = TextButton(
    onPressed: () {
      Navigator.pop(context);
    },
    child: Text('NO!'),
  );

  Widget alert = AlertDialog(
    title: Text('Leaving the account'),
    content: Column(
      children: <Widget>[
        Text('Are you sure to leave your account now?'),
        Text('You still can cancel this action by pressing the NO! button'),
      ]
    ),
    actions: [
      logout,
      back
    ]
  );

  showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      }
  );
}

class userNoteCreate extends StatefulWidget {
  @override
  _userNoteCreateState createState() => _userNoteCreateState();
}

class _userNoteCreateState extends State<userNoteCreate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Enter your note!")),
      body: usrNoteAdd(),
    );
  }
}

class usrNoteAdd extends StatefulWidget {

  usrNoteAdd({Key key}) : super(key: key);

  @override
  _usrNoteAddState createState() => _usrNoteAddState();
}

class _usrNoteAddState extends State<usrNoteAdd> {
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
                  labelText: "Enter the note, user",
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
                              globals.userNotes.add(note);
                              globals.account.put('notes', globals.userNotes);
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

