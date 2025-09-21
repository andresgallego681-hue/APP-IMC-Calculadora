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