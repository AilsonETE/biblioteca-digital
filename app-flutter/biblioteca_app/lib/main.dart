import 'package:flutter/material.dart';
import 'models/livro.dart';
import 'services/livro_service.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'pdf_viewer.dart';
import 'config.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Biblioteca Digital',
    theme: ThemeData.dark(useMaterial3: true),
    home: BibliotecaHome(),
  ));
}

class BibliotecaHome extends StatefulWidget {
  @override
  _BibliotecaHomeState createState() => _BibliotecaHomeState();
}

class _BibliotecaHomeState extends State<BibliotecaHome> {
  List<Livro> livros = [];
  List<Livro> filtrados = [];
  List<Livro> favoritos = [];
  Set<int> favoritosIds = <int>{};
  String categoriaSelecionada = 'Todos';
  int _indiceMenu = 0;

  @override
  void initState() {
    super.initState();
    carregarLivros();
  }

  void carregarLivros() async {
    try {
      final resultado = await LivroService.fetchLivros();
      setState(() {
        livros = resultado;
        filtrados = resultado;
      });
      await carregarFavoritosSalvos();
    } catch (e) {
      print("Erro ao carregar livros: $e");
    }
  }

  Future<void> carregarFavoritosSalvos() async {
    final prefs = await SharedPreferences.getInstance();
    final ids = prefs.getStringList('favoritos') ?? [];
    final idsConvertidos = ids.map(int.parse).toSet();
    setState(() {
      favoritosIds = idsConvertidos;
      favoritos = livros.where((l) => favoritosIds.contains(l.id)).toList();
    });
  }

  Future<void> salvarFavoritos() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(
      'favoritos',
      favoritosIds.map((id) => id.toString()).toList(),
    );
  }

  void filtrarPorCategoria(String categoria) {
    setState(() {
      categoriaSelecionada = categoria;
      if (categoria == 'Todos') {
        filtrados = livros;
      } else {
        filtrados = livros.where((l) => l.categoria == categoria).toList();
      }
    });
  }

  void alternarFavorito(Livro livro) async {
    setState(() {
      if (favoritosIds.contains(livro.id)) {
        favoritosIds.remove(livro.id);
        favoritos.removeWhere((l) => l.id == livro.id);
      } else {
        favoritosIds.add(livro.id);
        favoritos.add(livro);
      }
    });
    await salvarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    final categorias = [
      'Todos',
      ...{...livros.map((l) => l.categoria)}
    ];
    final livrosExibidos = _indiceMenu == 0 ? filtrados : favoritos;

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: [
          SafeArea(
            child: Container(
              height: 140,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/header.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          if (_indiceMenu == 0) ...[
            SizedBox(height: 10),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final cat = categorias[index];
                  final ativo = cat == categoriaSelecionada;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: ChoiceChip(
                      label: Text(cat),
                      selected: ativo,
                      onSelected: (_) => filtrarPorCategoria(cat),
                    ),
                  );
                },
              ),
            ),
          ],
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: livrosExibidos.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.64,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemBuilder: (context, index) {
                final livro = livrosExibidos[index];
                final urlImagem =
                    'https://appbiblioteca.etegaranhuns.com.br/static/uploads/${livro.imagem}';
                final urlPDF =
                    'https://appbiblioteca.etegaranhuns.com.br/static/uploads/${livro.pdf}';
                final ehFavorito = favoritosIds.contains(livro.id);

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            PDFViewerPage(url: urlPDF, titulo: livro.titulo),
                      ),
                    );
                  },
                  child: Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    color: Colors.white,
                    elevation: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(
                          child: Stack(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.vertical(
                                  top: Radius.circular(10),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: urlImagem,
                                  placeholder: (_, __) => Center(
                                      child: CircularProgressIndicator()),
                                  errorWidget: (_, __, ___) =>
                                      Icon(Icons.broken_image),
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: IconButton(
                                  icon: Icon(
                                    ehFavorito
                                        ? Icons.favorite
                                        : Icons.favorite_border,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () => alternarFavorito(livro),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                livro.titulo,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                livro.categoria,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _indiceMenu,
        onTap: (index) => setState(() => _indiceMenu = index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.menu_book),
            label: 'Todos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'Favoritos',
          ),
        ],
      ),
    );
  }
}
