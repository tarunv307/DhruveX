import uuid

def test_sync_batch_idempotency(client, auth_headers):
    idempotency_key = str(uuid.uuid4())
    patient_id = str(uuid.uuid4())

    payload = {
        "idempotency_key": idempotency_key,
        "client_device_id": "MOCK-PHONE-001",
        "items": [
            {
                "entity_type": "PATIENT",
                "entity_id": patient_id,
                "operation": "CREATE",
                "data": {
                    "patient_code": "P-OFFLINE-01",
                    "age": 52,
                    "gender": "FEMALE",
                    "height_cm": 158.0,
                    "weight_kg": 64.0,
                    "bmi": 25.6,
                    "village": "Wadgaon",
                    "district": "Kolhapur",
                    "state": "Maharashtra"
                }
            }
        ]
    }

    # 1. First Sync Request
    res1 = client.post("/api/v1/sync/batch", json=payload, headers=auth_headers)
    assert res1.status_code == 200
    data1 = res1.json()["data"]
    assert data1["total_received"] == 1
    assert data1["total_synced"] == 1
    assert data1["conflicts"] == 0

    # 2. Second Sync Request (Idempotency verification)
    res2 = client.post("/api/v1/sync/batch", json=payload, headers=auth_headers)
    assert res2.status_code == 200
    assert "Idempotent" in res2.json()["message"]
    data2 = res2.json()["data"]
    assert data2["total_synced"] == 1

    # 3. Verify Patient exists in DB
    pt_check = client.get(f"/api/v1/patients/{patient_id}", headers=auth_headers)
    assert pt_check.status_code == 200
    assert pt_check.json()["data"]["patient_code"] == "P-OFFLINE-01"
