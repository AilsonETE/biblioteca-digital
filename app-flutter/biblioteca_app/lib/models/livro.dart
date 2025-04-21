class Livro {
  final int id;
  final String titulo;
  final String sinopse;
  final String categoria;
  final String imagem;
  final String pdf;

  Livro({
    required this.id,
    required this.titulo,
    required this.sinopse,
    required this.categoria,
    required this.imagem,
    required this.pdf,
  });

  factory Livro.fromJson(Map<String, dynamic> json) {
    return Livro(
      id: json['id'],
      titulo: json['titulo'],
      sinopse: json['sinopse'],
      categoria: json['categoria'],
      imagem: json['imagem'],
      pdf: json['pdf'],
    );
  }
}
