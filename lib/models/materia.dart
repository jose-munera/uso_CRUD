class Materia {
  final String id;
  final String nombre;
  final String semestre;
  final int creditos;

  const Materia({
    required this.id,
    required this.nombre,
    required this.semestre,
    required this.creditos,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'semestre': semestre,
      'creditos': creditos,
    };
  }

  factory Materia.fromJson(Map<String, dynamic> json) {
    return Materia(
      id: json['id'],
      nombre: json['nombre'],
      semestre: json['semestre'],
      creditos: json['creditos'],
    );
  }
}