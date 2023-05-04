class Patient {
  final int? id;
  final String fullName;
  final String? dob;
  final String? gender;
  final String? phoneNumber;
  final String? email;

  Patient({
    this.id,
    required this.fullName,
    this.dob,
    this.gender,
    this.phoneNumber,
    this.email,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      id: json['id'],
      fullName: json['fullName'],
      dob: json['dob'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'fullName': fullName,
      'dob': dob,
      'gender': gender,
      'phoneNumber': phoneNumber,
      'email': email,
    };
  }

  Patient copyWith({
    int? id,
    String? fullName,
    String? dob,
    String? gender,
    String? phoneNumber,
    String? email,
  }) {
    return Patient(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      email: email ?? this.email,
    );
  }
}
