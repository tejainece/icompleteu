library icu.server.api.models;

import 'dart:convert';
import 'package:jaguar/src/http/json/json.dart';

import 'package:server/identifier/identifier.dart';

class FileDataModel {
  String filePath;

  String contents;

  List<String> fileTypes;

  void fromJson(Map map) {
    {
      dynamic value = map['contents'];
      if (value is String) {
        contents = value;
      } else {
        contents = '';
      }
    }

    {
      dynamic value = map['filetypes'];
      if (value is List<String>) {
        fileTypes = map['filetypes'];
      } else {
        fileTypes = <String>[];
      }
    }
  }

  String getLine(int lineNum) {
    final List<String> lines = new LineSplitter().convert(contents);
    if (lineNum >= lines.length) return '';
    return lines[lineNum];
  }
}

class BaseModel {
  int lineNum;

  int columnNum;

  String filePath;

  final Map<String, FileDataModel> fileData = {};

  void fromJson(Map map) {
    {
      dynamic value = map['line_num'];
      if (value is int) {
        lineNum = value;
      } else {
        lineNum = 0;
      }
    }

    {
      dynamic value = map['column_num'];
      if (value is int) {
        columnNum = value;
      } else {
        columnNum = 0;
      }
    }

    {
      dynamic value = map['filepath'];
      if (value is String) {
        filePath = value;
      } else {
        filePath = null;
      }
    }

    fileData.clear();
    for (String key in map['file_data'].keys) {
      fileData[key] = new FileDataModel()..fromJson(map['file_data'][key]);
      fileData[key].filePath = key;
    }
  }

  String getLine(String filepath, int lineNum) {
    FileDataModel file = fileData[filepath];
    if (file is! FileDataModel) return '';
    return file.getLine(lineNum);
  }
}

class EventNotificationModel extends BaseModel {
  String eventName;

  EventNotificationModel._();

  factory EventNotificationModel.FromMap(Map map) {
    final model = new EventNotificationModel._();
    model.fromJson(map);
    return model;
  }

  void fromJson(Map map) {
    super.fromJson(map);
    eventName = map['event_name'];
  }

  String toString() => '$filePath:$lineNum:$columnNum $eventName';
}

class SemanticCompletionAvailableModel extends BaseModel {
  List<String> fileTypes;

  SemanticCompletionAvailableModel._();

  factory SemanticCompletionAvailableModel.FromMap(Map map) {
    final model = new SemanticCompletionAvailableModel._();
    model.fromJson(map);
    return model;
  }

  void fromJson(Map map) {
    super.fromJson(map);
    {
      dynamic data = map['filetypes'];
      if (data is String) {
        fileTypes = <String>[data];
      } else if (data is List<String>) {
        fileTypes = data;
      } else {
        fileTypes = <String>[];
      }
    }
  }

  String toString() => '$filePath:$lineNum:$columnNum $fileTypes';
}

class Query extends BaseModel {
  int get columnCodepoint => byteOffsetToUnicodeOffset(lineValue, columnNum);

  int get startCodepoint => getIdentifierStartColumn();

  int get codeLength => columnCodepoint - startCodepoint;

  /// Forces semantic completion
  bool forceSemanticCompletion;

  final List<String> fileTypes = [];

  String get lineValue => getLine(filePath, lineNum - 1);

  Query();

  int getIdentifierStartColumn() {
    String fileType;
    if (fileTypes.length > 0) {
      fileType = fileTypes.first;
    }
    return toIdentifierStartColumn(lineValue, columnNum, fileType);
  }

  void fromMap(Map map) {
    super.fromJson(map);
  }

  factory Query.FromMap(Map map) {
    final query = new Query();
    query.fromMap(map);
    return query;
  }
}

int toIdentifierStartColumn(String lineVal, int columnVal, String fileType) {
  final int unicodeColNum = byteOffsetToUnicodeOffset(lineVal, columnVal);

  return startOfLongestIdentifierEndingAtIndex(
      lineVal, unicodeColNum, fileType);
}

int byteOffsetToUnicodeOffset(String string, int byteOffset) {
  List<int> bytes = UTF8.encode(string);
  if (bytes.length < byteOffset) return 0;

  return UTF8.decode(bytes.sublist(0, byteOffset)).length + 1;
}

class CompletionError implements ToJsonable {
  final dynamic exception;

  final StackTrace traceback;

  CompletionError(this.exception, this.traceback);

  Map toJson() => {
        'message': exception.toString(),
        'traceback': traceback.toString(),
      };
}

class CodeCompletionItem implements ToJsonable {
  /// Completed code
  final String insertionText;

  /// Display text
  final String extraMenuInfo;

  /// Description
  final String detailedInfo;

  final String menuText;

  final String kind;

  final Map<String, dynamic> extraData;

  const CodeCompletionItem(this.insertionText,
      {this.extraMenuInfo,
      this.detailedInfo,
      this.menuText,
      this.kind,
      this.extraData});

  Map toJson() {
    Map map = {};
    if (insertionText is String) map['insertion_text'] = insertionText;
    /* TODO
    {
      : insertionText,
    'menu_text': menuText,
    'extra_menu_info': extraMenuInfo,
    'kind': kind,
    'detailed_info': detailedInfo,
    'extra_data': extraData,
  };
  */
    return map;
  }
}

class CodeCompletionResponse implements ToJsonable {
  final List<CodeCompletionItem> items;

  final int startColumn;

  final List<CompletionError> errors;

  const CodeCompletionResponse(this.items, this.startColumn,
      [this.errors = const []]);

  Map toJson() => {
        'completions':
            items.map((CodeCompletionItem item) => item.toJson()).toList(),
        'completion_start_column': startColumn,
        'errors':
            errors.map((CompletionError error) => error.toJson()).toList(),
      };
}
