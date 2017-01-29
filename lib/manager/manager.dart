library manager;

import 'dart:async';
import 'package:icu_server/api/models/models.dart';
import 'package:icu_server/filter_and_sort/filter_and_sort.dart';

part 'code_completer.dart';
part 'completion_cache.dart';
part 'general_completer.dart';

class Options {
  final List<String> disabledFileType = [];

  int minNumChars;

  String hmac;

  Options._();

  factory Options.FromMap(Map map) {
    Options options = new Options._();
    options.fromMap(map);
    return options;
  }

  void fromMap(Map map) {
    hmac = map['hmac_secret'];
  }
}

class Manager {
  final Options options;

  final Map<String, CodeCompleter> _completers;

  Map<String, CodeCompleter> get completers => _completers;

  final GeneralCodeCompleter generalCompleter;

  Manager(this.options, {Map<String, CodeCompleter> completers})
      : generalCompleter = new GeneralCodeCompleter(options),
        _completers = completers;

  Future shutdown() async {
    for (final CodeCompleter completer in _completers.values) {
      await completer.shutdown();
    }

    await generalCompleter.shutdown();
  }

  CodeCompleter findCompleter(Set<String> fileTypes) {
    for (String fileType in fileTypes) {
      final CodeCompleter completer = _completers[fileType];
      if (completer is CodeCompleter) return completer;
    }
    return null;
  }

  bool isCompletionAvailable(Set<String> fileTypes) =>
      fileTypes.any((String fileType) => _completers.containsKey(fileType));

  bool isCompletionEnabled(final Set<String> fileTypes) {
    if (options.disabledFileType.contains('*')) return false;
    return !fileTypes
        .any((String file) => options.disabledFileType.contains(file));
  }

  bool isCompletionUsable(final Set<String> fileTypes) =>
      isCompletionEnabled(fileTypes) && isCompletionAvailable(fileTypes);

  List<bool> shouldUseCompletion(Query query) {
    if (isCompletionUsable(query.fileTypes)) {
      if (query.forceSemanticCompletion) {
        return <bool>[true, true];
      } else {
        return <bool>[
          findCompleter(query.fileTypes).shouldUseNow(query),
          false
        ];
      }
    }

    return <bool>[false, false];
  }
}
