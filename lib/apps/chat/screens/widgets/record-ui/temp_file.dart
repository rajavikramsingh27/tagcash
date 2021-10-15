import 'dart:io';
import 'package:path/path.dart';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

/// Creates an path to a temporary file.
Future<String> tempFile({String suffix}) async {
  suffix ??= 'tmp';

  if (!suffix.startsWith('.')) {
    suffix = '.$suffix';
  }
  var uuid = Uuid();
  String path;
  if (!kIsWeb) {
    var tmpDir = await getTemporaryDirectory();
    path = '${join(tmpDir.path, uuid.v4())}$suffix';
    var parent = dirname(path);
    Directory(parent).createSync(recursive: true);
  } else {
    path = 'uuid.v4()}$suffix';
  }

  return path;
}