import 'dart:math' show max;

// Sistema de unidades disponible
enum SistemaUnidad { metrico, imperial }

//---------- Helpers de conversión ----------
//son funciones auxiliares para convertir entre unidades métricas e imperiales
double kgToLb(double kg) => kg / 0.453592;
double lbToKg(double lb) => lb * 0.453592;

double cmToIn(double cm) => cm / 2.54;
double inToCm(double inch) => inch * 2.54;

// Parseo seguro que acepta coma o punto como separador decimal.
// Retorna null si no puede parsear.
double? parseNumero(String texto) {
  if (texto.trim().isEmpty) return null;
  final normalizado = texto.trim().replaceAll(',', '.');
  return double.tryParse(normalizado);
}

// devuelve string formateado o vacío si es null
String formatDouble(double? v, {int decimales = 2}) =>
    v == null ? "" : v.toStringAsFixed(decimales);

// ---------- Cálculo de IMC ----------
double calcularIMC({
  required double peso,
  required double altura,
  required bool esMetrico, // true: kg/cm, false: lbs/in
}) {
  // Evitar divisiones por cero / resultados inválidos
  if (peso <= 0 || altura <= 0) return double.nan;

  if (esMetrico) {
    final alturaM = altura / 100.0; // cm → m
    return peso / (alturaM * alturaM);
  } else {
    // Fórmula para lbs/in: IMC = 703 * peso(lbs) / altura(in)^2
    return 703.0 * peso / (altura * altura);
  }
}

// ---------- Clasificación estándar ----------
String clasificarIMC(double imc) {
  if (imc.isNaN || imc.isInfinite) return "";
  if (imc < 18.5) return "Bajo peso";
  if (imc <= 24.9) return "Normal";
  if (imc <= 29.9) return "Sobrepeso";
  return "Obesidad";
}

// ---------- Recomendaciones por categoría ----------
String recomendacionesSalud(String categoria) {
  switch (categoria) {
    case "Bajo peso":
      return "Consulta a tu médico para aumentar de peso de forma segura.";
    case "Normal":
      return "Mantené hábitos saludables de alimentación y actividad física.";
    case "Sobrepeso":
    case "Obesidad":
      return "Mejorá tu alimentación y realizá actividad física regularmente.";
    default:
      return "";
  }
}

// ---------- Actualización de valores base  ----------
// Devuelve [pesoBaseKg, alturaBaseCm] siempre en sistema métrico.
List<double?> actualizarValoresBase({
  required String pesoTexto,
  required String alturaTexto,
  required bool esMetrico, // true = kg/cm, false = lbs/in
}) {
  final pesoRaw = parseNumero(pesoTexto);
  final alturaRaw = parseNumero(alturaTexto);

  double? pesoBaseKg;
  double? alturaBaseCm;

  if (pesoRaw != null) {
    pesoBaseKg = esMetrico ? pesoRaw : lbToKg(pesoRaw);
  }
  if (alturaRaw != null) {
    alturaBaseCm = esMetrico ? alturaRaw : inToCm(alturaRaw);
  }

  return [pesoBaseKg, alturaBaseCm];
}

//---------- Helpers adicionales opcionale---------

// A partir de valores base (kg/cm) devuelve lo que debe mostrarse
// en UI según `esMetrico` (kg|lb, cm|in).
({double? pesoVisible, double? alturaVisible}) valoresVisiblesDesdeBase({
  required double? pesoBaseKg,
  required double? alturaBaseCm,
  required bool esMetrico,
  int decimales = 2,
}) {
  double? pesoVisible;
  double? alturaVisible;

  if (pesoBaseKg != null) {
    pesoVisible = esMetrico ? pesoBaseKg : kgToLb(pesoBaseKg);
    // redondeo a n decimales sin cambiar tipo
    final factor = pow10(decimales);
    pesoVisible = (pesoVisible * factor).round() / factor;
  }
  if (alturaBaseCm != null) {
    alturaVisible = esMetrico ? alturaBaseCm : cmToIn(alturaBaseCm);
    final factor = pow10(decimales);
    alturaVisible = (alturaVisible * factor).round() / factor;
  }

  return (pesoVisible: pesoVisible, alturaVisible: alturaVisible);
}

// Calcula IMC **siempre** desde base métrica (kg/cm) para evitar errores.
// Retorna NaN si faltan datos.
double calcularIMCDesdeBase({
  required double? pesoBaseKg,
  required double? alturaBaseCm,
}) {
  if (pesoBaseKg == null || alturaBaseCm == null) return double.nan;
  if (pesoBaseKg <= 0 || alturaBaseCm <= 0) return double.nan;
  final alturaM = alturaBaseCm / 100.0;
  return pesoBaseKg / (alturaM * alturaM);
}

// Protege contra strings vacíos y alturas/pesos no válidos.
//Útil antes de habilitar el botón "Calcular".
bool inputsSonValidos({
  required String pesoTexto,
  required String alturaTexto,
  required bool esMetrico,
}) {
  final vals = actualizarValoresBase(
    pesoTexto: pesoTexto,
    alturaTexto: alturaTexto,
    esMetrico: esMetrico,
  );
  final kg = vals[0];
  final cm = vals[1];
  return (kg != null && kg > 0) && (cm != null && cm > 0);
}

// ayuda a el redondeo a n decimales
double pow10(int n) {
  n = max(0, n);
  var v = 1.0;
  for (var i = 0; i < n; i++) {
    v *= 10.0;
  }
  return v;
}

