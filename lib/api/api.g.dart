// GENERATED CODE - DO NOT MODIFY BY HAND

part of icu.server.api;

// **************************************************************************
// Generator: ApiGenerator
// Target: class IcuApi
// **************************************************************************

abstract class _$JaguarIcuApi implements RequestHandler {
  static const List<RouteBase> routes = const <RouteBase>[
    const Post(path: '/event_notification'),
    const Get(path: '/healthy')
  ];

  dynamic eventNotification(Map<dynamic, dynamic> body);

  dynamic getHealth(HttpRequest req);

  Future<bool> handleRequest(HttpRequest request, {String prefix: ''}) async {
    PathParams pathParams = new PathParams();
    bool match = false;

//Handler for eventNotification
    match =
        routes[0].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<dynamic> rRouteResponse0 = new Response(null);
      DecodeJsonMap iDecodeJsonMap;
      try {
        iDecodeJsonMap = new WrapDecodeJsonMap().createInterceptor();
        Map<String, dynamic> rDecodeJsonMap = await iDecodeJsonMap.pre(
          request,
        );
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.value = eventNotification(
          rDecodeJsonMap,
        );
        await rRouteResponse0.writeResponse(request.response);
      } catch (e) {
        await iDecodeJsonMap?.onException();
        rethrow;
      }
      return true;
    }

//Handler for getHealth
    match =
        routes[1].match(request.uri.path, request.method, prefix, pathParams);
    if (match) {
      Response<dynamic> rRouteResponse0 = new Response(null);
      EncodeToJson iEncodeToJson;
      try {
        iEncodeToJson = new WrapEncodeToJson().createInterceptor();
        rRouteResponse0.statusCode = 200;
        rRouteResponse0.value = getHealth(
          request,
        );
        Response<String> rRouteResponse1 = iEncodeToJson.post(
          rRouteResponse0,
        );
        await rRouteResponse1.writeResponse(request.response);
      } catch (e) {
        await iEncodeToJson?.onException();
        rethrow;
      }
      return true;
    }

    return false;
  }
}
