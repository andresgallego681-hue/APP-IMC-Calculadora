// ignore: depend_on_referenced_packages
import 'package:app_bmi/Interfaz/registro_usaurios/login_view.dart';
import 'package:flutter/material.dart';

class calculadora extends StatelessWidget {
  const calculadora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: LoginView(
      ),
    );
  }
}