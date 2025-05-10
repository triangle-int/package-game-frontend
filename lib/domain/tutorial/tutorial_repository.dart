import 'dart:convert';

import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:logger/logger.dart';
import 'package:package_flutter/domain/core/dio_provider.dart';
import 'package:package_flutter/domain/core/firebase_analytics_provider.dart';
import 'package:package_flutter/domain/core/server_failure.dart';
import 'package:package_flutter/domain/tutorial/tutorial_step.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'tutorial_repository.g.dart';

@riverpod
TutorialRepository tutorialRepository(Ref ref) {
  return TutorialRepository(
    ref.watch(dioProvider),
    ref.watch(firebaseAnalyticsProvider),
  );
}

class TutorialRepository {
  final Dio _dio;
  final FirebaseAnalytics _analytics;

  TutorialRepository(this._dio, this._analytics);

  Future<Either<ServerFailure, TutorialStep>> getTutorialStep() async {
    try {
      final response = await _dio.get('/user/get-tutorial');
      final data = response.data as String?;
      Logger().d(data);

      final stepRaw = data == null || data.isEmpty
          ? jsonEncode(const TutorialStep.initial().toJson())
          : response.data as String;

      final step =
          TutorialStep.fromJson(jsonDecode(stepRaw) as Map<String, dynamic>);
      if (step is InitialTutorialStep) {
        _analytics.logTutorialBegin();
      }
      return right(step);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }

  Future<Either<ServerFailure, Unit>> setStep(TutorialStep step) async {
    try {
      await _dio.post(
        '/user/set-tutorial',
        data: {
          'tutorial': jsonEncode(step.toJson()),
        },
      );
      if (step is Hidden2TutorialStep) {
        await _analytics.logTutorialComplete();
      }
      return right(unit);
    } on DioException catch (e) {
      return left(ServerFailure.fromError(e));
    }
  }
}
