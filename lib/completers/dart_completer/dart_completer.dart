library icu.completers.dart;

import 'dart:io';
import 'dart:async';
import 'package:icu_server/manager/manager.dart';
import 'package:icu_server/api/models/models.dart';

import 'package:dart_analysis_client/dart_analysis_client.dart';

class DartCompleter extends CodeCompleter {
  final Options options;

  AnalysisServer _server;

  DartCompleter._(this.options, this._server) {}

  static Future<DartCompleter> make(Options options) async {
    Directory dir = new Directory(r'/usr/lib/dart');
    if (!dir.existsSync()) {
      throw new Exception("Dart SDK dir does not exist!");
    }
    final config = new AnalyzerConfig(dir);

    final server = new AnalysisServer(config);
    await server.start();

    return new DartCompleter._(options, server);
  }

  Set<String> getSupportedFileTypes() => new Set<String>.from(<String>['dart']);

  Future<List<CodeCompletionItem>> computeCandidatesInner(Query query) async {
    await _server.updateFileContentAdd(query.filePath, query.contents);
    GetSuggestionResult result =
        await _server.getSuggestions(query.filePath, query.offset - 1);

    return result.results.map((CompletionSuggestion sug) {
      String menuText = sug.completion;
      if (sug.element != null) {
        if(_isFunctionalKind(sug.element.kind)) {
          final Element el = sug.element;
          menuText += '${el.parameters} \u{2192} ${el.returnType}';
        } else if(sug.returnType != null) {
          menuText += ' \u{2192} ${sug.returnType}';
        } else {
          //Do nothing
        }
      } else {
        //Do nothing
      }
      return new CodeCompletionItem(
        sug.completion,
        menuText: menuText,
        kind: sug.element?.kind,
      );
    }).toList();
  }



  Future<Null> shutdown() async {
    await _server.kill();
  }

  @override
  Future<Null> onBufferVisit(Query query) async {
    await super.onBufferVisit(query);
    await _ensureFileInAnalysisServer(query.filePath);
  }

  @override
  Future<Null> onFileReadyToParse(Query query) async {
    await _ensureFileInAnalysisServer(query.filePath);
    await _server.updateFileContentAdd(
        query.filePath, query.fileData[query.filePath].contents);
    //TODO _GetErrorsResponseToDiagnostics
  }

  Future _ensureFileInAnalysisServer(String filename) async {
    Directory dir = new Directory(filename);
    if (await FileSystemEntity.isFile(filename)) {
      dir = new File(filename).parent;
    } else {
      dir = new Directory(filename);
    }

    //TODO if (!dir.existsSync()) return;

    await _server.setProjectRoots([dir.path]);
    await _server.setPriorityFiles([filename]);
  }
}

bool _isFunctionalKind(String kind) {
  if (kind == 'METHOD') return true;
  if (kind == 'FUNCTION') return true;
  if (kind == 'CONSTRUCTOR') return true;

  return false;
}
