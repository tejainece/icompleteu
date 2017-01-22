// GENERATED CODE - DO NOT MODIFY BY HAND

part of icu.server.api;

// **************************************************************************
// Generator: ApiGenerator
// Target: class IcuApi
// **************************************************************************

abstract class _$JaguarIcuApi implements RequestHandler {
  static const List<RouteBase> routes = const <RouteBase>[
    const Post(path: '/event_notification'),
    const Post(path: '/completions'),
    const Get(path: '/healthy'),
    const Post(path: '/semantic_completion_available'),
    const Post(path: '/shutdown')
  ];

  Future<dynamic> eventNotification(Map<dynamic, dynamic> body);

  String _getHmac();

  Future<Map<dynamic, dynamic>> getCompletions(Map<dynamic, dynamic> body);

  bool getHealth();

  bool isCompletionAvailableForFileType(Map<dynamic, dynamic> body);

  Future<bool> shutdown();

  Future<Response> handleRequest(Request request, {String prefix: ''}) async {
    PathParams pathParams = new PathParams();
    bool match = false;

//Handler for eventNotification
    match =
        routes[0].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<dynamic> rRouteResponse0 = new Response(null);
      AllowedHosts iAllowedHosts;
      HmacAuthenticator iHmacAuthenticator;
      EncodeToJson iEncodeToJson;
      DecodeJsonMap iDecodeJsonMap;
      try {
        iAllowedHosts = new WrapAllowedHosts(
          const <String>['127.0.0.1', 'localhost'],
        ).createInterceptor();
        iAllowedHosts.pre(
          request,
        );
        iHmacAuthenticator = new WrapHmacAuthenticator(
          makeParams: const <Symbol, MakeParam>{
            #hmacSecret: const MakeParamFromMethod(#_getHmac)
          },
          hmacSecret: _getHmac(),
        )
            .createInterceptor();
        await iHmacAuthenticator.pre(
          request,
          request.headers.value('x-ycm-hmac'),
        );
        iEncodeToJson = new WrapEncodeToJson().createInterceptor();
        iDecodeJsonMap = new WrapDecodeJsonMap().createInterceptor();
        Map<String, dynamic> rDecodeJsonMap = await iDecodeJsonMap.pre(
          request,
        );
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.setContentType('text/plain; charset=us-ascii');
        rRouteResponse0.value = await eventNotification(
          rDecodeJsonMap,
        );
        Response<String> rRouteResponse1 = iEncodeToJson.post(
          rRouteResponse0,
        );
        Response<String> rRouteResponse2 = iHmacAuthenticator.post(
          rRouteResponse1,
        );
        return rRouteResponse2;
      } catch (e) {
        await iDecodeJsonMap?.onException();
        await iEncodeToJson?.onException();
        await iHmacAuthenticator?.onException();
        await iAllowedHosts?.onException();
        rethrow;
      }
    }

//Handler for getCompletions
    match =
        routes[1].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<Map> rRouteResponse0 = new Response(null);
      AllowedHosts iAllowedHosts;
      HmacAuthenticator iHmacAuthenticator;
      EncodeToJson iEncodeToJson;
      DecodeJsonMap iDecodeJsonMap;
      try {
        iAllowedHosts = new WrapAllowedHosts(
          const <String>['127.0.0.1', 'localhost'],
        ).createInterceptor();
        iAllowedHosts.pre(
          request,
        );
        iHmacAuthenticator = new WrapHmacAuthenticator(
          makeParams: const <Symbol, MakeParam>{
            #hmacSecret: const MakeParamFromMethod(#_getHmac)
          },
          hmacSecret: _getHmac(),
        )
            .createInterceptor();
        await iHmacAuthenticator.pre(
          request,
          request.headers.value('x-ycm-hmac'),
        );
        iEncodeToJson = new WrapEncodeToJson().createInterceptor();
        iDecodeJsonMap = new WrapDecodeJsonMap().createInterceptor();
        Map<String, dynamic> rDecodeJsonMap = await iDecodeJsonMap.pre(
          request,
        );
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.setContentType('text/plain; charset=us-ascii');
        rRouteResponse0.value = await getCompletions(
          rDecodeJsonMap,
        );
        Response<String> rRouteResponse1 = iEncodeToJson.post(
          rRouteResponse0,
        );
        Response<String> rRouteResponse2 = iHmacAuthenticator.post(
          rRouteResponse1,
        );
        return rRouteResponse2;
      } catch (e) {
        await iDecodeJsonMap?.onException();
        await iEncodeToJson?.onException();
        await iHmacAuthenticator?.onException();
        await iAllowedHosts?.onException();
        rethrow;
      }
    }

