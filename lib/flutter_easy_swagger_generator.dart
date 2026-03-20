import 'dart:io';
import 'package:flutter_easy_swagger_generator/helpers/imports.dart';

import 'generator/presentation_generator/state/provider/provider_generator.dart';

Set<String> multiPartClasses = {};
Future<void> swaggerGenerator(
  String swaggerPath, {
  List<String>? prefixesToRemove,
}) async {
  multiPartClasses.clear();
  String mainPath = "lib/app";

  //********************* Check swagger file *******************************/
  if (!File(swaggerPath).existsSync()) {
    printError('Error: Swagger file not found at $swaggerPath');
    printInfo('Usage: dart run main.dart [path_to_swagger.json]');
    return;
  }

  if (prefixesToRemove != null) {
    ConstantsHelper.allPrefixesToRemove.addAll(prefixesToRemove);
  }

  //********************* Load swagger *******************************/
  String jsonString = File(swaggerPath).readAsStringSync();
  Map<String, dynamic> swaggerJson = jsonDecode(jsonString);
  OpenApiJSON openApiJSON = OpenApiJSON.fromJson(swaggerJson);
  Components components = openApiJSON.components;
  List<RouteInfo> routesInfo = openApiJSON.paths;

  //********************* Group routes by category *******************************/
  Map<String, List<RouteInfo>> groupedRoutes = {};
  for (var routeInfo in routesInfo) {
    String category = getCategory(routeInfo.fullRoute);
    groupedRoutes.putIfAbsent(category, () => []).add(routeInfo);
  }

  //********************* Generators Objects **********************/
  RoutesGenerator routesGenerator = RoutesGenerator(
    groupedRoutes: groupedRoutes,
    mainPath: mainPath,
  );

  EnumsGenerator enumsGenerator = EnumsGenerator(
    components: components,
    mainPath: mainPath,
  );
  String globalEnumsFileString = enumsGenerator.generateEnums();

  EntitiesGenerator entitiesGenerator = EntitiesGenerator(
    routesInfo: routesInfo,
    components: components,
    mainPath: mainPath,
    globalEnumsFileString: globalEnumsFileString,
  );

  ModelsGenerator responseModelsGenerator = ModelsGenerator(
    routesInfo: routesInfo,
    components: components,
    mainPath: mainPath,
    globalEnumsFileString: globalEnumsFileString,
  );

  RepositoryGenerator repositoryGenerator = RepositoryGenerator(
    groupedRoutes: groupedRoutes,
    mainPath: mainPath,
  );

  RemoteGenerator remoteGenerator = RemoteGenerator(
    groupedRoutes: groupedRoutes,
    mainPath: mainPath,
  );

  // Clean Architecture specific
  RepoImpGenerator repoImpGenerator = RepoImpGenerator(
    groupedRoutes: groupedRoutes,
    mainPath: mainPath,
  );

  // ApplicationGenerator applicationGenerator = ApplicationGenerator(
  //   groupedRoutes: groupedRoutes,
  //   mainPath: mainPath,
  // );

  //********************* State management generators **********************/
  BlocGenerator? blocGenerator;
  EventGenerator? eventGenerator;
  StateGenerator? stateGenerator;
  blocGenerator =
      BlocGenerator(groupedRoutes: groupedRoutes, mainPath: mainPath);
  eventGenerator =
      EventGenerator(groupedRoutes: groupedRoutes, mainPath: mainPath);
  stateGenerator =
      StateGenerator(groupedRoutes: groupedRoutes, mainPath: mainPath);
  ProviderGenerator providerGenerator = ProviderGenerator(
      routesInfo: routesInfo,
      components: components,
      mainPath: mainPath,
      globalEnumsFileString: globalEnumsFileString);
  //********************* Shared generators **********************/
  NetworkGenerator networkGenerator = NetworkGenerator(mainPath: mainPath);
  ResultBuilderGenerator resultBuilderGenerator =
      ResultBuilderGenerator(mainPath: mainPath);
  List<String> moduleList = getModuleNames(routesInfo);

  InjectionGenerator injectionGenerator = InjectionGenerator(
    mainPath: mainPath,
    moduleList: moduleList,
  );

  //********************* Generate shared code **********************/
  printInfo('\nGenerating code from swagger file: $swaggerPath');
  await Future.wait([
    Future(() => routesGenerator.generateRoutes()),
    Future(() => entitiesGenerator.generateEntities()),
    Future(() => providerGenerator.generateProvider()),
    Future(() => responseModelsGenerator.generateModels()),
    Future(() => networkGenerator.generateNetwork()),
    Future(() => resultBuilderGenerator.generateResultBuilder()),
    Future(() => injectionGenerator.generateInjection()),
  ]);

  //********************* Generate per category **********************/
  for (var category in groupedRoutes.keys) {
    repositoryGenerator.generateRepositoryForCategory(category);
    remoteGenerator.generateRemoteForCategory(category);
    repoImpGenerator.generateRepositoryForCategory(category);

    blocGenerator.generateBlocForCategory(category);
    eventGenerator.generateEventForCategory(category);
    stateGenerator.generateStateForCategory(category);
  }

  printSuccess('Code generation completed!\n');
}
