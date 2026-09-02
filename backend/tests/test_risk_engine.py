def test_risk_engine_calculation_and_incomplete(client, auth_headers):
    # 1. Register Patient
    pt_res = client.post("/api/v1/patients", json={
        "age": 56,
        "gender": "FEMALE",
        "height_cm": 158.0,
        "weight_kg": 73.0,
        "village": "Belgaum",
        "district": "Belagavi",
        "state": "Karnataka"
    }, headers=auth_headers)
    patient_id = pt_res.json()["data"]["id"]

    # 2. Add Clinical Assessment with moderate pain
    client.post(f"/api/v1/patients/{patient_id}/clinical-assessments", json={
        "pain_score": 6,
        "morning_stiffness": True,
        "walking_difficulty": True,
        "previous_knee_injury": False,
        "family_history": True,
        "swelling": False,
        "joint_locking": False,
        "fever_or_acute_injury": False
    }, headers=auth_headers)

    # 3. Add Lifestyle Assessment
    client.post(f"/api/v1/patients/{patient_id}/lifestyle-assessments", json={
        "squatting_level": "OFTEN",
        "load_carrying_level": "MEDIUM",
        "manual_work": True,
        "hill_walking_level": "LOW",
        "physical_activity_level": "MEDIUM",
        "daily_walking_minutes": 45
    }, headers=auth_headers)

    # 4. Create Screening
    sc_res = client.post("/api/v1/screenings", json={
        "patient_id": patient_id
    }, headers=auth_headers)
    screening_id = sc_res.json()["data"]["id"]

    # Case A: Calculate risk WITHOUT sensor data -> Must return INCOMPLETE category
    inc_res = client.post(f"/api/v1/screenings/{screening_id}/calculate-risk", headers=auth_headers)
    assert inc_res.status_code == 200
    inc_data = inc_res.json()["data"]
    assert inc_data["risk_category"] == "INCOMPLETE"
    assert inc_data["risk_score"] is None

    # Case B: Upload valid Gait Features -> Must return calculated score
    client.post(f"/api/v1/screenings/{screening_id}/gait-features", json={
        "cadence": 92.0,
        "step_time": 0.65,
        "stance_time": 0.65,
        "swing_time": 0.35,
        "gait_asymmetry": 0.35,
        "step_variability": 0.09,
        "thigh_angular_range": 30.0,
        "shin_angular_range": 40.0,
        "estimated_knee_motion": 35.0,
        "sit_to_stand_duration": 3.2,
        "quality_score": 0.95
    }, headers=auth_headers)

    calc_res = client.post(f"/api/v1/screenings/{screening_id}/calculate-risk", headers=auth_headers)
    assert calc_res.status_code == 200
    calc_data = calc_res.json()["data"]
    assert calc_data["risk_score"] is not None
    assert calc_data["risk_category"] in ["MODERATE", "HIGH"]
    assert calc_data["is_diagnostic"] is False
    assert len(calc_data["contributing_factors"]) > 0
    assert "not a final diagnosis" in calc_data["disclaimer"]
