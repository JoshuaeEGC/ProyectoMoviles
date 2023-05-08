import 'package:auth_buttons/auth_buttons.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../../auth/bloc/auth_bloc.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key? key}) : super(key: key);

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: ListView(
          children: [
            SizedBox(height: 200),
            Center(
              child: Text(
                "Iniciar Sesion",
                style: Theme.of(context).textTheme.headlineLarge,
              ),
            ),
            SizedBox(height: 50),
            GoogleAuthButton(
              onPressed: () {
                // Bloc add event autenticacion con google event
                BlocProvider.of<AuthBloc>(context).add(GoogleAuthEvent());
              },
            ),
          ],
        ),
      ),
    );
  }
}
