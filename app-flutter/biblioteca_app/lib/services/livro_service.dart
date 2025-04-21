import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/livro.dart';

class LivroService {
  static const String baseUrl =
      'https://appbiblioteca.etegaranhuns.com.br/api/api/livros';
  //'http://192.168.0.209:5000/api/api/livros'; // troque pelo IP real

  static Future<List<Livro>> fetchLivros() async {
    final response = await http.get(Uri.parse(baseUrl));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((json) => Livro.fromJson(json)).toList();
    } else {
      throw Exception('Erro ao carregar livros');
    }
  }
}
