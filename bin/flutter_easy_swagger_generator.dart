import 'package:flutter_easy_swagger_generator/flutter_easy_swagger_generator.dart';

void main(List<String> args) async {
  if (args.isEmpty) {
    print('❌ Missing Swagger file path.');
    print(
        'Usage: dart run flutter_easy_swagger_generator <path_to_swagger.json> [--prefixes=pre1,pre2] [--category=name]');
    return;
  }

  final swaggerPath = args.first;
  final optionalArgs = args.skip(1).toList();
  final prefixesToRemove = _parsePrefixesToRemove(optionalArgs);
  final category = _parseCategory(optionalArgs);

  await swaggerGenerator(
    swaggerPath,
    prefixesToRemove: prefixesToRemove.isEmpty ? null : prefixesToRemove,
    category: category,
  );
}

List<String> _parsePrefixesToRemove(List<String> args) {
  const prefixFlag = '--prefixes=';
  final raw = args.where((arg) => arg.startsWith(prefixFlag)).toList();
  if (raw.isEmpty) return [];

  return raw
      .expand(
        (arg) => arg
            .substring(prefixFlag.length)
            .split(',')
            .map((value) => value.trim())
            .where((value) => value.isNotEmpty),
      )
      .toSet()
      .toList();
}

String? _parseCategory(List<String> args) {
  const categoryFlag = '--category=';
  final categoryArg = args.cast<String?>().lastWhere(
        (arg) => arg?.startsWith(categoryFlag) ?? false,
        orElse: () => null,
      );
  if (categoryArg == null) return null;

  final value = categoryArg.substring(categoryFlag.length).trim();
  return value.isEmpty ? null : value;
}
