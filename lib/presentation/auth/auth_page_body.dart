import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/auth/auth_page/auth_page_bloc.dart';
import 'package:package_flutter/presentation/auth/auth_button.dart';
import 'package:package_flutter/presentation/core/package_title.dart';

class AuthPageBody extends StatelessWidget {
  const AuthPageBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: PackageTitle(
          child: Column(
            children: [
              AuthButton(
                'Sign in with Google',
                onPressed: () => context
                    .read<AuthPageBloc>()
                    .add(const AuthPageEvent.signedInWithGoogle()),
              ),
              const SizedBox(height: 16),
              AuthButton(
                'Sign in with Apple',
                onPressed: () => context
                    .read<AuthPageBloc>()
                    .add(const AuthPageEvent.signedInWithApple()),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
