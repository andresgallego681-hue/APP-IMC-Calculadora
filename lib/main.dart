import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MiAplicacion());
}

class MiAplicacion extends StatelessWidget {
  const MiAplicacion({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'App Demo',
      debugShowCheckedModeBanner: false,
      home: const PantallaLogin(),
    );
  }
}

// ---------------- Pantalla Login ----------------
class PantallaLogin extends StatefulWidget {
  const PantallaLogin({super.key});

  @override
  State<PantallaLogin> createState() => _PantallaLoginState();
}

class _PantallaLoginState extends State<PantallaLogin> {
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  Future<void> _iniciarSesion() async {
    final prefs = await SharedPreferences.getInstance();

    final correoGuardado = prefs.getString("correo") ?? "";
    final claveGuardada = prefs.getString("clave") ?? "";

    if (_correoController.text == correoGuardado &&
        _claveController.text == claveGuardada) {
      // Comprobación Usuarios
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PantallaInicio()),
      );
    } else {
      // Usuario incorrecto
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Error de inicio de sesión"),
          content: const Text("Correo o contraseña incorrectos."),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Aceptar"),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Barra superior gris
          Container(height: 40, color: Colors.grey[700]),
          const SizedBox(height: 40),

          const Text(
            "Bienvenido a la App",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          // Campo correo
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
          ),
          const SizedBox(height: 10),

          // Campo contraseña
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _claveController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 20),

          // Botón para iniciar sesión
          ElevatedButton(
            onPressed: _iniciarSesion,
            child: const Text("Iniciar Sesión"),
          ),
          const SizedBox(height: 10),

          // Botón para registro
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaRegistro()),
              );
            },
            child: const Text("Registrarse"),
          ),
          const SizedBox(height: 10),

          // Botón continuar sin registrar
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PantallaInvitado()),
              );
            },
            child: const Text("Continuar sin registrar"),
          ),

          const Spacer(),
          Container(height: 40, color: Colors.grey[700]),
        ],
      ),
    );
  }
}

// ---------------- Pantalla Registro ----------------
class PantallaRegistro extends StatefulWidget {
  const PantallaRegistro({super.key});

  @override
  State<PantallaRegistro> createState() => _PantallaRegistroState();
}

class _PantallaRegistroState extends State<PantallaRegistro> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _correoController = TextEditingController();
  final TextEditingController _claveController = TextEditingController();

  Future<void> _guardarDatos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("nombre", _nombreController.text);
    await prefs.setString("apellido", _apellidoController.text);
    await prefs.setString("correo", _correoController.text);
    await prefs.setString("clave", _claveController.text);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Registro guardado con éxito")),
    );

    Navigator.pop(context); // volver a login
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(height: 40, color: Colors.grey[700]),
          const SizedBox(height: 40),

          const Text(
            "Registro",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _nombreController,
              decoration: const InputDecoration(labelText: "Nombre"),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _apellidoController,
              decoration: const InputDecoration(labelText: "Apellido"),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _correoController,
              decoration: const InputDecoration(labelText: "Correo"),
            ),
          ),
          const SizedBox(height: 10),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: TextField(
              controller: _claveController,
              decoration: const InputDecoration(labelText: "Contraseña"),
              obscureText: true,
            ),
          ),
          const SizedBox(height: 20),

          ElevatedButton(
            onPressed: _guardarDatos,
            child: const Text("Guardar"),
          ),

          const Spacer(),
          Container(height: 40, color: Colors.grey[700]),
        ],
      ),
    );
  }
}

// ---------------- Pantalla Inicio (post login) ----------------
class PantallaInicio extends StatelessWidget {
  const PantallaInicio({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(height: 40, color: Colors.grey[700]),
          const Expanded(
            child: Center(
              child: Text(
                "Pantalla de Inicio",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(height: 40, color: Colors.grey[700]),
        ],
      ),
    );
  }
}

// ---------------- Pantalla Invitado ----------------
class PantallaInvitado extends StatelessWidget {
  const PantallaInvitado({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(height: 40, color: Colors.grey[700]),
          const Expanded(
            child: Center(
              child: Text(
                "Modo invitado (pantalla en blanco)",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(height: 40, color: Colors.grey[700]),
        ],
      ),
    );
  }
}

// ---------------- Pantalla Historial ----------------
class PantallaHistorial extends StatelessWidget {
  const PantallaHistorial({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Container(height: 40, color: Colors.grey[700]),
          const Expanded(
            child: Center(
              child: Text(
                "Historial (en blanco)",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          Container(height: 40, color: Colors.grey[700]),
        ],
      ),
    );
  }
}
