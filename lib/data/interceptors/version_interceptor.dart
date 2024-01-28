import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionInterceptor extends Interceptor {
  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final packageInfo = await PackageInfo.fromPlatform();
    options.headers['version'] = packageInfo.version;
    handler.next(options);
  }
}
