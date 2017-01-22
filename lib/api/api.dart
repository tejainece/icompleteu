// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library icu.server.api;

import 'dart:io';
import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar/interceptors.dart';
import 'package:logging/logging.dart';

import 'package:server/manager/manager.dart';
import 'package:server/api/interceptors/interceptors.dart';
import 'package:server/api/models/models.dart';

part 'api.g.dart';

final Logger log = new Logger('icu.server');

@Api()
@WrapAllowedHosts(const <String>['127.0.0.1', 'localhost'])
@WrapHmacAuthenticator(makeParams: const <Symbol, MakeParam>{
  #hmacSecret: const MakeParamFromMethod(#_getHmac)
})
@WrapEncodeToJson()
class IcuApi extends _$JaguarIcuApi implements RequestHandler {
  final Manager _manager;

  IcuApi(this._manager);

  @Post(path: '/event_notification')
  @WrapDecodeJsonMap()
  Future eventNotification(@Input(DecodeJsonMap) Map body) async {
    EventNotificationModel model = new EventNotificationModel.FromMap(body);
    log.info('Received event notification: ${model.eventName}');
    //DEBUG log.info(body);

    await _manager.generalCompleter
        .invokeEvent(model.eventName, new Query.FromMap(body));

    /* TODO
    for(FileDataModel dataModel in model.fileData.values) {
      //TODO _manager.findCompleter();
    }
    */
  }

  @Get(path: '/healthy')
  @WrapDecodeJsonMap()
  bool getHealth(@InputQueryParams() QueryParams queryParams) {
    log.info('Received health request');
    return true;
  }

  @Post(path: '/semantic_completion_available')
  @WrapDecodeJsonMap()
  bool isCompletionAvailableForFiletype(@Input(DecodeJsonMap) Map body) {
    log.info('Received filetype completion available request');
    log.info(body);
    if (body is! Map) {
      throw new Exception('Invalid body: Body is empty!');
    }
    final model = new SemanticCompletionAvailableModel.FromMap(body);
    return _manager.isCompletionAvailableForFileType(model.fileTypes);
  }

  @Post(path: '/shutdown')
  Future<bool> shutdown() async {
    log.info('Received shutdown request');

    await _manager.shutdown();

    new Future.delayed(new Duration(seconds: 10), () {
      exit(0);
    });

    return true;
  }

  String _getHmac() => _manager.options.hmac;
}
