/// Represents a primitive schema property (e.g., string, integer, number, boolean).
/// Captures optional `format`, `enum` values, and `default` when present.
class PrimitiveProperty extends TProperty {
  PrimitiveProperty({
    required super.type,
    super.ref,
    required super.nullable,
    super.format,
    super.defaultValue,
    required super.enumValues,
    super.items,
  });

  factory PrimitiveProperty.fromJson(Map<String, dynamic> json) {
    late TPropertyType tPropertyType;
    if (json['format'] == "binary") {
      tPropertyType = TPropertyType.file;
    } else if (json['format']?.toString().contains("date") == true) {
      tPropertyType = TPropertyType.date;
    } else {
      tPropertyType = TPropertyType.values.firstWhere(
        (e) => e.name == (json['type'].toString()),
        orElse: () => TPropertyType.string,
      );
    }
    return PrimitiveProperty(
      type: tPropertyType,
      format: json['format'] as String?,
      enumValues: (json['enum'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
      defaultValue: json['default'],
      nullable: json['nullable'] ?? false,
    );
  }

  @override
  String toString() {
    return 'PrimitiveProperty(type: $type, format: $format, nullable: $nullable, defaultValue: $defaultValue, enumValues: $enumValues)';
  }
}

/// Represents an array schema property.
class ArrayProperty extends TProperty {
  ArrayProperty({
    super.items,
    super.ref,
    required super.nullable,
    super.format,
    super.defaultValue,
    required super.enumValues,
  }) : super(
          type: TPropertyType.arrayProperty,
        );

  factory ArrayProperty.fromJson(Map<String, dynamic> json) {
    return ArrayProperty(
      items: json['items'] == null
          ? null
          : TProperty.fromJson(json['items'] as Map<String, dynamic>),
      format: json['format'] as String?,
      defaultValue: json['default'],
      nullable: json['nullable'] ?? false,
      enumValues: (json['enum'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ArrayProperty(items: $items, nullable: $nullable, format: $format, defaultValue: $defaultValue, enumValues: $enumValues)';
  }
}

/// Represents a `$ref` schema that points to another component schema.
class RefProperty extends TProperty {
  RefProperty({
    super.ref,
    super.format,
    super.nullable = false,
    super.defaultValue,
    required super.enumValues,
    super.items,
  }) : super(
          type: TPropertyType.refProperty,
        );

  factory RefProperty.fromJson(Map<String, dynamic> json) {
    return RefProperty(
      ref: (json['\$ref'] as String?)?.replaceAll("#/components/schemas/", ""),
      format: json['format'] as String?,
      defaultValue: json['default'],
      nullable: json['nullable'] ?? false,
      enumValues: (json['enum'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'RefProperty(ref: $ref, nullable: $nullable, format: $format, defaultValue: $defaultValue, enumValues: $enumValues)';
  }
}

/// Represents an object schema property with nested properties.
class ObjectProperty extends TProperty {
  final List<PropertyNameAndSchema> properties;
  final dynamic additionalProperties;

  ObjectProperty({
    required this.properties,
    this.additionalProperties,
    super.ref,
    required super.nullable,
    super.format,
    super.defaultValue,
    required super.enumValues,
    super.items,
  }) : super(
          type: TPropertyType.objectProperty,
        );

  factory ObjectProperty.fromJson(Map<String, dynamic> json) {
    List<PropertyNameAndSchema> properties = [];
    if (json['properties'] != null &&
        json['properties'] is Map<String, dynamic>) {
      (json['properties'] as Map<String, dynamic>).forEach((key, value) {
        properties.add(
          PropertyNameAndSchema(
            propertyName: key,
            schema: TProperty.fromJson(value),
          ),
        );
      });
    }

    return ObjectProperty(
      properties: properties,
      additionalProperties: json['additionalProperties'],
      format: json['format'] as String?,
      defaultValue: json['default'],
      nullable: json['nullable'] ?? false,
      enumValues: (json['enum'] as List<dynamic>? ?? [])
          .map((e) => e.toString())
          .toList(),
    );
  }

  @override
  String toString() {
    return 'ObjectProperty(properties: $properties, additionalProperties: $additionalProperties, nullable: $nullable, format: $format, defaultValue: $defaultValue, enumValues: $enumValues)';
  }
}

/// Base type for any schema property.
class TProperty {
  final TPropertyType type;
  final String? ref;
  final bool nullable;
  final String? format;
  final dynamic defaultValue;
  final List<String> enumValues;
  final TProperty? items;

  TProperty({
    required this.type,
    required this.ref,
    required this.nullable,
    required this.format,
    required this.defaultValue,
    required this.enumValues,
    required this.items,
  });

  factory TProperty.fromJson(Map<String, dynamic> json) {
    if (json['type'] == 'array') {
      return ArrayProperty.fromJson(json);
    } else if (json['type'] == 'object') {
      return ObjectProperty.fromJson(json);
    } else if (json['\$ref'] != null) {
      return RefProperty.fromJson(json);
    } else {
      return PrimitiveProperty.fromJson(json);
    }
  }

  @override
  String toString() {
    return 'TProperty(type: $type, ref: $ref, nullable: $nullable, format: $format, defaultValue: $defaultValue, enumValues: $enumValues, items: $items)';
  }
}

/// Pair of a property name and its parsed schema.
class PropertyNameAndSchema {
  final String propertyName;
  final TProperty schema;

  PropertyNameAndSchema({
    required this.propertyName,
    required this.schema,
  });

  @override
  String toString() {
    return '$propertyName: $schema';
  }
}

/// Enumeration of supported schema property kinds and primitive types.
enum TPropertyType {
  primitiveProperty,
  refProperty,
  objectProperty,
  arrayProperty,
  string,
  integer,
  number,
  boolean,
  file,
  date,
}
