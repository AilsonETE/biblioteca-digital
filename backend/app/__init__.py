from flask import Flask
from flask_sqlalchemy import SQLAlchemy
from flask_migrate import Migrate
from flask_cors import CORS
import os

# Instância global do banco
db = SQLAlchemy()

def create_app():
    # Criação da aplicação
    app = Flask(__name__)

    # Configurações básicas
    app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///biblioteca.db'
    app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False  # Evita warning
    app.config['UPLOAD_FOLDER'] = os.path.join(app.root_path, 'static', 'uploads')
    app.config['SECRET_KEY'] = 'segredo'

    # Inicialização de extensões
    db.init_app(app)
    migrate = Migrate(app, db)  # Necessário atribuir a uma variável se quiser usar comandos do Flask-Migrate

    # Importação e registro das rotas
    from .routes import main
    from .api_routes import api
    app.register_blueprint(main)
    app.register_blueprint(api, url_prefix='/api')  # Adiciona um prefixo útil para organização

    # Ativação do CORS
    CORS(app)

    return app
