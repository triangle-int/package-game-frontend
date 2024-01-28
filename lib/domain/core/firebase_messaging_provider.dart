import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

final firebaseMessagingProvider = Provider((ref) => FirebaseMessaging.instance);
