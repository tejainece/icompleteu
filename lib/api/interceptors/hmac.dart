part of icu.api.interceptors;

class WrapHmacAuthenticator implements RouteWrapper<HmacAuthenticator> {
  final String _hmacSecret;

  String get id => null;

  final Map<Symbol, MakeParam> makeParams;

  const WrapHmacAuthenticator({String hmacSecret, this.makeParams})
      : _hmacSecret = hmacSecret;

  HmacAuthenticator createInterceptor() => new HmacAuthenticator(_hmacSecret);
}

class HmacAuthenticator extends Interceptor {
  final String secret;

  final crypto.Hmac codec;

  HmacAuthenticator(String secret)
      : codec = new crypto.Hmac(crypto.sha256, BASE64.decode(secret)),
        secret = secret;

  Future pre(
      Request req, @InputHeader('x-ycm-hmac') String incomingSecret) async {
    final String body = await req.bodyAsText(UTF8);

    /* TODO
    Map logged = {
      "method": req.method,
      "path": req.uri.path,
      "body": body,
      "secret": secret,
    };

    logged["method_hmac"] = BASE64.encode(_hmacEncode(UTF8.encode(req.method)));
    logged["path_hmac"] = BASE64.encode(_hmacEncode(UTF8.encode(req.uri.path)));
    logged["body_hmac"] = BASE64.encode(_hmacEncode(UTF8.encode(body)));
    */

    final String calc =
    BASE64.encode(encode(req.method, req.uri.path, body));

    /* TODO
    logged["ret_hmac"] = calc;

    log.info(logged);
    */

    if (incomingSecret != calc) {
      throw new JaguarError(
          HttpStatus.UNAUTHORIZED, 'Invalid hmac!', "Invalid hmac!");
    }
  }

  Response<String> post(@InputRouteResponse() Response<String> incoming) {
    String value = BASE64.encode(_hmacEncode(UTF8.encode(incoming.value)));
    incoming.headers['x-ycm-hmac'] = value;
    return incoming;
  }

  List<int> _hmacEncode(List<int> content) => codec.convert(content).bytes;

  List<int> encode(String method, String path, String body) {
    final List<int> data =
    _hmacEncode(UTF8.encode(method)).toList(growable: true);
    data.addAll(_hmacEncode(UTF8.encode(path)));
    data.addAll(_hmacEncode(UTF8.encode(body)));

    //TODO map["ret"] = BASE64.encode(data);

    return _hmacEncode(data);
  }
}