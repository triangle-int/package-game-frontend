import 'package:flutter/material.dart';
import 'package:package_flutter/presentation/user/avatar_field.dart';
import 'package:package_flutter/presentation/user/nickname_field.dart';

class CreateUserBody extends StatelessWidget {
  const CreateUserBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20),
          alignment: Alignment.topCenter,
          child: Column(
            children: <Widget>[
              const Text(
                'Choose your avatar',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 30,
                  fontFamily: 'Montserrat',
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 10),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF646464),
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 3),
                      blurRadius: 5,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              const Expanded(
                child: AvatarField(),
              ),
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 25),
                height: 6,
                decoration: BoxDecoration(
                  color: const Color(0xFF646464),
                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                  boxShadow: [
                    BoxShadow(
                      offset: const Offset(0, 4),
                      blurRadius: 10,
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 30),
                height: 46,
                child: const NicknameField(),
              ),
              const SizedBox(height: 10),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 30),
                child: Text(
                  'Company name can only contain letters, numbers, or underscores',
                  style: TextStyle(
                    fontFamily: 'Montserrat',
                    fontWeight: FontWeight.w500,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.start,
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}
