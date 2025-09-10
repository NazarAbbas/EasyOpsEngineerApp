class LoginResponse {
  // Default token (used when API returns null/empty token)
  static const String defaultToken =
      'eyJhbGciOiJIUzI1NiJ9.eyJpc3MiOiJFYXp5T3BzIiwic3ViIjoic3VwZXJhZG1pbkBlYXp5c2Fhcy5pbiIsImF1dGhvcml0aWVzIjoiVVBEQVRFVVNFUixERUxFVEVVU0VSLFJFQURVU0VSLENSRUFURVRFTkFOVCxVUERBVEVURU5BTlQsREVMRVRFVEVOQU5ULENSRUFURVVTRVIsUkVBRFRFTkFOVCIsImlhdCI6MTc1NzQ5OTk1MCwiZXhwIjoxNzU5MjI3OTUwfQ.31hgA28-202zr1GPnhzRbda1rv_g_GeFc1EeurApZgc';

  final int recordStatus;
  final String userName;
  final String message;
  final String token; // always non-empty (falls back to defaultToken)
  final List<String> authorities;

  const LoginResponse({
    required this.recordStatus,
    required this.userName,
    required this.message,
    required this.token,
    required this.authorities,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    final rawToken = (json['token'] as String?)?.trim() ?? '';
    return LoginResponse(
      recordStatus: json['record_status'] ?? 0,
      userName: json['userName'] ?? '',
      message: json['message'] ?? '',
      token: rawToken.isEmpty ? defaultToken : rawToken,
      authorities:
          (json['authorities'] as List?)?.map((e) => e.toString()).toList() ??
          const [],
    );
  }

  Map<String, dynamic> toJson() => {
    'record_status': recordStatus,
    'userName': userName,
    'message': message,
    'token': token,
    'authorities': authorities,
  };
}
