from app.routers.auth import router as auth_router
from app.routers.patients import router as patients_router
from app.routers.clinical import router as clinical_router
from app.routers.lifestyle import router as lifestyle_router
from app.routers.screenings import router as screenings_router
from app.routers.gait import router as gait_router
from app.routers.risk import router as risk_router
from app.routers.referrals import router as referrals_router
from app.routers.follow_ups import router as follow_ups_router
from app.routers.devices import router as devices_router
from app.routers.sync import router as sync_router
from app.routers.dashboard import router as dashboard_router
from app.routers.reports import router as reports_router

__all__ = [
    "auth_router",
    "patients_router",
    "clinical_router",
    "lifestyle_router",
    "screenings_router",
    "gait_router",
    "risk_router",
    "referrals_router",
    "follow_ups_router",
    "devices_router",
    "sync_router",
    "dashboard_router",
    "reports_router",
]
