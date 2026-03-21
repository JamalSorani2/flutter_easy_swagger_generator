import 'package:flutter_easy_swagger_generator/helpers/imports.dart';

/// Determines the Dart type information for a given Swagger schema.
///
/// - If [schema] is `null`, defaults to `dynamic`.
/// - If the schema is an array, resolves the type of the array items.
/// - If the schema has a `$ref`, resolves the referenced type from [components].
/// - Otherwise, falls back to mapping Swagger primitive types
///   (`string`, `integer`, `number`, `boolean`) to Dart types.
///
/// [isForEntities] controls whether the suffix `Param` (for entities)
/// or `Model` (for infrastructure models) is used when resolving class names.
///
/// Returns a [DartTypeInfo] containing:
/// - The Dart type/class name.
/// - The original schema.
/// - Whether the type was resolved from a `$ref`.
DartTypeInfo getDartType({
  required TProperty? schema,
  required Components components,
  required bool isForEntities,
  required String parameterName,
}) {
  if (schema == null) {
    return DartTypeInfo(
      className: 'dynamic',
      schema: null,
      fieldType: FieldType.textField,
    );
  }

  String endPoint = isForEntities ? 'Param' : 'Model';

  // Handle array types
  if (schema is ArrayProperty) {
    final itemType = getDartType(
      parameterName: parameterName,
      schema: schema.items,
      components: components,
      isForEntities: isForEntities,
    );
    final ref = schema.items?.ref;
    final refLast =
        ref?.split('/').last.split('.').last.toCamelCase().toPascalCase();
    return DartTypeInfo(
      className: 'List<${refLast ?? itemType.className}>',
      schema: schema.items,
      isSubclass: true,
      isEnum: itemType.isEnum,
      fieldType: itemType.fieldType,
    );
  }

  // Handle referenced schemas
  if (schema.ref != null) {
    final ref = schema.ref!.split('/').last;
    final refParts = ref.split('.');

    // Shared reference types
    return DartTypeInfo(
      className: refParts.last.toCamelCase().toPascalCase() + endPoint,
      schema: schema,
      isSubclass: true,
      fieldType: FieldType.textField,
    );
  }

  // Handle primitive Swagger types
  return _type(
    schema.type.name,
    schema,
    parameterName,
  );
}

/// Maps a Swagger primitive type string to its Dart equivalent.
///
/// - `"string"` → `String`
/// - `"integer"` → `int`
/// - `"number"` → `double`
/// - `"boolean"` → `bool`
/// - anything else → `dynamic`
DartTypeInfo _type(
  String? type,
  TProperty schema,
  String? enumName,
) {
  if (enumName != null && (schema.enumValues.isNotEmpty)) {
    return DartTypeInfo(
      className: "${enumName.toPascalCase()}GlobalEnum",
      schema: schema,
      isEnum: true,
      fieldType: FieldType.textField,
    );
  }
  switch (type) {
    case 'string':
      return DartTypeInfo(
          className: 'String', schema: schema, fieldType: FieldType.textField);
    case 'integer':
      return DartTypeInfo(
          className: 'int', schema: schema, fieldType: FieldType.textField);
    case 'number':
      return DartTypeInfo(
          className: 'num', schema: schema, fieldType: FieldType.textField);
    case 'boolean':
      return DartTypeInfo(
          className: 'bool', schema: schema, fieldType: FieldType.switchType);
    case 'file':
      return DartTypeInfo(
          className: 'File', schema: schema, fieldType: FieldType.file);
    case 'date':
      return DartTypeInfo(
          className: 'DateTime',
          schema: schema,
          fieldType: FieldType.textField);
    default:
      return DartTypeInfo(
          className: 'dynamic', schema: schema, fieldType: FieldType.textField);
  }
}

/// Represents type information derived from a Swagger schema.
///
/// - [className] is the resolved Dart type or class name.
/// - [schema] holds the original Swagger property.
/// - [isSubclass] indicates if the type was resolved from a `$ref`.
class DartTypeInfo {
  final String className;
  final TProperty? schema;
  final bool isSubclass;
  final bool isEnum;
  final FieldType fieldType;

  DartTypeInfo({
    required this.className,
    required this.schema,
    this.isSubclass = false,
    this.isEnum = false,
    required this.fieldType,
  });
}

enum FieldType {
  textField,
  switchType,
  file,
}
