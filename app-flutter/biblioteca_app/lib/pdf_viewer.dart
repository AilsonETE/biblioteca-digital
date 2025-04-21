import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class PDFViewerPage extends StatelessWidget {
  final String url;
  final String titulo;

  const PDFViewerPage({super.key, required this.url, required this.titulo});

  Future<void> _baixarPDF(BuildContext context) async {
    try {
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/${titulo.replaceAll(" ", "_")}.pdf';

      await Dio().download(url, path);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Arquivo salvo em: ${path.split("/").last}')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao baixar PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(titulo),
        actions: [
          IconButton(
            icon: Icon(Icons.download),
            onPressed: () => _baixarPDF(context),
            tooltip: 'Baixar PDF',
          ),
        ],
      ),
      body: SfPdfViewer.network(url),
    );
  }
}
