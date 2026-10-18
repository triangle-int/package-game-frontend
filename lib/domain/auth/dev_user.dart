import 'package:firebase_auth/firebase_auth.dart';

class DevUser implements User {
  @override
  final String uid = 'dev_user_1';

  @override
  final String? email = 'dev@package.local';

  @override
  final String? displayName = 'Dev User';

  @override
  final bool emailVerified = true;

  @override
  final bool isAnonymous = true;

  @override
  Future<String> getIdToken([bool forceRefresh = false]) async =>
      'dev_token';

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
