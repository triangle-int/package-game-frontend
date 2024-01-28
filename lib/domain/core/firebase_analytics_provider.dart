import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final firebaseAnalyticsProvider = Provider((ref) => FirebaseAnalytics.instance);
