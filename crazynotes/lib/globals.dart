library crazynotes.globals;

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

String noteTile = '';

List<String> NoteList = [];

int signed = 0;

String nickname = '';

var account;
List<String> userNotes = [];
var encryptionKey;

final FlutterSecureStorage safeArea = const FlutterSecureStorage();
