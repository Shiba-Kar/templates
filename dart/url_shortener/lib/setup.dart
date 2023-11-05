import 'dart:developer';
import 'dart:io';

import 'package:url_shortener/appwrite_service.dart';
import 'package:url_shortener/utils.dart';

Future<dynamic> main() async {
  throwIfMissing(Platform.environment, [
    'APPWRITE_API_KEY',
    'APPWRITE_DATABASE_ID',
    'APPWRITE_COLLECTION_ID',
  ]);
  log('Executing setup script...');
  var appwrite = AppwriteService();
  if (await appwrite.doesURLEntryDatabaseExist()) {
    log('Database exists.');
    return;
  }

  await appwrite.setupURLEntryDatabase();
  log('Database created.');
}
