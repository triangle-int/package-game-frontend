import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_flutter/bloc/auth/auth_bloc.dart';
import 'package:package_flutter/bloc/config/config_provider.dart';
import 'package:package_flutter/bloc/geolocation/geolocation_bloc.dart';
import 'package:package_flutter/domain/user/create_user_failure.dart';
import 'package:package_flutter/domain/user/user_repository.dart';
import 'package:package_flutter/presentation/loading/loading_page.dart';

class CreateDevUserPage extends ConsumerStatefulWidget {
  const CreateDevUserPage({super.key});

  @override
  ConsumerState<CreateDevUserPage> createState() => _CreateDevUserPageState();
}

class _CreateDevUserPageState extends ConsumerState<CreateDevUserPage> {
  String? _error;

  @override
  void initState() {
    super.initState();
    Future.microtask(_createUser);
  }

  Future<void> _createUser() async {
    if (!mounted) return;
    setState(() => _error = null);
    try {
      final avatars = ref.read(configProvider).requireValue.avatars;
      if (avatars.isEmpty) throw StateError('No avatars are available.');
      final geoState = context.read<GeolocationBloc>().state;
      final result = await ref.read(userRepositoryProvider).createUser(
            nickname: 'Defuser',
            avatar: avatars.first,
            position: geoState is GeolocationStateLoadSuccess
                ? geoState.position
                : null,
          );
      if (!mounted) return;
      result.fold((failure) {
        setState(() => _error = switch (failure) {
              NicknameAlreadyInUse() => 'The name Defuser is already in use.',
              ServerFailure(:final message) => message,
              _ => 'Could not create the development profile: $failure',
            });
      }, (_) {});
    } catch (error) {
      if (mounted) setState(() => _error = error.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error == null)
      return const LoadingPage(text: 'Creating dev profile...');
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_error!, textAlign: TextAlign.center),
            TextButton(onPressed: _createUser, child: const Text('Try again')),
            TextButton(
              onPressed: () =>
                  context.read<AuthBloc>().add(const AuthEvent.signedOut()),
              child: const Text('Sign out'),
            ),
          ],
        ),
      ),
    );
  }
}
