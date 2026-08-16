import 'dart:io';

void main() {
  var file = File('lib/config/app_colors.dart');
  var lines = file.readAsLinesSync();
  
  var properties = <String>[];
  var getters = <String>[];
  var overrides = <String>[];
  
  for (var line in lines) {
    if (line.contains('static const Color ')) {
      var match = RegExp(r'static const Color (\w+) = (.*);').firstMatch(line);
      if (match != null) {
        var name = match.group(1)!;
        var value = match.group(2)!;
        getters.add('  Color get \;');
        overrides.add('  @override\n  Color get \ => \;');
      }
    }
  }
  
  var configDir = Directory('lib/config/flavor_configuration');
  if (!configDir.existsSync()) {
    configDir.createSync(recursive: true);
  }
  
  var configDart = '''
import 'package:flutter/material.dart';

abstract class Configuration {
  ConfigurationColors get colors;
  Widget get splashScreen;
  String get appName;
  String get appLogo;
  String get baseUrl;
}

abstract class ConfigurationColors {
\
}
''';
  File('lib/config/flavor_configuration/configuration.dart').writeAsStringSync(configDart);
  
  var prodDart = '''
import 'package:flutter/material.dart';
import 'configuration.dart';

class MasarProProdConfig implements Configuration {
  @override
  String get appName => 'Masar Pro';

  @override
  String get appLogo => 'assets/logo.png';

  @override
  String get baseUrl => 'https://YOUR_API_BASE_URL/';

  @override
  Widget get splashScreen => const Scaffold(body: Center(child: Text('Masar Pro')));

  @override
  ConfigurationColors get colors => _MasarProProdColors();
}

class _MasarProProdColors implements ConfigurationColors {
\
}
''';
  File('lib/config/flavor_configuration/masar_pro_prod_config.dart').writeAsStringSync(prodDart);
  
  var devDart = '''
import 'package:flutter/material.dart';
import 'configuration.dart';

class MasarProDevConfig implements Configuration {
  @override
  String get appName => 'Masar Pro (Dev)';

  @override
  String get appLogo => 'assets/logo_dev.png';

  @override
  String get baseUrl => 'https://dev.api.example.com/';

  @override
  Widget get splashScreen => const Scaffold(body: Center(child: Text('Masar Pro Dev')));

  @override
  ConfigurationColors get colors => _MasarProDevColors();
}

class _MasarProDevColors implements ConfigurationColors {
\
}
''';
  File('lib/config/flavor_configuration/masar_pro_dev_config.dart').writeAsStringSync(devDart);
  
  print('Done generating flavors');
}
