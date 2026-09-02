class ApiConstants {
  static const String defaultBaseUrl = "http://10.0.2.2:8000/api/v1";
  static const int connectTimeoutMs = 10000;
  static const int receiveTimeoutMs = 15000;

  // Endpoints
  static const String authLogin = "/auth/login";
  static const String authRegister = "/auth/register";
  static const String authMe = "/auth/me";
  static const String authRefresh = "/auth/refresh";

  static const String patients = "/patients";
  static const String clinicalAssessments = "/clinical-assessments";
  static const String lifestyleAssessments = "/lifestyle-assessments";
  static const String screenings = "/screenings";
  static const String syncBatch = "/sync/batch";
  static const String referrals = "/referrals";
  static const String followUps = "/follow-ups";
  static const String dashboardSummary = "/dashboard/summary";
}