//Handler for getHealth
    match =
        routes[2].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<bool> rRouteResponse0 = new Response(null);
      AllowedHosts iAllowedHosts;
      HmacAuthenticator iHmacAuthenticator;
      EncodeToJson iEncodeToJson;
      try {
        iAllowedHosts = new WrapAllowedHosts(
          const <String>['127.0.0.1', 'localhost'],
        ).createInterceptor();
        iAllowedHosts.pre(
          request,
        );
        iHmacAuthenticator = new WrapHmacAuthenticator(
          makeParams: const <Symbol, MakeParam>{
            #hmacSecret: const MakeParamFromMethod(#_getHmac)
          },
          hmacSecret: _getHmac(),
        )
            .createInterceptor();
        await iHmacAuthenticator.pre(
          request,
          request.headers.value('x-ycm-hmac'),
        );
        iEncodeToJson = new WrapEncodeToJson().createInterceptor();
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.setContentType('text/plain; charset=us-ascii');
        rRouteResponse0.value = getHealth();
        Response<String> rRouteResponse1 = iEncodeToJson.post(
          rRouteResponse0,
        );
        Response<String> rRouteResponse2 = iHmacAuthenticator.post(
          rRouteResponse1,
        );
        return rRouteResponse2;
      } catch (e) {
        await iEncodeToJson?.onException();
        await iHmacAuthenticator?.onException();
        await iAllowedHosts?.onException();
        rethrow;
      }
    }

//Handler for isCompletionAvailableForFileType
    match =
        routes[3].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<bool> rRouteResponse0 = new Response(null);
      AllowedHosts iAllowedHosts;
      HmacAuthenticator iHmacAuthenticator;
      EncodeToJson iEncodeToJson;
      DecodeJsonMap iDecodeJsonMap;
      try {
        iAllowedHosts = new WrapAllowedHosts(
          const <String>['127.0.0.1', 'localhost'],
        ).createInterceptor();
        iAllowedHosts.pre(
          request,
        );
        iHmacAuthenticator = new WrapHmacAuthenticator(
          makeParams: const <Symbol, MakeParam>{
            #hmacSecret: const MakeParamFromMethod(#_getHmac)
          },
          hmacSecret: _getHmac(),
        )
            .createInterceptor();
        await iHmacAuthenticator.pre(
          request,
          request.headers.value('x-ycm-hmac'),
        );
        iEncodeToJson = new WrapEncodeToJson().createInterceptor();
        iDecodeJsonMap = new WrapDecodeJsonMap().createInterceptor();
        Map<String, dynamic> rDecodeJsonMap = await iDecodeJsonMap.pre(
          request,
        );
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.setContentType('text/plain; charset=us-ascii');
        rRouteResponse0.value = isCompletionAvailableForFileType(
          rDecodeJsonMap,
        );
        Response<String> rRouteResponse1 = iEncodeToJson.post(
          rRouteResponse0,
        );
        Response<String> rRouteResponse2 = iHmacAuthenticator.post(
          rRouteResponse1,
        );
        return rRouteResponse2;
      } catch (e) {
        await iDecodeJsonMap?.onException();
        await iEncodeToJson?.onException();
        await iHmacAuthenticator?.onException();
        await iAllowedHosts?.onException();
        rethrow;
      }
    }

//Handler for shutdown
    match =
        routes[4].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<bool> rRouteResponse0 = new Response(null);
      AllowedHosts iAllowedHosts;
      HmacAuthenticator iHmacAuthenticator;
      EncodeToJson iEncodeToJson;
      try {
        iAllowedHosts = new WrapAllowedHosts(
          const <String>['127.0.0.1', 'localhost'],
        ).createInterceptor();
        iAllowedHosts.pre(
          request,
        );
        iHmacAuthenticator = new WrapHmacAuthenticator(
          makeParams: const <Symbol, MakeParam>{
            #hmacSecret: const MakeParamFromMethod(#_getHmac)
          },
          hmacSecret: _getHmac(),
        )
            .createInterceptor();
        await iHmacAuthenticator.pre(
          request,
          request.headers.value('x-ycm-hmac'),
        );
        iEncodeToJson = new WrapEncodeToJson().createInterceptor();
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.setContentType('text/plain; charset=us-ascii');
        rRouteResponse0.value = await shutdown();
        Response<String> rRouteResponse1 = iEncodeToJson.post(
          rRouteResponse0,
        );
        Response<String> rRouteResponse2 = iHmacAuthenticator.post(
          rRouteResponse1,
        );
        return rRouteResponse2;
      } catch (e) {
        await iEncodeToJson?.onException();
        await iHmacAuthenticator?.onException();
        await iAllowedHosts?.onException();
        rethrow;
      }
    }

    return null;
  }
}
