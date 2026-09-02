def test_screening_lifecycle(client, auth_headers):
    # 1. Create Patient
    pt_res = client.post("/api/v1/patients", json={
        "age": 62,
        "gender": "MALE",
        "height_cm": 170.0,
        "weight_kg": 75.0,
        "village": "Shirdi",
        "district": "Ahmednagar",
        "state": "Maharashtra"
    }, headers=auth_headers)
    patient_id = pt_res.json()["data"]["id"]

    # 2. Create Screening
    sc_res = client.post("/api/v1/screenings", json={
        "patient_id": patient_id,
        "is_demo": False
    }, headers=auth_headers)
    assert sc_res.status_code == 201
    screening_id = sc_res.json()["data"]["id"]

    # 3. Add Sensor Session
    ss_res = client.post(f"/api/v1/screenings/{screening_id}/sensor-sessions", json={
        "test_type": "NORMAL_WALKING",
        "duration_seconds": 30,
        "signal_quality": 95,
        "battery_level": 88
    }, headers=auth_headers)
    assert ss_res.status_code == 200

    # 4. Upload Gait Features
    gait_res = client.post(f"/api/v1/screenings/{screening_id}/gait-features", json={
        "cadence": 98.0,
        "step_time": 0.61,
        "stance_time": 0.62,
        "swing_time": 0.38,
        "gait_asymmetry": 0.28,
        "step_variability": 0.08,
        "thigh_angular_range": 32.0,
        "shin_angular_range": 44.0,
        "estimated_knee_motion": 38.0,
        "sit_to_stand_duration": 2.8,
        "quality_score": 0.96
    }, headers=auth_headers)
    assert gait_res.status_code == 201
    assert gait_res.json()["data"]["cadence"] == 98.0
