class Nota {
  final double valor;
  final double porcentaje;

  const Nota({
    required this.valor,
    required this.porcentaje,
  });

  Map<String, dynamic> toJson() {
    return {
      'valor': valor,
      'porcentaje': porcentaje,
    };
  }

  factory Nota.fromJson(Map<String, dynamic> json) {
    return Nota(
      valor: json['valor'].toDouble(),
      porcentaje: json['porcentaje'].toDouble(),
    );
  }
}