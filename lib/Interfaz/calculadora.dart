import 'package:app_bmi/Interfaz/calculo.dart';
import 'package:flutter/material.dart';

class calculadora extends StatelessWidget {
  const calculadora({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: calculo(),
    );
  }
}