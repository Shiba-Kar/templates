import 'dart:async';
import 'dart:io';
import 'package:algoliasearch/algoliasearch.dart';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:sync_with_algolia/utils.dart';

import 'appwrite_service.dart';

// This is your Appwrite function
// It's executed each time we get a request
Future<dynamic> main(final context) async {
  throwIfMissing(Platform.environment, [
    'APPWRITE_API_KEY',
    'APPWRITE_DATABASE_ID',
    'APPWRITE_COLLECTION_ID',
    'ALGOLIA_APP_ID',
    'ALGOLIA_INDEX_ID',
    'ALGOLIA_ADMIN_API_KEY',
    'ALGOLIA_SEARCH_API_KEY',
  ]);
  if (context.req.method == 'GET') {
    var html = interpolate(getStaticFile('index.html'), {
      "ALGOLIA_APP_ID": Platform.environment["ALGOLIA_APP_ID"]!,
      "ALGOLIA_INDEX_ID": Platform.environment["ALGOLIA_INDEX_ID"]!,
      "ALGOLIA_SEARCH_API_KEY": Platform.environment["ALGOLIA_SEARCH_API_KEY"]!,
    });

    return context.res
        .send(html, 200, {'Content-Type': 'text/html; charset=utf-8'});
  }
  final client = SearchClient(
    appId: Platform.environment["ALGOLIA_APP_ID"]!,
    apiKey: Platform.environment["ALGOLIA_ADMIN_API_KEY"]!,
  );
  //Platform.environment["ALGOLIA_INDEX_ID"]!
  await client.searchIndex(
    request: SearchForHits(
      indexName: Platform.environment["ALGOLIA_INDEX_ID"]!,
    ),
  );
  AppwriteService appwriteService = AppwriteService();
  var docs = await appwriteService.iterateDocs();
  var records = docs.map((doc) {
    var id = doc.$id;
    var rest = Map.from(doc.data)..remove('\$id');
    return {...rest, 'objectID': id};
  }).toList();

  await client.saveObject(
    indexName: Platform.environment["ALGOLIA_INDEX_ID"]!,
    body: records,
  );
  context.log('Sync finished.');

  return context.res.send('Sync finished.', 200);
}
