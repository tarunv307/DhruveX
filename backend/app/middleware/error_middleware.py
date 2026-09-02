import uuid
from fastapi import Request, status
from fastapi.responses import JSONResponse
from starlette.middleware.base import BaseHTTPMiddleware
from app.schemas.schemas import ErrorResponse, ApiError, ApiErrorDetail

class ErrorHandlingMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next):
        request_id = str(uuid.uuid4())
        request.state.request_id = request_id

        try:
            response = await call_next(request)
            response.headers["X-Request-ID"] = request_id
            return response
        except Exception as exc:
            # Handle unhandled errors
            error_response = ErrorResponse(
                success=False,
                error=ApiError(
                    code="INTERNAL_SERVER_ERROR",
                    message="An unexpected server error occurred. Please contact system support.",
                    details=[ApiErrorDetail(issue=str(exc))]
                ),
                request_id=request_id
            )
            return JSONResponse(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                content=error_response.model_dump(),
                headers={"X-Request-ID": request_id}
            )
