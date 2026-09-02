from starlette.middleware.base import BaseHTTPMiddleware
from fastapi import Request
import logging

logger = logging.getLogger("osteoguard.audit")

class AuditMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        client_ip = request.client.host if request.client else "unknown"
        method = request.method
        path = request.url.path

        response = await call_next(request)

        # Log state-modifying requests
        if method in ["POST", "PUT", "PATCH", "DELETE"]:
            logger.info(
                f"[AUDIT] {method} {path} - Status: {response.status_code} - IP: {client_ip}"
            )

        return response
