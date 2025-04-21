from flask import Blueprint, jsonify, request
from .models import Livro
from . import db
import os
from werkzeug.utils import secure_filename

api = Blueprint('api', __name__)

# Listar todos os livros
@api.route('/api/livros', methods=['GET'])
def api_listar_livros():
    livros = Livro.query.all()
    return jsonify([
        {
            'id': l.id,
            'titulo': l.titulo,
            'sinopse': l.sinopse,
            'categoria': l.categoria,
            'imagem': l.imagem,
            'pdf': l.pdf
        } for l in livros
    ])

# Detalhes de um livro
@api.route('/api/livros/<int:id>', methods=['GET'])
def api_ver_livro(id):
    livro = Livro.query.get_or_404(id)
    return jsonify({
        'id': livro.id,
        'titulo': livro.titulo,
        'sinopse': livro.sinopse,
        'categoria': livro.categoria,
        'imagem': livro.imagem,
        'pdf': livro.pdf
    })

# Criar novo livro
@api.route('/api/livros', methods=['POST'])
def api_criar_livro():
    data = request.form
    imagem = request.files.get('imagem')
    pdf = request.files.get('pdf')

    imagem_filename = secure_filename(imagem.filename) if imagem else None
    pdf_filename = secure_filename(pdf.filename) if pdf else None

    upload_path = os.path.join('app', 'static', 'uploads')
    os.makedirs(upload_path, exist_ok=True)

    if imagem:
        imagem.save(os.path.join(upload_path, imagem_filename))
    if pdf:
        pdf.save(os.path.join(upload_path, pdf_filename))

    novo = Livro(
        titulo=data.get('titulo'),
        sinopse=data.get('sinopse'),
        categoria=data.get('categoria'),
        imagem=imagem_filename,
        pdf=pdf_filename
    )
    db.session.add(novo)
    db.session.commit()

    return jsonify({'message': 'Livro criado com sucesso', 'id': novo.id}), 201

# Atualizar livro
@api.route('/api/livros/<int:id>', methods=['PUT'])
def api_atualizar_livro(id):
    livro = Livro.query.get_or_404(id)
    data = request.form
    imagem = request.files.get('imagem')
    pdf = request.files.get('pdf')

    livro.titulo = data.get('titulo', livro.titulo)
    livro.sinopse = data.get('sinopse', livro.sinopse)
    livro.categoria = data.get('categoria', livro.categoria)

    upload_path = os.path.join('app', 'static', 'uploads')
    os.makedirs(upload_path, exist_ok=True)

    if imagem:
        imagem_filename = secure_filename(imagem.filename)
        imagem.save(os.path.join(upload_path, imagem_filename))
        livro.imagem = imagem_filename

    if pdf:
        pdf_filename = secure_filename(pdf.filename)
        pdf.save(os.path.join(upload_path, pdf_filename))
        livro.pdf = pdf_filename

    db.session.commit()
    return jsonify({'message': 'Livro atualizado com sucesso'})

# Excluir livro
@api.route('/api/livros/<int:id>', methods=['DELETE'])
def api_excluir_livro(id):
    livro = Livro.query.get_or_404(id)
    db.session.delete(livro)
    db.session.commit()
    return jsonify({'message': 'Livro excluído com sucesso'})
