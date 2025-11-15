import 'dart:convert';
import 'dart:io';

// Simple checker to keep translations healthy:
// 1) Ensures all keys exist in all locale files
// 2) Reports .tr() usages that are missing in locales
// 3) Heuristically reports suspicious hardcoded Text literals
//
// Run:
// dart tool/check_translations.dart

Future<void> main() async {
  final repoRoot = Directory.current.path;
  final translationsDir =
      Directory('$repoRoot/assets/translations'); // project-relative
  final libDir = Directory('$repoRoot/lib');
  if (!translationsDir.existsSync()) {
    stderr.writeln('Translations directory not found: ${translationsDir.path}');
    exitCode = 1;
    return;
  }

  final localeFiles = translationsDir
      .listSync()
      .whereType<File>()
      .where((f) => f.path.endsWith('.json'))
      .toList();
  if (localeFiles.isEmpty) {
    stderr.writeln('No locale JSON files found in ${translationsDir.path}');
    exitCode = 1;
    return;
  }

  // Parse JSON maps
  final localeMaps = <String, Map<String, dynamic>>{};
  for (final file in localeFiles) {
    try {
      final content = await file.readAsString();
      final map = jsonDecode(content) as Map<String, dynamic>;
      localeMaps[file.uri.pathSegments.last] = map;
    } catch (e) {
      stderr.writeln('Failed to parse ${file.path}: $e');
      exitCode = 2;
      return;
    }
  }

  // 1) Key parity across locales
  final allKeys = <String>{};
  for (final map in localeMaps.values) {
    allKeys.addAll(map.keys);
  }
  final missingPerLocale = <String, List<String>>{};
  for (final entry in localeMaps.entries) {
    final missing = allKeys.difference(entry.value.keys.toSet()).toList()..sort();
    if (missing.isNotEmpty) {
      missingPerLocale[entry.key] = missing;
    }
  }

  // 2) Collect .tr() usages
  final trKeyRegex = RegExp(r"'([a-zA-Z0-9_\.]+)'\.tr\(");
  final usedKeys = <String>{};
  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      for (final match in trKeyRegex.allMatches(content)) {
        usedKeys.add(match.group(1)!);
      }
    }
  }
  final unusedPerLocale = <String, List<String>>{};
  for (final entry in localeMaps.entries) {
    final unused = entry.value.keys.where((k) => !usedKeys.contains(k)).toList()..sort();
    if (unused.isNotEmpty) {
      unusedPerLocale[entry.key] = unused;
    }
  }
  final missingInLocales = <String>[];
  for (final key in usedKeys) {
    for (final map in localeMaps.values) {
      if (!map.containsKey(key)) {
        missingInLocales.add(key);
        break;
      }
    }
  }
  missingInLocales.sort();

  // 3) Heuristic hardcoded Text literals
  // Looks for: Text('Something') or Text("Something") not followed by .tr()
  final hardcodedFindings = <String>[];
  final textLiteralRegex = RegExp(
    "Text\\(\\s*(['\"])((?!\\s*\\)\\.tr\\().+?)\\1\\s*\\)",
    dotAll: true,
  );
  await for (final entity in libDir.list(recursive: true, followLinks: false)) {
    if (entity is File && entity.path.endsWith('.dart')) {
      final content = await entity.readAsString();
      for (final match in textLiteralRegex.allMatches(content)) {
        final literal = match.group(2)?.trim() ?? '';
        // Skip obviously non-user-facing or tiny glyphs
        if (literal.isEmpty ||
            literal.length < 3 ||
            RegExp(r'^\{.*\}$').hasMatch(literal) ||
            RegExp(r'^[\.\,\:\;\-\(\)\[\]\{\}\+\=\>\<\!\?]+$').hasMatch(literal)) {
          continue;
        }
        final line = _lineNumberForOffset(content, match.start);
        hardcodedFindings.add('${entity.path}:$line -> "$literal"');
      }
    }
  }

  // Report
  stdout.writeln('== Translation Check Report ==');
  stdout.writeln('');

  if (missingPerLocale.isEmpty) {
    stdout.writeln('✓ Key parity: All locales have the same keys.');
  } else {
    stdout.writeln('! Key parity issues:');
    for (final entry in missingPerLocale.entries) {
      stdout.writeln('  - ${entry.key} is missing ${entry.value.length} keys');
      for (final k in entry.value.take(20)) {
        stdout.writeln('      • $k');
      }
      if (entry.value.length > 20) {
        stdout.writeln('      • ... and ${entry.value.length - 20} more');
      }
    }
  }
  stdout.writeln('');

  if (missingInLocales.isEmpty) {
    stdout.writeln('✓ Usage coverage: All .tr() keys exist in locales.');
  } else {
    stdout.writeln('! Missing keys referenced by .tr(): ${missingInLocales.length}');
    for (final k in missingInLocales.take(50)) {
      stdout.writeln('  - $k');
    }
    if (missingInLocales.length > 50) {
      stdout.writeln('  - ... and ${missingInLocales.length - 50} more');
    }
  }
  stdout.writeln('');

  if (unusedPerLocale.isEmpty) {
    stdout.writeln('✓ No unused keys found in locales.');
  } else {
    stdout.writeln('! Unused keys in locales:');
    for (final entry in unusedPerLocale.entries) {
      stdout.writeln('  - ${entry.key}: ${entry.value.length} unused keys');
      for (final k in entry.value.take(50)) {
        stdout.writeln('      • $k');
      }
      if (entry.value.length > 50) {
        stdout.writeln('      • ... and ${entry.value.length - 50} more');
      }
    }
  }
  stdout.writeln('');

  if (hardcodedFindings.isEmpty) {
    stdout.writeln('✓ No suspicious hardcoded Text literals found.');
  } else {
    stdout.writeln('! Suspicious hardcoded Text literals: ${hardcodedFindings.length}');
    for (final f in hardcodedFindings.take(50)) {
      stdout.writeln('  - $f');
    }
    if (hardcodedFindings.length > 50) {
      stdout.writeln('  - ... and ${hardcodedFindings.length - 50} more');
    }
  }
}

int _lineNumberForOffset(String content, int offset) {
  var line = 1;
  for (var i = 0; i < offset && i < content.length; i++) {
    if (content.codeUnitAt(i) == 10) line++;
  }
  return line;
}


