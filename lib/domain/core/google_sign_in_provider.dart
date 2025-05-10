import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'google_sign_in_provider.g.dart';

@riverpod
GoogleSignIn googleSignIn(Ref ref) {
  return GoogleSignIn();
}
