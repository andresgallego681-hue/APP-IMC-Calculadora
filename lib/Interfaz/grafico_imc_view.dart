import 'package:flutter/material.dart';
import '../datos/grafico.dart';

class GraficoIMCView extends StatefulWidget {
  const GraficoIMCView({super.key});

  @override
  State<GraficoIMCView> createState() => _GraficoIMCViewState();
}

class _GraficoIMCViewState extends State<GraficoIMCView> {
  String? chartUrl;
  bool cargando = true;
  String? errorMensaje;

  @override
  void initState() {
    super.initState();
    _cargarGrafico();
  }

  Future<void> _cargarGrafico() async {
    try {
      final url = await GraficoIMC.generarGraficoIMC();
      setState(() {
        chartUrl = url;
        cargando = false;
      });
    } catch (e) {
      setState(() {
        errorMensaje = e.toString();
        cargando = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evolución del IMC"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF3F3), // fondo suave
      body: cargando
          ? const Center(child: CircularProgressIndicator())
          : errorMensaje != null
              ? Center(
                  child: Text(
                    "❌ Error: $errorMensaje",
                    style: const TextStyle(color: Colors.red),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: Center(
                        child: chartUrl != null
                            ? SingleChildScrollView(
                                child: Image.network(
                                  chartUrl!,
                                  width:
                                      MediaQuery.of(context).size.width * 0.95, // 95% del ancho
                                  height:
                                      MediaQuery.of(context).size.height * 0.6, // 60% del alto
                                  fit: BoxFit.contain,
                                ),
                              )
                            : const Text("No se pudo cargar el gráfico."),
                      ),
                    ),
                    const SizedBox(height: 10),
                    
                  ],
                ),
    );
  }
}

