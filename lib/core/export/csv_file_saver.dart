import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

Future<void> saveCsvFile({
  required String csv,
  required String filename,
}) async {
  final bytes = Uint8List.fromList(csv.codeUnits);

  if (kIsWeb) return;

  if (Platform.isAndroid) {
    await _saveOnAndroid(bytes, filename);
  } else if (Platform.isIOS) {
    await _shareOnIOS(bytes, filename);
  }
}

Future<void> _saveOnAndroid(Uint8List bytes, String filename) async {
  final directory = await getExternalStorageDirectory();

  if (directory == null) {
    throw Exception('External storage not available');
  }

  final file = File('${directory.path}/$filename');
  await file.writeAsBytes(bytes);
}

Future<void> _shareOnIOS(Uint8List bytes, String filename) async {
  final tempDir = await getTemporaryDirectory();
  final file = File('${tempDir.path}/$filename');

  await file.writeAsBytes(bytes);

  await Share.shareXFiles(
    [XFile(file.path, mimeType: 'text/csv')],
    text: 'Sales report',
  );
}
