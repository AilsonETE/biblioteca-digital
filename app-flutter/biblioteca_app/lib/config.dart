class AppConfig {
  static const bool isProd = false; // 👈 Mude para `true` para produção

  static String get baseUrl => isProd
      ? 'https://appbiblioteca.etegaranhuns.com.br'
      : 'http://192.168.0.209:5000';

  static String get apiLivrosUrl => '$baseUrl/api/livros';

  static String staticUrl(String path) => '$baseUrl/static/uploads/$path';
}
