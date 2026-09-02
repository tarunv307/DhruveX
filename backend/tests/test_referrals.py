from datetime import datetime, timezone, timedelta

def test_referrals_and_follow_ups(client, auth_headers):
    # 1. Create Patient
    pt_res = client.post("/api/v1/patients", json={
        "age": 60,
        "gender": "FEMALE",
        "height_cm": 152.0,
        "weight_kg": 68.0,
        "village": "Sangli",
        "district": "Sangli",
        "state": "Maharashtra"
    }, headers=auth_headers)
    patient_id = pt_res.json()["data"]["id"]

    # 2. Create Referral
    ref_res = client.post("/api/v1/referrals", json={
        "patient_id": patient_id,
        "reason": "Severe knee stiffness and abnormal asymmetric gait",
        "priority": "URGENT",
        "notes": "Referred to District Civil Hospital Orthopedics"
    }, headers=auth_headers)
    assert ref_res.status_code == 201
    referral_id = ref_res.json()["data"]["id"]
    assert ref_res.json()["data"]["status"] == "PENDING"

    # 3. Update Referral Status
    patch_res = client.patch(f"/api/v1/referrals/{referral_id}", json={
        "status": "ACCEPTED",
        "notes": "Consultation scheduled with Dr. Patil"
    }, headers=auth_headers)
    assert patch_res.status_code == 200
    assert patch_res.json()["data"]["status"] == "ACCEPTED"

    # 4. Create Follow-up
    due_date = (datetime.now(timezone.utc) + timedelta(days=14)).isoformat()
    fu_res = client.post("/api/v1/follow-ups", json={
        "patient_id": patient_id,
        "due_date": due_date,
        "type": "POST_REFERRAL_CHECK",
        "notes": "Check compliance with prescribed physiotherapy"
    }, headers=auth_headers)
    assert fu_res.status_code == 201
    assert fu_res.json()["data"]["status"] == "SCHEDULED"
