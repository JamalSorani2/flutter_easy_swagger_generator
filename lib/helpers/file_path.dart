import 'package:flutter_easy_swagger_generator/helpers/imports.dart';

class FilePath {
  final String mainPath;
  final String _category;
  final String? routeName;
  FilePath({
    required this.mainPath,
    required String category,
    this.routeName,
  }) : _category = category.toSnakeCase().toLowerCase();

  String get applicationFilePath {
    return '$mainPath/$_category/application/${_category}_facade.dart';
  }

  String get entityFilePath {
    return '$mainPath/$_category/${ImportPath(
      actionName: routeName!,
    ).entityFilePath}';
  }

  String get modelFilePath {
    return '$mainPath/$_category/${ImportPath(
      actionName: routeName!,
    ).modelFilePath}';
  }

  String get repositoryFilePath {
    final subPath = 'domain/repository';
    return '$mainPath/$_category/$subPath/${_category}_repository.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get remoteFilePath {
    final subPath = "infrastructure/datasource";
    return '$mainPath/$_category/$subPath/remote/${_category}_remote.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get repoImpFilePath {
    final subPath = "infrastructure/repo_imp";
    return '$mainPath/$_category/$subPath/${_category}_repo_imp.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get blocFilePath {
    return '$mainPath/$_category/presentation/state/bloc/${_category}_bloc.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get eventFilePath {
    return '$mainPath/$_category/presentation/state/bloc/${_category}_event.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get stateFilePath {
    return '$mainPath/$_category/presentation/state/bloc/${_category}_state.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get providerFilePath {
    final subPath = "presentation/state/provider";
    final nameComplement = "provider";
    return '$mainPath/$_category/$subPath/${_category}_$nameComplement.dart'
        .toSnakeCase()
        .toLowerCase();
  }

  String get riverpodFilePath {
    return '$mainPath/$_category/presentation/state/riverpod/${_category}_riverpod.dart'
        .toSnakeCase()
        .toLowerCase();
  }
}
