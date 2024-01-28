import 'package:dio/dio.dart';
import 'package:package_flutter/data/exceptions/not_authenticated_exception.dart';
import 'package:package_flutter/domain/auth/auth_repository.dart';

class AuthInterceptor extends Interceptor {
  final AuthRepository _auth;

  AuthInterceptor(this._auth);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final accessToken = await _auth.getToken();
    if (accessToken == null) {
      handler.reject(
        NotAuthenticatedException(
          error: DioError(
            requestOptions: options,
          ),
        ),
      );
      return;
    }

    options.headers['Authorization'] = 'Bearer $accessToken';
    // Logger().d('Auth header:\n${options.headers['Authorization']}');
    handler.next(options);
  }
}
