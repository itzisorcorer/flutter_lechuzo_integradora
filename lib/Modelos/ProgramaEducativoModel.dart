class ProgramaEducativoModel {
  final int id;
  final String nombre;

  ProgramaEducativoModel({required this.id, required this.nombre});

  factory ProgramaEducativoModel.fromJson(Map<String, dynamic> json) {
    return ProgramaEducativoModel(
      id: json['id'],
      nombre: json['nombre'],
    );
  }
}