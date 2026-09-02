def test_patient_registration_and_list(client, auth_headers):
    # 1. Register Patient
    payload = {
        "initials": "S.K.",
        "age": 58,
        "gender": "FEMALE",
        "height_cm": 155.0,
        "weight_kg": 68.0,
        "village": "Rampur",
        "district": "Pune",
        "state": "Maharashtra",
        "consent": {
            "consent_version": "v1.0",
            "has_consented": True
        }
    }
    res = client.post("/api/v1/patients", json=payload, headers=auth_headers)
    assert res.status_code == 201
    patient = res.json()["data"]
    assert patient["patient_code"].startswith("P-")
    assert round(patient["bmi"], 1) == 28.3
    patient_id = patient["id"]

    # 2. Get Patient by ID
    get_res = client.get(f"/api/v1/patients/{patient_id}", headers=auth_headers)
    assert get_res.status_code == 200
    assert get_res.json()["data"]["village"] == "Rampur"

    # 3. List Patients with search query
    list_res = client.get("/api/v1/patients?search=Rampur", headers=auth_headers)
    assert list_res.status_code == 200
    assert len(list_res.json()["data"]) >= 1
