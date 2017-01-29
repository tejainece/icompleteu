part of icu.api.interceptors;

class WrapAllowedHosts implements RouteWrapper<AllowedHosts> {
  final List<String> allowed;

  final String id;

  final Map<Symbol, MakeParam> makeParams;

  const WrapAllowedHosts(this.allowed, {this.id, this.makeParams});

  AllowedHosts createInterceptor() => new AllowedHosts(new Set.from(allowed));
}

class AllowedHosts extends Interceptor {
  final Set<String> allowed;

  const AllowedHosts(this.allowed);

  void pre(Request req) {
    if (!allowed.contains(req.headers.host)) {
      throw new JaguarError(
          HttpStatus.BAD_REQUEST, "Bad host", "Host not allowed!");
    }
  }
}
