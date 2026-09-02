def test_register_and_login(client):
    # 1. Register User
    reg_res = client.post("/api/v1/auth/register", json={
        "phone": "9998887776",
        "password": "secretpassword",
        "display_name": "Nurse Anjali",
        "role": "HEALTH_WORKER",
        "health_worker_id": "HW-999"
    })
    assert reg_res.status_code == 201
    assert reg_res.json()["success"] is True
    assert reg_res.json()["data"]["phone"] == "9998887776"

    # 2. Login User
    login_res = client.post("/api/v1/auth/login", json={
        "phone_or_id": "9998887776",
        "password": "secretpassword"
    })
    assert login_res.status_code == 200
    token_data = login_res.json()["data"]
    assert "access_token" in token_data
    assert "refresh_token" in token_data

    # 3. Get Current User /me
    access_token = token_data["access_token"]
    me_res = client.get("/api/v1/auth/me", headers={"Authorization": f"Bearer {access_token}"})
    assert me_res.status_code == 200
    assert me_res.json()["data"]["display_name"] == "Nurse Anjali"
