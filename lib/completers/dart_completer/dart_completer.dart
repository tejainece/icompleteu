library icu.completers.dart;

import 'dart:async';
import 'package:server/manager/manager.dart';
import 'package:server/api/models/models.dart';

class DartCompleter extends CodeCompleter {
  final Options options;

  DartCompleter(this.options);

  Set<String> getSupportedFileTypes() => new Set<String>.from(<String>['dart']);

  Future<List<CodeCompletionItem>> computeCandidatesInner(Query query) async {
    //TODO

    return [
      new CodeCompletionItem('hello1'),
      new CodeCompletionItem('hello2'),
      new CodeCompletionItem('hello3'),
      new CodeCompletionItem('hello4'),
    ];
  }

  Future<Null> shutdown() async {
    //TODO
  }
}
