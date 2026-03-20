import 'package:flutter_easy_swagger_generator/helpers/imports.dart';

class ImportPath {
  final String actionName;

  ImportPath({
    required this.actionName,
  });

  String get entityFilePath {
    String actionName2 = actionName.toSnakeCase();

    return "domain/entities/${actionName2}_param.dart";
  }

  String get modelFilePath {
    String actionName2 = actionName.toSnakeCase();

    return "infrastructure/models/${actionName2}_model.dart".toSnakeCase();
  }
}
