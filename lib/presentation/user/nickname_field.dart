import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:package_flutter/bloc/user/create_user/create_user_bloc.dart';

class NicknameField extends StatelessWidget {
  const NicknameField({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CreateUserBloc, CreateUserState>(
      builder: (context, state) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Company name',
                  hintStyle: const TextStyle(
                    color: Color(0xFF646464),
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontSize: 22,
                  ),
                  counterStyle: const TextStyle(
                    height: double.minPositive,
                  ),
                  counterText: '',
                  fillColor: const Color(0xFFE2E2E2),
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.fromLTRB(13, 0, 13, 0),
                ),
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w500,
                  fontSize: 22,
                ),
                autocorrect: false,
                maxLength: 15,
                onChanged: (value) => context
                    .read<CreateUserBloc>()
                    .add(CreateUserEvent.nicknameChanged(value)),
              ),
            ),
            const SizedBox(width: 15),
            if (state.isSubmitting) ...[
              const CircularProgressIndicator(),
            ] else ...[
              AspectRatio(
                aspectRatio: 1,
                child: ElevatedButton(
                  onPressed: () => context
                      .read<CreateUserBloc>()
                      .add(const CreateUserEvent.confirmed()),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.all(5),
                    shape: const CircleBorder(),
                    backgroundColor: Theme.of(context).primaryColor,
                    foregroundColor: Colors.black,
                    elevation: 7,
                    shadowColor: Colors.black,
                  ),
                  child: const Icon(Icons.check),
                ),
              ),
            ]
          ],
        );
      },
    );
  }
}
