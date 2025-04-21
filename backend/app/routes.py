from flask import Blueprint, render_template, request, redirect, url_for
from werkzeug.utils import secure_filename
import os
from . import db
from .models import Livro

main = Blueprint('main', __name__)

@main.route('/')
def index():
    busca = request.args.get('busca', '')
    categoria = request.args.get('categoria', '')

    query = Livro.query

    if busca:
        query = query.filter(Livro.titulo.ilike(f'%{busca}%'))
    if categoria:
        query = query.filter(Livro.categoria == categoria)

    livros = query.all()
    categorias = db.session.query(Livro.categoria).distinct().all()

    return render_template('adminlte/listar_livros.html', livros=livros, categorias=categorias, busca=busca, categoria=categoria)



@main.route('/novo', methods=['GET', 'POST'])
def novo_livro():
    if request.method == 'POST':
        titulo = request.form['titulo']
        sinopse = request.form['sinopse']
        categoria = request.form['categoria']
        imagem = request.files['imagem']
        pdf = request.files['pdf']

        imagem_filename = secure_filename(imagem.filename)
        pdf_filename = secure_filename(pdf.filename)

        # Pasta de uploads
        upload_path = os.path.join('app', 'static', 'uploads')
        os.makedirs(upload_path, exist_ok=True)

        imagem.save(os.path.join(upload_path, imagem_filename))
        pdf.save(os.path.join(upload_path, pdf_filename))

        novo = Livro(
            titulo=titulo,
            sinopse=sinopse,
            categoria=categoria,
            imagem=imagem_filename,
            pdf=pdf_filename
        )
        db.session.add(novo)
        db.session.commit()

        return redirect(url_for('main.index'))

    return render_template('adminlte/novo_livro.html')

@main.route('/livro/<int:id>')
def ver_livro(id):
    livro = Livro.query.get_or_404(id)
    return render_template('adminlte/ver_livro.html', livro=livro)


@main.route('/editar/<int:id>', methods=['GET', 'POST'])
def editar_livro(id):
    livro = Livro.query.get_or_404(id)

    if request.method == 'POST':
        livro.titulo = request.form['titulo']
        livro.sinopse = request.form['sinopse']
        livro.categoria = request.form['categoria']

        if 'imagem' in request.files and request.files['imagem'].filename:
            imagem = request.files['imagem']
            imagem_filename = secure_filename(imagem.filename)
            imagem.save(os.path.join('app/static/uploads', imagem_filename))
            livro.imagem = imagem_filename

        if 'pdf' in request.files and request.files['pdf'].filename:
            pdf = request.files['pdf']
            pdf_filename = secure_filename(pdf.filename)
            pdf.save(os.path.join('app/static/uploads', pdf_filename))
            livro.pdf = pdf_filename

        db.session.commit()
        return redirect(url_for('main.index'))

    return render_template('adminlte/editar_livro.html', livro=livro)

@main.route('/excluir/<int:id>', methods=['POST'])
def excluir_livro(id):
    livro = Livro.query.get_or_404(id)
    db.session.delete(livro)
    db.session.commit()
    return redirect(url_for('main.index'))