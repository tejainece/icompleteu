library icu.server.api.models;

import 'dart:convert';
import 'package:jaguar/src/http/json/json.dart';

import 'package:icu_server/identifier/identifier.dart';

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
      } else if (value is String) {
        fileTypes = <String>[map['filetypes']];
      } else {
        fileTypes = <String>[];
      }
    }
  }

  String getLine(int lineNum) {
    if(lineNum < 1) return '';
    List<String> lines = new LineSplitter().convert(contents);
    if ((lineNum-1) >= lines.length) return '';
    return lines[lineNum-1];
  }

  int offset(int lineNum, int colNum) {
    int curline = 1;
    int curcol = 1;
    for(int i = 0; i < contents.length; i++) {
      if(curline == lineNum && curcol == colNum) return i+1;

      if(contents[i] == '\n') {
        curline += 1;
        curcol = 1;
        continue;
      }

      curcol++;
    }

    return -1;
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

    {

    }
  }

  String getLine(String filepath, int lineNum) {
    FileDataModel file = fileData[filepath];
    if (file is! FileDataModel) return '';
    return file.getLine(lineNum);
  }

  FileDataModel get selFileData => fileData[filePath];

  String get contents => selFileData.contents;

  int get offset => selFileData.offset(lineNum, columnNum);
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

  String get lineValue => getLine(filePath, lineNum);

  Query();

  int getIdentifierStartColumn() {
    final String fileType = fileTypes.isNotEmpty? fileTypes.first: null;
    return toIdentifierStartColumn(lineValue, columnNum, fileType);
  }

  void fromMap(Map map) {
    super.fromJson(map);
    fileTypes.addAll(fileData[filePath].fileTypes);
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
  if (bytes.length < (byteOffset-1)) return 0;

  return UTF8.decode(bytes.sublist(0, byteOffset-1)).length+1;
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
    if (extraMenuInfo is String) map['extra_menu_info'] = extraMenuInfo;
    if (menuText is String) map['menu_text'] = menuText;
    if (kind is String) map['kind'] = kind;
    if (detailedInfo is String) map['detailed_info'] = detailedInfo;
    if (extraData is String) map['extra_data'] = extraData;
    return map;
  }

  String toString() => insertionText;
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
