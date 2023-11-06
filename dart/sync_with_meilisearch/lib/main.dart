import 'dart:async';
import 'dart:io';
import 'package:meilisearch/meilisearch.dart';
import 'package:sync_with_meilisearch/appwrite_service.dart';

import 'utils.dart';

Future<dynamic> main(final context) async {
  throwIfMissing(Platform.environment, [
    'APPWRITE_API_KEY',
    'APPWRITE_DATABASE_ID',
    'APPWRITE_COLLECTION_ID',
    'MEILISEARCH_ENDPOINT',
    'MEILISEARCH_INDEX_NAME',
    'MEILISEARCH_ADMIN_API_KEY',
    'MEILISEARCH_SEARCH_API_KEY',
  ]);

  if (context.req.method == 'GET') {
    var html = interpolate(getStaticFile('index.html'), {
      "MEILISEARCH_ENDPOINT": Platform.environment['MEILISEARCH_ENDPOINT']!,
      "MEILISEARCH_INDEX_NAME": Platform.environment['MEILISEARCH_INDEX_NAME']!,
      "MEILISEARCH_SEARCH_API_KEY":
          Platform.environment['MEILISEARCH_SEARCH_API_KEY']!,
    });

    return context.res
        .send(html, 200, {'Content-Type': 'text/html; charset=utf-8'});
  }
  var meilisearch = MeiliSearchClient(
    Platform.environment['MEILISEARCH_ENDPOINT']!,
    Platform.environment['MEILISEARCH_ADMIN_API_KEY'],
  );
  var index =
      meilisearch.index(Platform.environment['MEILISEARCH_INDEX_NAME']!);
  final appwrite = AppwriteService();
  await appwrite.syncDocuments(index, context);
  context.log('Sync finished.');

  return context.res.send('Sync finished.', 200);
}
