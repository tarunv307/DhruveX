# OSTEOGUARD-NER Bluetooth Low Energy (BLE) Protocol

**DhruveX** | Hardware: **ESP32-S3 + Dual 6-Axis IMUs** (Thigh & Shin)

---

## 1. GATT Service and Characteristic UUIDs

```ini
OSTEO_SERVICE_UUID                = "6E400001-B5A3-F393-E0A9-E50E24DCCA9E"
SENSOR_STATUS_CHARACTERISTIC_UUID = "6E400002-B5A3-F393-E0A9-E50E24DCCA9E" (Read, Notify)
THIGH_DATA_CHARACTERISTIC_UUID    = "6E400003-B5A3-F393-E0A9-E50E24DCCA9E" (Notify)
SHIN_DATA_CHARACTERISTIC_UUID     = "6E400004-B5A3-F393-E0A9-E50E24DCCA9E" (Notify)
COMMAND_CHARACTERISTIC_UUID       = "6E400005-B5A3-F393-E0A9-E50E24DCCA9E" (Write)
RESULT_CHARACTERISTIC_UUID        = "6E400006-B5A3-F393-E0A9-E50E24DCCA9E" (Read, Notify)
BATTERY_CHARACTERISTIC_UUID       = "00002A19-0000-1000-8000-00805F9B34FB" (Read, Notify)
FIRMWARE_CHARACTERISTIC_UUID      = "00002A26-0000-1000-8000-00805F9B34FB" (Read)
```

---

## 2. IMU Binary Packet Layout (24 Bytes per packet)

Sampling rate: 50 Hz. Big-Endian byte ordering.

| Byte Offset | Field Name | Type | Scale / Range | Description |
|---|---|---|---|---|
| `0` | `magic_header` | `uint8` | `0xAA` | Start of frame delimiter |
| `1` | `protocol_version` | `uint8` | `0x01` | Protocol revision |
| `2` | `sensor_type` | `uint8` | `0x01`: Thigh, `0x02`: Shin | Sensor identifier |
| `3` | `sequence_number` | `uint8` | `0-255` | Rollover packet index |
| `4..7` | `timestamp_ms` | `uint32` | `0 - 4,294,967,295` | Milliseconds since ESP32 boot |
| `8..9` | `accel_x` | `int16` | $\pm 16g$ (scale: 2048 LSB/g) | Acceleration X-axis |
| `10..11`| `accel_y` | `int16` | $\pm 16g$ (scale: 2048 LSB/g) | Acceleration Y-axis |
| `12..13`| `accel_z` | `int16` | $\pm 16g$ (scale: 2048 LSB/g) | Acceleration Z-axis |
| `14..15`| `gyro_x` | `int16` | $\pm 2000^\circ/s$ (scale: 16.4 LSB/dps) | Angular velocity X |
| `16..17`| `gyro_y` | `int16` | $\pm 2000^\circ/s$ (scale: 16.4 LSB/dps) | Angular velocity Y |
| `18..19`| `gyro_z` | `int16` | $\pm 2000^\circ/s$ (scale: 16.4 LSB/dps) | Angular velocity Z |
| `20` | `battery_pct` | `uint8` | `0 - 100` | Current battery percentage |
| `21` | `signal_quality` | `uint8` | `0 - 100` | Signal / RSSI / Calib score |
| `22..23`| `checksum` | `uint16` | CRC-16-CCITT | Frame integrity checksum |

---

## 3. Command Protocol (Mobile $\to$ ESP32)

Commands are written to `COMMAND_CHARACTERISTIC_UUID`:

```json
{
  "command": "START_TEST",
  "test_type": "WALKING",
  "duration_sec": 30,
  "patient_code": "P-9842"
}
```

Available commands:
- `START_TEST`: Begin sensor streaming (`test_type`: `"WALKING"` or `"SIT_TO_STAND"`)
- `STOP_TEST`: Terminate streaming and flush summary buffers
- `CALIBRATE`: Perform static 5-second gyroscope zero-rate calibration
- `PING`: Keep-alive and battery heartbeat
