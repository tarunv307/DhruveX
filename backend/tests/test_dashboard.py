def test_dashboard_summary_and_distribution(client, auth_headers):
    # 1. Dashboard summary
    summary_res = client.get("/api/v1/dashboard/summary", headers=auth_headers)
    assert summary_res.status_code == 200
    s_data = summary_res.json()["data"]
    assert "total_patients" in s_data
    assert "total_screenings" in s_data
    assert "low_risk_count" in s_data
    assert "high_risk_count" in s_data

    # 2. Risk distribution
    dist_res = client.get("/api/v1/dashboard/risk-distribution", headers=auth_headers)
    assert dist_res.status_code == 200
    d_data = dist_res.json()["data"]
    assert len(d_data) == 4 # LOW, MODERATE, HIGH, INCOMPLETE
