library icu.server.api.models;

class FileDataModel {
  String filePath;

  String contents;

  List<String> fileTypes;

  void fromJson(Map map) {
    contents = map['contents'];
    fileTypes = map['filetypes'];
  }
}

class BaseModel {
  int lineNum;

  int columnNum;

  String filePath;

  final Map<String, FileDataModel> fileData = {};

  void fromJson(Map map) {
    columnNum = map['column_num'];
    lineNum = map['line_num'];
    filePath = map['filepath'];

    fileData.clear();
    for (String key in map['file_data'].keys) {
      fileData[key] = new FileDataModel()..fromJson(map['file_data'][key]);
      fileData[key].filePath = key;
    }
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