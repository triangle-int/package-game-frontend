import 'package:dio/dio.dart';

class NotAuthenticatedException extends DioError {
  NotAuthenticatedException({required DioError error})
      : super(
          requestOptions: error.requestOptions,
          response: error.response,
          type: error.type,
          error: error.error,
        );
}
