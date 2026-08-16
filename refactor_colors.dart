import 'dart:io';

void main() {
  var file = File('lib/config/app_colors.dart');
  var lines = file.readAsLinesSync();
  
  var newLines = <String>[];
  var hasImport = false;
  
  for (var line in lines) {
    if (line.contains('import ''package:flutter/material.dart'';')) {
      newLines.add(line);
      newLines.add("import '../injection/injection_container.dart';");
      newLines.add("import 'flavor_configuration/configuration.dart';");
      hasImport = true;
    } else if (line.contains('static const Color ')) {
      var match = RegExp(r'static const Color (\w+) = (.*);').firstMatch(line);
      if (match != null) {
        var name = match.group(1)!;
        newLines.add('  static Color get \ => locator<Configuration>().colors.\;');
      } else {
        newLines.add(line);
      }
    } else {
      newLines.add(line);
    }
  }
  
  file.writeAsStringSync(newLines.join('\n'));
  print('Updated app_colors.dart');
}
