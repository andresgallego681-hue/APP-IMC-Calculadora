import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_bmi/datos/firebase/usuario_registo.dart';
import 'package:app_bmi/logica/logica_grafico.dart';

class GraficoIMCView extends StatefulWidget {
  const GraficoIMCView({super.key});

  @override
  State<GraficoIMCView> createState() => _GraficoIMCViewState();
}

class _GraficoIMCViewState extends State<GraficoIMCView> {
  final _repo = UsuarioRegisto();
  final _logic = GraficoIMCLogic();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Evolución del IMC"),
        backgroundColor: Colors.orange,
      ),
      backgroundColor: const Color(0xFFFFF3F3),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repo.registrosStream(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Text(
                "❌ Error: ${snapshot.error}",
                style: const TextStyle(color: Colors.red),
              ),
            );
          }

          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          // Mapear snapshot → lista de pares (imc, fecha)
          final pairs = <({double imc, DateTime date})>[];
          for (final doc in snapshot.data!.docs) {
            final data = doc.data();
            final imcRaw = data['imc'];
            final ts = data['createdAt'];

            if (imcRaw == null) continue;
            if (ts is! Timestamp) continue; // aún sin serverTimestamp

            final imc = (imcRaw as num).toDouble();
            final date = ts.toDate();

            pairs.add((imc: imc, date: date));
          }

          if (pairs.isEmpty) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  "Aún no hay registros de IMC.\nCalculá tu primer IMC para ver la evolución.",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          final series = _logic.buildSeriesFromPairs(pairs);
          final labels = (series['labels'] as List).cast<String>();
          final values = (series['values'] as List).cast<num>();

          final chartUrl = _logic.buildChartUrl(labels: labels, values: values);

          return Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Image.network(
                      chartUrl,
                      width: MediaQuery.of(context).size.width * 0.95,
                      height: MediaQuery.of(context).size.height * 0.6,
                      fit: BoxFit.contain,
                      headers: const {"Cache-Control": "no-cache"},
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'Registros: ${values.length}  ·  IMC actual: ${values.last.toStringAsFixed(1)}',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
