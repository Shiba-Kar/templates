import 'package:nanoid/nanoid.dart';

const alphabet =
    '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ';

String nanoid = customAlphabet(alphabet, 6);

String generateShortCode() => nanoid;

void throwIfMissing(Map<String, String> obj, List<String> keys) {
  final missing = <String>[];
  for (var key in keys) {
    if (!obj.containsKey(key) || obj[key] == null) {
      missing.add(key);
    }
  }
  if (missing.isNotEmpty) {
    throw Exception('Missing required fields: ${missing.join(', ')}');
  }
}
