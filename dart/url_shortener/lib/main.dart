import 'dart:async';
import 'dart:io';

import 'package:url_shortener/utils.dart';

import 'appwrite_service.dart';

// This is your Appwrite function
// It's executed each time we get a request
Future<dynamic> main(final context) async {
  throwIfMissing(Platform.environment, [
    'APPWRITE_API_KEY',
    'APPWRITE_DATABASE_ID',
    'APPWRITE_COLLECTION_ID',
    'SHORT_BASE_URL',
  ]);

  var appwrite = AppwriteService();
  if (context.req.method == 'POST' &&
      context.req.headers['content-type'] == 'application/json') {
    try {
      throwIfMissing(context.req.body, ['url']);
      Uri.parse(context.req.body['url']);
    } catch (err) {
      context.error(err.toString());
      return context.res.send({"ok": false, "error": err.toString()}, 400);
    }

    var urlEntry =
        await appwrite.createURLEntry(context.req.body['url'], nanoid);
    context.log(urlEntry);
    if (urlEntry == null) {
      context.error('Failed to create url entry.');
      return context.res
          .json({"ok": false, "error": 'Failed to create url entry'}, 500);
    }

    return context.res.json({
      "short": Uri(host: Platform.environment['SHORT_BASE_URL']).toString(),
    });
  }

  String shortId = context.req.url.replaceAll(RegExp(r'^/|/$'), '');
  context.log('Fetching document from with ID: $shortId');

  try {
    var urlEntry = await appwrite.getURLEntry(shortId);
    if (urlEntry == null) {
      context.error('Invalid link.');
      return context.res.send('Invalid link.', 404);
    }

    return context.res.redirect(urlEntry.data['url']);
  } catch (err) {
    context.error(err.toString());
    return context.res.send({"ok": false, "error": err.toString()}, 400);
  }
}
