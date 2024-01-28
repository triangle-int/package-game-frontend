import 'package:dio/dio.dart';

class NotAuthenticatedException extends DioException {
  NotAuthenticatedException({required DioException error})
      : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        );
}
