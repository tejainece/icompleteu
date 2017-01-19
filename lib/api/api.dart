// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library icu.server.api;

import 'dart:io';
import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar/interceptors.dart';
import 'package:logging/logging.dart';
import 'dart:convert';

part 'api.g.dart';

final Logger log = new Logger('icu.server');

class EventNotificationModel {
  int column;

  int lineNum;

  String eventName;

  final Map<String, FileDataModel> fileData = {};

  String filePath;

  void fromJson(Map map) {
    column = map['column_num'];
    lineNum = map['line_num'];
    eventName = map['event_name'];
    filePath = map['filepath'];

    fileData.clear();
    for(String key in map['file_data'].keys) {
      fileData[key] = new FileDataModel()..fromJson(map['file_data'][key]);
      fileData[key].filePath = key;
    }
  }

  String toString() => '$filePath:$lineNum:$column $eventName';
}

class FileDataModel {
  String filePath;

  String contents;

  List<String> fileTypes;


  void fromJson(Map map) {
    contents = map['contents'];
    fileTypes = map['filetypes'];
  }
}

@Api()
class IcuApi extends _$JaguarIcuApi implements RequestHandler {
  @Post(path: '/event_notification')
  @WrapDecodeJsonMap()
  eventNotification(@Input(DecodeJsonMap) Map body) {
    log.info('Received event notification');
    EventNotificationModel model = new EventNotificationModel();
    model.fromJson(body);
    log.info(model);
    //TODO
  }

  @Get(path: '/healthy')
  @WrapEncodeToJson()
  getHealth(HttpRequest req) {
    log.info('Received health request');
    return true;
  }
}