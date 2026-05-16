class UserModel {
  final String id;
  final String email;
  final String? fullName;
  final bool isVerified;
  final String? gender;
  final int? age;
  final String? industry;
  final String? workStartTime;
  final String? workEndTime;
  final double? weightKg;
  final double? heightCm;

  /// Mengecek apakah user sudah melengkapi data onboarding.
  bool get isOnboarded => gender != null && age != null && industry != null;

  const UserModel({
    required this.id,
    required this.email,
    this.fullName,
    required this.isVerified,
    this.gender,
    this.age,
    this.industry,
    this.workStartTime,
    this.workEndTime,
    this.weightKg,
    this.heightCm,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      isVerified: json['is_verified'] as bool,
      gender: json['gender'] as String?,
      age: json['age'] as int?,
      industry: json['industry'] as String?,
      workStartTime: json['work_start_time'] as String?,
      workEndTime: json['work_end_time'] as String?,
      weightKg: (json['weight_kg'] as num?)?.toDouble(),
      heightCm: (json['height_cm'] as num?)?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'email': email,
        'full_name': fullName,
        'is_verified': isVerified,
        'gender': gender,
        'age': age,
        'industry': industry,
        'work_start_time': workStartTime,
        'work_end_time': workEndTime,
        'weight_kg': weightKg,
        'height_cm': heightCm,
      };

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    bool? isVerified,
    String? gender,
    int? age,
    String? industry,
    String? workStartTime,
    String? workEndTime,
    double? weightKg,
    double? heightCm,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      isVerified: isVerified ?? this.isVerified,
      gender: gender ?? this.gender,
      age: age ?? this.age,
      industry: industry ?? this.industry,
      workStartTime: workStartTime ?? this.workStartTime,
      workEndTime: workEndTime ?? this.workEndTime,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
    );
  }
}
