class Patient {
  final String name;
  final String? dob;
  final String? gender;
  final String? phoneNumber;
  final String? email;

  Patient({
    required this.name,
    this.dob,
    this.gender,
    this.phoneNumber,
    this.email,
  });

  factory Patient.fromJson(Map<String, dynamic> json) {
    return Patient(
      name: json['name'],
      dob: json['dob'],
      gender: json['gender'],
      phoneNumber: json['phoneNumber'],
      email: json['email'],
    );
  }
}
