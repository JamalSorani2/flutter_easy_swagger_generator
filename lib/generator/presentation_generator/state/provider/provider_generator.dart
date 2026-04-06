import 'dart:io';

import 'package:flutter_easy_swagger_generator/generator/class_content_generator/components_generator.dart';
import 'package:flutter_easy_swagger_generator/helpers/imports.dart';

import '../../../../flutter_easy_swagger_generator.dart';

class ProviderGenerator {
  final List<RouteInfo> routesInfo;

  final Components components;

  final String mainPath;

  final String globalEnumsFileString;

  ProviderGenerator({
    required this.routesInfo,
    required this.components,
    required this.globalEnumsFileString,
    required this.mainPath,
  });

  void generateProvider() {
    final classGenerator = ProviderClassGenerator(
      components: components,
      mainPath: mainPath,
      globalEnumsFileString: globalEnumsFileString,
    );
    for (var routeInfo in routesInfo) {
      classGenerator.generateProvider(routeInfo);
    }
  }
}

class ProviderClassGenerator {
  final Components components;

  final String mainPath;

  final String globalEnumsFileString;

  ProviderClassGenerator({
    required this.components,
    required this.mainPath,
    required this.globalEnumsFileString,
  });

  void generateProvider(RouteInfo routeInfo) {
    String endPoint = 'Provider';
    String routeName =
        getRouteName(routeInfo.fullRoute, routeInfo.httpMethod.name);
    String className = '$routeName$endPoint';

    String moduleName = getCategory(routeInfo.fullRoute);
    String filePath = FilePath(
      mainPath: mainPath,
      category: moduleName,
      routeName: routeName,
    ).providerFilePath;
    List<String> contents = [];

    String classContent = _generateClassContent(
      className: className,
      parameters: routeInfo.httpMethodInfo.parameters,
      requestBody: routeInfo.httpMethodInfo.requestBody,
      moduleName: moduleName,
      routeName: routeName,
    );
    contents.add(classContent);

    final file = File(filePath);
    file.parent.createSync(recursive: true);
    for (var content in contents) {
      file.writeAsStringSync(content);
    }
  }

  String _generateClassContent({
    required String className,
    required List<TParameter>? parameters,
    required TRequestBody? requestBody,
    List<GeneratedParameters>? subClassParameters,
    required String moduleName,
    required String routeName,
  }) {
    String generatedClassString = "";
    List<GeneratedParameters> generateParametars = [];
    final bool isMultiPart =
        requestBody?.content?.contentType == TContentType.multipartFormData;

    ParametarsGenerator.generatedSubClassesNames.clear();
    if (subClassParameters == null) {
      generateParametars = ParametarsGenerator.generateParametars(
        parameters: parameters,
        components: components,
      );
      final componentsGenerator = ComponentsGenerator(
        components: components,
        isForEntities: true,
      );

      generateParametars.addAll(
        componentsGenerator.generateComponents(
          content: requestBody?.content,
        ),
      );
    } else {
      generatedClassString = "$generatedClassString$line";
      generateParametars = subClassParameters;
    }
    final classSerializerGenerator = ClassSerializerGenerator(
      className: className,
      components: components,
    );

    // Generate class definition

    String generatedImportsString = classSerializerGenerator.generateImports(
      generateParametars,
      isMultiPart,
    );
    bool withFormGroup = false;
    String generatedFormGroupsString =
        """//! Form Groups=====================================================
  final form = FormGroup({
""";
    String generatedVariablesString =
        "//! Variables=====================================================$line";
    String generatedGettersString =
        "//! Getters=====================================================$line";
    String generatedSettersString =
        "//! Setters=====================================================$line";
    String generatedClearAllString =
        """//! Clear All=====================================================
  void clearAll() {
""";
    String initializerParametersString = "";
    String initializerBodyString = "";
    Set<String> varianlesNames = {};

    for (var parameter in generateParametars) {
      String variable = parameter.generatedVariable
          .replaceAll("final", "")
          .trim()
          .replaceAll("?", "");
      final parts = variable.trim().split(RegExp(r'\s+'));
      final type = parts[0];
      final variableName = parts[1].replaceAll(';', '');
      if (varianlesNames.contains(variableName)) {
        continue;
      }
      varianlesNames.add(variableName);
      if (parameter.fieldType == FieldType.textField) {
        generatedFormGroupsString +=
            "    InputKeys.$variableName: FormControl<$type>(),$line";
        inputKeys.add(variableName);
        withFormGroup = true;
      } else {
        generatedVariablesString += ("  $type? _$variableName;$line");

        generatedGettersString +=
            "  $type? get $variableName => _$variableName;$line";

        generatedSettersString +=
            """  void ${variableName}Setter($type? value) { 
    _$variableName = value;
    notifyListeners();
  }$line$line""";

        generatedClearAllString += "    _$variableName = null;$line";
      }
      initializerParametersString += " required $type? $variableName,";

      if (parameter.fieldType == FieldType.textField) {
        initializerBodyString +=
            "    form.control(InputKeys.$variableName).value = $variableName;$line";
      } else {
        initializerBodyString += "    _$variableName = $variableName;$line";
      }
      // String enumClassString = '';
      if (parameter.enumValues.isNotEmpty) {
        if (globalEnumsFileString.contains(parameter.subClassName)) {
          if (!generatedImportsString.contains(enumsImport)) {
            generatedImportsString += enumsImport;
          }
        } else {
          generatedImportsString +=
              "import '../../../${ImportPath(actionName: routeName).entityFilePath}';$line";
        }
      }

      if (parameter.subClassParameters != null &&
          parameter.enumValues.isEmpty) {
        if (globalEnumsFileString.contains(parameter.subClassName)) {
          if (!generatedImportsString.contains(enumsImport)) {
            generatedImportsString += enumsImport;
          }
        } else {
          String subClassName = parameter.subClassName;
          if (subClassName.startsWith("List")) {
            subClassName =
                subClassName.replaceAll("List<", "").replaceAll(">", "");
          }

          generatedImportsString +=
              "import '../../../${ImportPath(actionName: routeName).entityFilePath}';$line";
        }
      }
    }
    generatedImportsString += "import 'package:flutter/material.dart';$line";
    generatedImportsString =
        ClassGeneratorHelper.removeDuplicateImports(generatedImportsString);
    // final genereatedSubClasses =
    //     classSerializerGenerator.generateSubClasses(generatedSubClasses);
    generatedClearAllString +=
        """${withFormGroup ? "    form.reset();$line" : ""}    notifyListeners();
  }$line""";
    generatedFormGroupsString += "  });$line";
    if (initializerParametersString.isNotEmpty) {
      initializerParametersString = "{$initializerParametersString}";
    }
    String generatedInitializerString =
        """//! Initializer=====================================================
  void initialize($initializerParametersString) {
$initializerBodyString    notifyListeners();
  }$line""";
    if (withFormGroup) {
      generatedImportsString +=
          "import 'package:reactive_forms/reactive_forms.dart';$line";
      generatedImportsString += "import '../../../../input_keys.dart';$line";
    }
    generatedImportsString = generatedImportsString.replaceAll(
      "import 'package:dio/dio.dart';",
      "",
    );
    String result = """$generatedImportsString
class $className extends ChangeNotifier {
${withFormGroup ? generatedFormGroupsString : ""}
$generatedVariablesString
$generatedGettersString
$generatedSettersString$generatedInitializerString
$generatedClearAllString}
""";
    return result.trim() + line;
  }
}
