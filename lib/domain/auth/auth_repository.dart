import 'dart:convert';
import 'dart:async';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/domain/auth/auth_failure.dart';
import 'package:package_flutter/domain/auth/dev_user.dart';
import 'package:package_flutter/domain/core/firebase_auth_provider.dart';
import 'package:package_flutter/domain/core/google_sign_in_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    ref.watch(firebaseAuthProvider),
    ref.watch(googleSignInProvider),
  );
}

class AuthRepository {
  final FirebaseAuth _auth;
  final GoogleSignIn _googleSignIn;
  final _devChanges = StreamController<bool>.broadcast();
  bool _devSignedIn = false;
  String? _devUserId;

  AuthRepository(this._auth, this._googleSignIn);

  Future<String?> getToken() async {
    if (kDebugMode && _devSignedIn) return 'dev_token:$_devUserId';
    return _auth.currentUser?.getIdToken();
  }

  Stream<Either<AuthFailure, User>> authStateChanges() {
    return Stream.multi((controller) {
      void emit(User? user) {
        if (kDebugMode && _devSignedIn) {
          controller.add(right(DevUser(uid: _devUserId!)));
        } else if (user == null) {
          controller.add(left(const AuthFailure.unauthenticated()));
        } else {
          controller.add(right(user));
        }
      }

      final firebase =
          _auth.authStateChanges().listen(emit, onError: controller.addError);
      final dev = _devChanges.stream.listen((_) => emit(_auth.currentUser));
      controller.onCancel = () async {
        await firebase.cancel();
        await dev.cancel();
      };
    });
  }

  void signInForDevelopment() {
    if (!kDebugMode) return;
    final random = Random.secure().nextInt(0x7fffffff).toRadixString(36);
    _devUserId = 'dev_${DateTime.now().microsecondsSinceEpoch}_$random';
    _devSignedIn = true;
    _devChanges.add(true);
  }

  Future signOut() async {
    _devSignedIn = false;
    _devUserId = null;
    _devChanges.add(false);
    await _auth.signOut();
  }

  Future<Either<AuthFailure, Unit>> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

    if (googleUser == null) {
      return left(const AuthFailure.canceled());
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth =
        await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    try {
      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(credential);

      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.firebaseFailure(e.code));
    }
  }

  /// Generates a cryptographically secure random nonce, to be included in a
  /// credential request.
  String generateNonce([int length = 32]) {
    const charset =
        '0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._';
    final random = Random.secure();
    return List.generate(length, (_) => charset[random.nextInt(charset.length)])
        .join();
  }

  /// Returns the sha256 hash of [input] in hex notation.
  String sha256ofString(String input) {
    final bytes = utf8.encode(input);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Either<AuthFailure, Unit>> signInWithApple() async {
    // To prevent replay attacks with the credential returned from Apple, we
    // include a nonce in the credential request. When signing in with
    // Firebase, the nonce in the id token returned by Apple, is expected to
    // match the sha256 hash of `rawNonce`.
    final rawNonce = generateNonce();
    final nonce = sha256ofString(rawNonce);

    // Request credential for the currently signed in Apple account.
    final appleCredential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
      ],
      nonce: nonce,
    );

    // Create an `OAuthCredential` from the credential returned by Apple.
    final oauthCredential = OAuthProvider('apple.com').credential(
      idToken: appleCredential.identityToken,
      rawNonce: rawNonce,
      accessToken: appleCredential.authorizationCode,
    );

    // Sign in the user with Firebase. If the nonce we generated earlier does
    // not match the nonce in `appleCredential.identityToken`, sign in will fail.
    try {
      // Once signed in, return the UserCredential
      await _auth.signInWithCredential(oauthCredential);

      return right(unit);
    } on FirebaseAuthException catch (e) {
      return left(AuthFailure.firebaseFailure(e.code));
    }
  }
}
