import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:app_bmi/datos/firebase/usuario_registo.dart';

class HistorialView extends StatefulWidget {
  const HistorialView({super.key});

  @override
  State<HistorialView> createState() => _HistorialViewState();
}

class _HistorialViewState extends State<HistorialView> {
  final _repo = UsuarioRegisto();

  String _fmtNum(num? n, {int dec = 2}) {
    if (n == null) return '--';
    return n.toStringAsFixed(dec);
  }

  String _fmtFecha(Timestamp? ts) {
    final dt = ts?.toDate();
    if (dt == null) return '';
    final two = (int v) => v.toString().padLeft(2, '0');
    return '${two(dt.day)}/${two(dt.month)}/${dt.year} ${two(dt.hour)}:${two(dt.minute)}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial de IMC')),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: _repo.registrosStream(), // ← nube como fuente de verdad
        builder: (context, snapshot) {
          // Loading
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          // Error
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error al cargar el historial: ${snapshot.error}',
                textAlign: TextAlign.center,
              ),
            );
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const Center(
              child: Text(
                'No hay registros en el historial.',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: docs.length,
            itemBuilder: (context, index) {
              final d = docs[index].data();
              // Campos esperados (con defaults defensivos)
              final imc = (d['imc'] ?? 0).toDouble();
              final categoria = (d['categoria'] ?? '') as String;
              final pesoVisible = (d['pesoVisible'] ?? 0).toDouble();
              final alturaVisible = (d['alturaVisible'] ?? 0).toDouble();
              final esMetricoVisible = (d['esMetricoVisible'] ?? true) as bool;
              final createdAt = d['createdAt'] as Timestamp?;
              final fechaStr = _fmtFecha(createdAt);
              final unidadPeso = esMetricoVisible ? 'kg' : 'lb';
              final unidadAltura = esMetricoVisible ? 'cm' : 'in';
              return Card(
                elevation: 3,
                margin: const EdgeInsets.symmetric(vertical: 6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue.shade100,
                    child: Text(
                      _fmtNum(imc, dec: 1), // IMC en el avatar
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ),
                  title: Text('IMC: ${_fmtNum(imc, dec: 2)}  •  $categoria'),
                  subtitle: Text(
                    'Peso: ${_fmtNum(pesoVisible, dec: 1)} $unidadPeso | '
                    'Altura: ${_fmtNum(alturaVisible, dec: 1)} $unidadAltura\n'
                    '$fechaStr',
                  ),
                  trailing: IconButton(
                    tooltip: 'Eliminar registro',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () async {
                      await _repo.eliminarRegistro(docs[index].id);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
