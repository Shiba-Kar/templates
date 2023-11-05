import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:dart_appwrite/models.dart';

class AppwriteService {
  late Client client;
  late Databases databases;
  AppwriteService() {
    client = Client()
      ..setEndpoint(Platform.environment['APPWRITE_ENDPOINT'] ??
          'https://cloud.appwrite.io/v1')
      ..setProject(Platform.environment['APPWRITE_FUNCTION_PROJECT_ID'])
      ..setKey(Platform.environment['APPWRITE_API_KEY']);

    databases = Databases(client);
  }

  Future<Document?> getURLEntry(String shortCode) async {
    try {
      var document = await databases.getDocument(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
        collectionId: Platform.environment['APPWRITE_COLLECTION_ID']!,
        documentId: shortCode,
      );

      return document;
    } on AppwriteException catch (err) {
      if (err.code != 404) rethrow;

      return null;
    }
  }

  Future<Document?> createURLEntry(String url, String shortCode) async {
    try {
      var document = await databases.createDocument(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
        collectionId: Platform.environment['APPWRITE_COLLECTION_ID']!,
        documentId: shortCode,
        data: {"url": url},
      );

      return document;
    } on AppwriteException catch (err) {
      if (err.code != 409) rethrow;
      return null;
    }
  }

  Future<bool> doesURLEntryDatabaseExist() async {
    try {
      await databases.get(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
      );
      return true;
    } on AppwriteException catch (err) {
      if (err.code != 404) rethrow;
      return false;
    }
  }

  Future setupURLEntryDatabase() async {
    try {
      await databases.create(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
        name: 'URL Shortener',
      );
    } on AppwriteException catch (err) {
      // If resource already exists, we can ignore the error
      if (err.code != 409) rethrow;
    }
    try {
      await databases.createCollection(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
        collectionId: Platform.environment['APPWRITE_COLLECTION_ID']!,
        name: 'URLs',
      );
    } on AppwriteException catch (err) {
      // If resource already exists, we can ignore the error
      if (err.code != 409) rethrow;
    }
    try {
      await databases.createUrlAttribute(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
        collectionId: Platform.environment['APPWRITE_COLLECTION_ID']!,
        key: 'url',
        xrequired: true,
      );
    } on AppwriteException catch (err) {
      // If resource already exists, we can ignore the error
      if (err.code != 409) rethrow;
    }
  }
}
