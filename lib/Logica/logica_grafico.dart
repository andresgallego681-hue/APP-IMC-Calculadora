import 'dart:convert';

class GraficoIMCLogic {
  /// Construye la URL del gráfico (QuickChart/Chart.js)
  String buildChartUrl({
    required List<String> labels,
    required List<num> values,
  }) {
    final chartConfig = {
      'type': 'line',
      'data': {
        'labels': labels,
        'datasets': [
          {
            'label': 'IMC',
            'data': values,
            'fill': false,
            'tension': 0.25,
          },
        ],
      },
      'options': {
        'plugins': {
          'legend': {'display': false}
        },
        'scales': {
          'y': {
            'suggestedMin': 10,
            'suggestedMax': 40,
          }
        }
      }
    };

    final encoded = Uri.encodeComponent(jsonEncode(chartConfig));
    return 'https://quickchart.io/chart?c=$encoded&w=1000&h=500&devicePixelRatio=2';
  }

  /// Recibe pares (imc, date) y devuelve labels/values listos para graficar.
  Map<String, List> buildSeriesFromPairs(List<({double imc, DateTime date})> data) {
    data.sort((a, b) => a.date.compareTo(b.date));

    final labels = <String>[];
    final values = <num>[];

    for (final it in data) {
      final d = it.date;
      final label =
          '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')} '
          '${d.hour.toString().padLeft(2, '0')}:${d.minute.toString().padLeft(2, '0')}';
      labels.add(label);
      values.add(it.imc);
    }

    return {'labels': labels, 'values': values};
  }
}
