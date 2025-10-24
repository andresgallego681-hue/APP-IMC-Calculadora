import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Rutas
import 'package:app_bmi/Interfaz/registro_usaurios/login_view.dart';
import 'package:app_bmi/Interfaz/calculo.dart'; // tu pantalla de cálculo

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Lee la preferencia ANTES de correr la app
  final prefs = await SharedPreferences.getInstance();
  final bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

  runApp(MyApp(isLoggedIn: isLoggedIn));
}

class MyApp extends StatelessWidget {
  final bool isLoggedIn;
  const MyApp({super.key, required this.isLoggedIn});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'App BMI',
      initialRoute: isLoggedIn ? '/calculo' : '/login',
      routes: {
        '/login': (_) => const LoginView(),
        '/calculo': (_) => const calculo(),
      },
      // (opcional) tema
    );
  }
}

