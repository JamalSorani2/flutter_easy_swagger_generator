import 'dart:io';

import '../../../../flutter_easy_swagger_generator.dart';
import '../../../../helpers/constants.dart';
import '../../../../helpers/create_folder.dart';
import '../../../../helpers/printer.dart';

class InputKeysGenerator {
  final String mainPath;

  InputKeysGenerator({
    required this.mainPath,
  });

  void generateInputKeys() {
    try {
      final List<String> formattedGroups = [];

      // Build formatted route strings grouped by category
      for (var key in inputKeys) {
        formattedGroups.add("  static const String $key = '$key';");
      }

      // Final Dart class content
      final generatedClass = '''
class InputKeys {
${formattedGroups.join(line)}
}
''';

      // Ensure output folder exists
      createFolder(mainPath);

      // Write to file
      final outputFile = File("$mainPath/input_keys.dart");
      outputFile.writeAsStringSync(generatedClass);
    } catch (e, s) {
      printError('Error while generating input keys: $e');
      printError(s.toString());
    }
  }
}
