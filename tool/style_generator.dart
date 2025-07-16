import 'dart:convert';
import 'dart:async';
import 'package:build/build.dart';
import 'package:path/path.dart' as path;

class StyleTokenGeneratorBuilder implements Builder {
  @override
  final buildExtensions = const {
    '.json': ['.style.g.dart'],
  };

  @override
  Future<void> build(BuildStep buildStep) async {
    if (!buildStep.inputId.path.contains("tokens")) return;

    final inputId = buildStep.inputId;
    final content = await buildStep.readAsString(inputId);
    final Map<String, dynamic> json = jsonDecode(content);

    final buffer = StringBuffer();
    buffer.writeln('// GENERATED CODE - DO NOT MODIFY BY HAND');
    buffer.writeln('');
    buffer.writeln("import 'dart:ui';");
    buffer.writeln('');
    buffer.writeln('class DesignTokens {');
    buffer.writeln('  const DesignTokens._();');

    if (json.containsKey("global")) {
      final global = json["global"] as Map<String, dynamic>;

      for (final entry in global.entries) {
        final rawKey = entry.key;
        final valueObj = entry.value;

        if (valueObj is Map<String, dynamic> && valueObj.containsKey("value")) {
          final value = valueObj["value"];
          final type = valueObj["type"];
          final key = _toLowerCamelCase(rawKey);

          if (type == "color") {
            final hex = value.toString().replaceAll("#", "");
            final formattedHex = _formatHexToColor(hex);
            buffer.writeln('  static const Color $key = Color(0x$formattedHex);');
          } else if (type == "dimension" || type == "sizing") {
            final cleaned = value.toString().replaceAll("px", "");
            final doubleValue = double.tryParse(cleaned);
            if (doubleValue != null) {
              buffer.writeln('  static const double $key = $doubleValue;');
            } else {
              buffer.writeln('  static const String $key = \'$value\';');
            }
          } else {
            buffer.writeln('  static const String $key = \'$value\';');
          }
        }
      }
    }

    buffer.writeln('}');

    final outputId = buildStep.inputId.changeExtension('.style.g.dart');

    await buildStep.writeAsString(outputId, buffer.toString());
  }

  String _formatHexToColor(String hex) {
    if (hex.length == 6) return 'FF$hex';
    if (hex.length == 8) return hex.toUpperCase(); // already ARGB
    if (hex.length == 3) return 'FF${hex}FFF';
    return 'FF000000'; // default to black
  }

  /// Converts snake_case or camelCase or PascalCase to lowerCamelCase
  String _toLowerCamelCase(String input) {
    final parts = input.split(RegExp(r'[_\s\-]'));
    if (parts.length == 1) return input[0].toLowerCase() + input.substring(1);

    return parts.first.toLowerCase() +
        parts.skip(1).map((p) => '${p[0].toUpperCase()}${p.substring(1)}').join();
  }
}
