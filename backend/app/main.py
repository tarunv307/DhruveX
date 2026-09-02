from fastapi import FastAPI, status
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.config import settings
from app.database import Base, engine
from app.middleware import ErrorHandlingMiddleware, AuditMiddleware
from app.routers import (
    auth_router, patients_router, clinical_router, lifestyle_router,
    screenings_router, gait_router, risk_router, referrals_router,
    follow_ups_router, devices_router, sync_router, dashboard_router,
    reports_router
)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Initialize database tables on startup
    Base.metadata.create_all(bind=engine)
    yield

app = FastAPI(
    title="OSTEOGUARD-NER API",
    description=(
        "Production REST API for OSTEOGUARD-NER (DhruveX - SIH26004).\n\n"
        "**AI-Assisted Osteoarthritis Risk Screening & Clinical Decision Support.**\n\n"
        "⚠️ **Medical Disclaimer:** This application provides risk screening estimates "
        "and referral support. It does NOT make definitive diagnoses of osteoarthritis."
    ),
    version=settings.VERSION,
    openapi_url=f"{settings.API_V1_STR}/openapi.json",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan
)

# 1. Custom Middlewares
app.add_middleware(ErrorHandlingMiddleware)
app.add_middleware(AuditMiddleware)

# 2. CORS Middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.CORS_ORIGINS,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# 3. Mount Routers under /api/v1
api_v1_prefix = settings.API_V1_STR

app.include_router(auth_router, prefix=api_v1_prefix)
app.include_router(patients_router, prefix=api_v1_prefix)
app.include_router(clinical_router, prefix=api_v1_prefix)
app.include_router(lifestyle_router, prefix=api_v1_prefix)
app.include_router(screenings_router, prefix=api_v1_prefix)
app.include_router(gait_router, prefix=api_v1_prefix)
app.include_router(risk_router, prefix=api_v1_prefix)
app.include_router(referrals_router, prefix=api_v1_prefix)
app.include_router(follow_ups_router, prefix=api_v1_prefix)
app.include_router(devices_router, prefix=api_v1_prefix)
app.include_router(sync_router, prefix=api_v1_prefix)
app.include_router(dashboard_router, prefix=api_v1_prefix)
app.include_router(reports_router, prefix=api_v1_prefix)

# 4. Root & Health Check Endpoints
@app.get("/", tags=["System"])
def root():
    return {
        "project": "OSTEOGUARD-NER",
        "team": "DhruveX",
        "author": "TARUN V",
        "problem_statement": "SIH26004",
        "status": "online",
        "version": settings.VERSION,
        "docs": "/docs",
        "disclaimer": "AI-assisted screening support only. Not a medical diagnosis."
    }

@app.get("/health", tags=["System"])
@app.get(f"{api_v1_prefix}/health", tags=["System"])
def health_check():
    return {
        "status": "healthy",
        "environment": settings.ENVIRONMENT,
        "demo_mode": settings.ENABLE_DEMO_MODE,
        "model_provider": settings.MODEL_PROVIDER
    }
