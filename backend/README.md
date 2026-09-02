# OSTEOGUARD-NER Backend

FastAPI, SQLAlchemy 2.x, PostgreSQL, PostGIS-ready, JWT RBAC, Risk Engine, Offline Sync & PDF Reporting.

---

## 🚀 Quick Start (Docker)

```bash
docker-compose up -d --build
```
Access the interactive Swagger UI at: `http://localhost:8000/docs`

---

## 🛠️ Local Development (Bare Metal)

1. Create and activate a Python virtual environment:
   ```bash
   python3 -m venv .venv
   source .venv/bin/activate
   ```
2. Install dependencies:
   ```bash
   pip install -r requirements.txt
   ```
3. Copy environment configuration:
   ```bash
   cp .env.example .env
   ```
4. Run database migrations:
   ```bash
   alembic upgrade head
   ```
5. Run the FastAPI development server:
   ```bash
   uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
   ```

---

## 🧪 Running Tests

```bash
pytest -v
```
