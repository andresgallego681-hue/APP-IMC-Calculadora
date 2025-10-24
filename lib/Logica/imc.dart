double calcularIMC({
  required double peso,
  required double altura,
  required bool esMetrico, // true: kg/cm, false: lbs/in
}) {
  if (esMetrico) {
    final alturaM = altura / 100;
    return peso / (alturaM * alturaM);
  } else {
    // Fórmula para lbs/in: IMC = 703 * peso(lbs) / altura(in)^2
    return 703 * peso / (altura * altura);
  }
}

// Clasifica el IMC en categorías estándar
String clasificarIMC(double imc) {
  switch (imc) {
    case < 18.5:
      return "Bajo peso";
    case >= 18.5 && <= 24.9:
      return "Normal";
    case >= 25 && <= 29.9:
      return "Sobrepeso";
    default:
      return "Obesidad";
  }
}

// Proporciona recomendaciones de salud basadas en la categoría de IMC
String recomendacionesSalud(String categoria) {
  switch (categoria) {
    case "Bajo peso":
      return "Consulta a tu médico para aumentar de peso";
    case "Normal":
      return "Mantén tus hábitos saludables";
    case "Sobrepeso":
    case "Obesidad":
      return "Mejora tu alimentación y realiza actividad física";
    default:
      return "";
  }
}

/// Actualiza los valores base en sistema métrico
List<double?> actualizarValoresBase({
  required String pesoTexto,
  required String alturaTexto,
  required bool esMetrico, // true = métrico (kg/cm), false = imperial (lbs/in)
}) {
  final peso = double.tryParse(pesoTexto);
  final altura = double.tryParse(alturaTexto);

  double? pesoBase;
  double? alturaBase;

  if (peso != null) {
    pesoBase = esMetrico ? peso : peso * 0.453592; // lbs → kg
  }
  if (altura != null) {
    alturaBase = esMetrico ? altura : altura * 2.54; // in → cm
  }

  return [pesoBase, alturaBase];
}


