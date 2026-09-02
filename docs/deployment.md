# OSTEOGUARD-NER Deployment Guide

**DhruveX** | Infrastructure & Production Setup

---

## 1. Prerequisites

- **Docker & Docker Compose** (v24+)
- **Python 3.12+**
- **Flutter SDK 3.19+**
- **PostgreSQL 16** with PostGIS extension (if running bare metal)

---

## 2. Dockerized Backend Deployment

### Start Stack (FastAPI + PostgreSQL + Redis)
```bash
cd backend
docker-compose up -d --build
```

### Run Migrations
```bash
docker-compose exec api alembic upgrade head
```

### Access Services
- **Interactive Swagger UI**: `http://localhost:8000/docs`
- **ReDoc Documentation**: `http://localhost:8000/redoc`
- **Health Check**: `http://localhost:8000/health`
- **Postgres Database**: `localhost:5432` (`osteoguard`)

---

## 3. Production Hardening Checklist

- [x] Set strong `SECRET_KEY` in production `.env`
- [x] Enable SSL/TLS termination via Nginx / Traefik reverse proxy
- [x] Set restrictive `CORS_ORIGINS`
- [x] Configure database connection pooling with health checks
- [x] Automated daily PostgreSQL pg_dump backups
- [x] Enable rate limiting on authentication routes
