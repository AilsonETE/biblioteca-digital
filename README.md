#  Biblioteca Digital

Projeto multiplataforma composto por:

- `app-flutter`: Aplicativo mobile Flutter
- `backend`: API REST desenvolvida com Flask
- `frontend`: (reservado para futuras interfaces web)

---

##  Como rodar o backend (Flask)

### 1. Pré-requisitos
- Python 3.10+
- pip (gerenciador de pacotes)
- Virtualenv (opcional, mas recomendado)

### 2. Configuração

```bash
# Acesse a pasta do backend
cd backend

# (Opcional) Crie um ambiente virtual
python -m venv venv
source venv/bin/activate  # Linux/macOS
venv\Scripts\activate     # Windows

# Instale as dependências
pip install -r requirements.txt

# Com Flask CLI no terminal
export FLASK_APP=app.py       # Linux/macOS
set FLASK_APP=app.py          # Windows

flask run


📱 Como rodar o app Flutter
1. Pré-requisitos
Flutter SDK instalado (https://docs.flutter.dev/get-started/install)

Um emulador Android ou dispositivo físico

IDE (VS Code ou Android Studio)

# Acesse a pasta do app
cd app-flutter

# Instale as dependências
flutter pub get

# Execute no dispositivo/emulador
flutter run
