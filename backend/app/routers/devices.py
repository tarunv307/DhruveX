from typing import List
from datetime import datetime, timezone
from fastapi import APIRouter, Depends, HTTPException, status
from sqlalchemy.orm import Session
from app.database import get_db
from app.models.entities import Device, User
from app.schemas.schemas import (
    DeviceRegister, DeviceHeartbeat, DeviceOut, ApiResponse
)
from app.dependencies import get_current_user

router = APIRouter(prefix="/devices", tags=["IoT Devices"])

@router.post("/register", response_model=ApiResponse[DeviceOut])
def register_device(
    device_in: DeviceRegister,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    existing = db.query(Device).filter(Device.device_mac == device_in.device_mac).first()
    if existing:
        existing.firmware_version = device_in.firmware_version
        existing.device_name = device_in.device_name
        existing.last_heartbeat = datetime.now(timezone.utc)
        db.commit()
        db.refresh(existing)
        return ApiResponse(data=DeviceOut.model_validate(existing), message="Device updated")

    device = Device(
        device_mac=device_in.device_mac,
        device_name=device_in.device_name,
        firmware_version=device_in.firmware_version
    )
    db.add(device)
    db.commit()
    db.refresh(device)
    return ApiResponse(data=DeviceOut.model_validate(device), message="Device registered")

@router.get("", response_model=ApiResponse[List[DeviceOut]])
def list_devices(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user)
):
    devices = db.query(Device).all()
    return ApiResponse(data=[DeviceOut.model_validate(d) for d in devices], message="Devices listed")

@router.post("/{device_id}/heartbeat", response_model=ApiResponse[bool])
def device_heartbeat(
    device_id: str,
    hb: DeviceHeartbeat,
    db: Session = Depends(get_db)
):
    device = db.query(Device).filter(Device.id == device_id).first()
    if not device:
        raise HTTPException(status_code=status.HTTP_404_NOT_FOUND, detail="Device not registered")

    device.battery_level = hb.battery_level
    if hb.firmware_version:
        device.firmware_version = hb.firmware_version
    device.last_heartbeat = datetime.now(timezone.utc)
    db.commit()

    return ApiResponse(data=True, message="Heartbeat received")
