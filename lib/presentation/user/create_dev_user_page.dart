import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/auth/auth_bloc.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/domain/user/create_user_failure.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:package_flutter/l10n/app_text.dart';
import 'package:package_flutter/l10n/translations.dart';

class CreateDevUserPage extends ConsumerStatefulWidget {
  const CreateDevUserPage({super.key});

  @override
  ConsumerState<CreateDevUserPage> createState() => _CreateDevUserPageState();
}

class _CreateDevUserPageState extends ConsumerState<CreateDevUserPage> {
  late final TextEditingController _nickname;
  String? _error;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _nickname = TextEditingController(text: 'Defuser');
  }

  @override
  void dispose() {
    _nickname.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_submitting) return;
    final nickname = _nickname.text.trim();
    if (nickname.length < 3 || nickname.length > 15) {
      setState(() => _error = 'Nickname must be between 3 and 15 characters.');
      return;
    }
    setState(() {
      _error = null;
      _submitting = true;
    });
    try {
      final repository = ref.read(userRepositoryProvider);
      CreateUserFailure? failure;
      final avatars = ref.read(configProvider).requireValue.avatars;
      if (avatars.isEmpty) {
        failure = const CreateUserFailure.serverFailure(
            'No avatars are available.');
      } else {
        final geoState = context.read<GeolocationBloc>().state;
        final result = await repository.createUser(
          nickname: nickname,
          avatar: avatars.first,
          position: geoState is GeolocationStateLoadSuccess
              ? geoState.position
              : null,
        );
        failure = result.fold((failure) => failure, (_) => null);
      }
      if (!mounted) return;
      if (failure != null) {
        setState(() => _error = switch (failure) {
              NicknameAlreadyInUse() =>
                'Company name is busy, please enter another.',
              TooShortNickname() ||
              TooLongNickname() =>
                'Nickname must be between 3 and 15 characters.',
              ServerFailure(:final message) => message,
              _ => 'Could not save the development profile.',
            });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Could not save the development profile.');
      }
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const AppText('Choose a nickname',
                    style: TextStyle(fontSize: 24)),
                const SizedBox(height: 16),
                TextField(
                  controller: _nickname,
                  enabled: !_submitting,
                  maxLength: 15,
                  textInputAction: TextInputAction.done,
                  onSubmitted: (_) => _confirm(),
                  decoration: InputDecoration(
                    labelText: translate(context, 'Nickname'),
                    border: const OutlineInputBorder(),
                  ),
                ),
                if (_error != null) ...[
                  AppText(_error!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                ],
                ElevatedButton(
                  onPressed: _submitting ? null : _confirm,
                  child: _submitting
                      ? const CircularProgressIndicator()
                      : const AppText('Continue'),
                ),
                TextButton(
                  onPressed: _submitting
                      ? null
                      : () => context
                          .read<AuthBloc>()
                          .add(const AuthEvent.signedOut()),
                  child: const AppText('Sign out'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
