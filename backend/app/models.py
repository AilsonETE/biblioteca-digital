from . import db

class Livro(db.Model):
    id = db.Column(db.Integer, primary_key=True)
    titulo = db.Column(db.String(200), nullable=False)
    sinopse = db.Column(db.Text, nullable=False)
    categoria = db.Column(db.String(100), nullable=False)
    imagem = db.Column(db.String(200))  # Caminho da imagem
    pdf = db.Column(db.String(200))     # Caminho do PDF
