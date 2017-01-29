// Copyright (c) 2017, teja. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.

library icu.server.api;

import 'dart:io';
import 'dart:async';
import 'package:jaguar/jaguar.dart';
import 'package:jaguar/interceptors.dart';
import 'package:logging/logging.dart';

import 'package:icu_server/manager/manager.dart';
import 'package:icu_server/api/interceptors/interceptors.dart';
import 'package:icu_server/api/models/models.dart';

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
  Future<ToJsonable> eventNotification(@Input(DecodeJsonMap) Map body) async {
    EventNotificationModel model = new EventNotificationModel.FromMap(body);
    log.info(
        'Received event notification: ${model.eventName}');
    //DEBUG log.info(body);
    final q = new BaseModel.FromJson(body); // parse body

    await _manager.generalCompleter.invokeEvent(model.eventName, q);

    final comp = _manager.findCompleter(model.fileTypes);

    final result = await comp.invokeEvent(model.eventName, q);

    return result;
  }

  @Post(path: '/completions', charset: 'utf-8')
  @WrapDecodeJsonMap()
  Future<Map> getCompletions(@Input(DecodeJsonMap) Map body) async {
    log.info('Received completion request');

    final Query query = new Query.FromMap(body);

    final List<bool> shouldUse = _manager.shouldUseCompletion(query);

    final List<CompletionError> errors = [];
    final List<CodeCompletionItem> completions = [];

    bool completed = false;

    if (shouldUse[0]) {
      try {
        completed = true;
        completions.addAll(await _manager
            .findCompleter(query.fileTypes)
            .computeCandidates(query));
      } catch (e, s) {
        if (shouldUse[1]) {
          rethrow;
        } else {
          errors.add(new CompletionError(e, s));
        }
      }
    }

    if (!completed && !shouldUse[1]) {
      completions
          .addAll(await _manager.generalCompleter.computeCandidates(query));
    }

    Map map = new CodeCompletionResponse(
            completions, query.getIdentifierStartColumn(), errors)
        .toJson();

    return map;
  }

  @Get(path: '/healthy')
  bool getHealth() {
    log.info('Received health request');
    return true;
  }

  @Post(path: '/semantic_completion_available')
  @WrapDecodeJsonMap()
  bool isCompletionAvailableForFileType(@Input(DecodeJsonMap) Map body) {
    log.info('Received filetype completion available request');
    //DEBUG log.info(body);
    if (body is! Map) {
      throw new Exception('Invalid body: Body is empty!');
    }
    final model = new SemanticCompletionAvailableModel.FromMap(body);
    return _manager.isCompletionAvailable(model.fileTypes);
  }

  @Post(path: '/shutdown')
  Future<bool> shutdown() async {
    log.info('Received shutdown request');

    await _manager.shutdown();

    exit(0);

    return true;
  }

  @Post(path: '/detailed_diagnostic')
  @WrapDecodeJsonMap()
  Future getDetailedDiagnostics(@Input(DecodeJsonMap) Map body) async {
    log.info('Get diagnostics');
    final q = new BaseModel.FromJson(body); // parse body
    final comp = _manager.findCompleter(q.fileTypes);

    if(comp == null) {
      return await _manager.generalCompleter.getDetailedDiagnostic(q);
    }

    return await comp.getDetailedDiagnostic(q);
  }

  String _getHmac() => _manager.options.hmac;
}
