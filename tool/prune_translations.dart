import 'dart:convert';
import 'dart:io';

// Prunes unused translation keys by comparing .tr() usages in lib/ against
// locale JSON files in assets/translations/.
//
// Usage:
//   dart tool/prune_translations.dart           # dry-run (shows what would change)
//   dart tool/prune_translations.dart --write   # writes pruned JSON (backs up originals)
//
// Notes:
// - Creates backups: <file>.backup before writing
// - Keeps keys used anywhere in lib/ via '<key>'.tr(

Future<void> main(List<String> args) async {
  final write = args.contains('--write');
  final repoRoot = Directory.current.path;
  final translationsDir = Directory('$repoRoot/assets/translations');
  final libDir = Directory('$repoRoot/lib');

  if (!translationsDir.existsSync()) {
    stderr.writeln('Translations directory not found: ${translationsDir.path}');
    exitCode = 1;
    return;
  }
  if (!libDir.existsSync()) {
    stderr.writeln('lib directory not found: ${libDir.path}');
    exitCode = 1;
    return;
  }

  // Collect used keys
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

  // Process each locale
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

  var totalRemoved = 0;
  for (final file in localeFiles) {
    final raw = await file.readAsString();
    final map = (jsonDecode(raw) as Map<String, dynamic>);
    final originalCount = map.length;

    // Build pruned map preserving insertion order
    final pruned = <String, dynamic>{};
    for (final key in map.keys) {
      if (usedKeys.contains(key)) {
        pruned[key] = map[key];
      }
    }
    final removedCount = originalCount - pruned.length;
    totalRemoved += removedCount;

    stdout.writeln(
        '${file.uri.pathSegments.last}: ${removedCount == 0 ? 'no removals' : 'removed $removedCount unused keys'} (kept ${pruned.length}/$originalCount)');

    if (write && removedCount > 0) {
      final backupPath = '${file.path}.backup';
      await File(file.path).copy(backupPath);
      final encoder = const JsonEncoder.withIndent('  ');
      await file.writeAsString('${encoder.convert(pruned)}\n');
      stdout.writeln('  -> wrote pruned file and created backup: $backupPath');
    } else if (!write && removedCount > 0) {
      stdout.writeln('  -> run with --write to apply these removals');
    }
  }

  stdout.writeln('');
  if (totalRemoved == 0) {
    stdout.writeln('✓ No unused keys to prune.');
  } else {
    stdout.writeln('Summary: $totalRemoved total unused keys across locales.');
  }
}


