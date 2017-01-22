library manager;

import 'dart:async';

part 'code_completer.dart';
part 'completion_item.dart';
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

class Query {
  int columnCodepoint;

  int startCodepoint;

  int get codeLength => columnCodepoint - startCodepoint;

  bool forceSemantic;

  Query();

  void fromMap(Map map) {
    //TODO
  }

  factory Query.FromMap(Map map) {
    final query = new Query();
    query.fromMap(map);
    return query;
  }
}

class Manager {
  final Options options;

  final Map<String, CodeCompleter> _completers = {};

  final GeneralCodeCompleter generalCompleter;

  Manager(this.options) : generalCompleter = new GeneralCodeCompleter(options);

  Future shutdown() async {
    for (final CodeCompleter completer in _completers.values) {
      await completer.shutdown();
    }

    await generalCompleter.shutdown();
  }

  CodeCompleter findCompleter(List<String> fileTypes) {
    for (String fileType in fileTypes) {
      final CodeCompleter completer = _completers[fileType];
      if (completer is CodeCompleter) return completer;
    }
    return null;
  }

  bool isCompletionAvailableForFileType(final List<String> fileTypes) =>
      fileTypes.any((String fileType) => _completers.containsKey(fileType));

  bool isCompletionEnabledForFileType(final List<String> fileTypes) {
    if (options.disabledFileType.contains('*')) return false;
    return !fileTypes
        .any((String file) => options.disabledFileType.contains(file));
  }
}
