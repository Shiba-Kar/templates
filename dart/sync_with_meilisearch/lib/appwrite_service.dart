import 'dart:io';

import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:meilisearch/meilisearch.dart';

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

  Future syncDocuments(
    MeiliSearchIndex meiliSearchIndex,
    dynamic context,
  ) async {
    String? cursor;
    do {
      var queries = [Query.limit(100)];

      if (cursor != null) {
        queries.add(Query.cursorAfter(cursor));
      }

      var documents = await databases.listDocuments(
        databaseId: Platform.environment['APPWRITE_DATABASE_ID']!,
        collectionId: Platform.environment['APPWRITE_COLLECTION_ID']!,
        queries: queries,
      );

      if (documents.documents.isNotEmpty) {
        cursor = documents.documents[documents.documents.length - 1].$id;
      } else {
        context.log('No more documents found.');
        cursor = null;
        break;
      }

      context
          .log('Syncing chunk of ${documents.documents.length} documents ...');
      final doc = documents.documents.map((e) => e.toMap()).toList();
      await meiliSearchIndex.addDocuments(doc, primaryKey: '\$id');
    } while (cursor != null);
  }
}
