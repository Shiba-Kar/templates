import 'dart:io';
import 'package:algoliasearch/algoliasearch.dart';
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

  Future<List<Document>> iterateDocs() async {
    String? cursor;
    List<Document> records = [];

    do {
      var queries = [Query.limit(100)];

      if (cursor != null) {
        queries.add(Query.cursorAfter(cursor));
      }

      var response = await databases.listDocuments(
        databaseId: Platform.environment["APPWRITE_DATABASE_ID"]!,
        collectionId: Platform.environment["APPWRITE_COLLECTION_ID"]!,
        queries: queries,
      );

      if (response.documents.isNotEmpty) {
        cursor = response.documents[response.documents.length - 1].$id;
      } else {
        cursor = null;
        // break;
      }

      records.addAll(response.documents);
    } while (cursor != null);
    return records;
  }
}
