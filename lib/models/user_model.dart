class User {
  final String userId;
  final String email;
  final String password;
  final String userType;
  final String firstName;
  final String lastName;
  final String? middleName;
  final String? gender;
  final String? dateOfBirth;
  final String? country;
  final String? state;
  final String? city;
  final String? street;
  final String? postalCode;
  final String? address;
  final String? phoneNumber;
  final String? idType;
  final String? idNumber;
  final String status;
  final String refreshToken;
  final bool isDeleted;
  final String? verificationToken;
  final String? verificationTokenExpiryTime;
  final String? passwordResetToken;
  final String? passwordResetTokenExpiryTime;
  final String? verificationEmail;
  final String createdAt;
  final String updatedAt;
  final String? token; // Made nullable
  final String? expires; // Made nullable
  final String? level; // Added from JSON
  final String? transactionPin; // Added from JSON

  User({
    required this.userId,
    required this.email,
    required this.password,
    required this.userType,
    required this.firstName,
    required this.lastName,
    this.middleName,
    this.gender,
    this.dateOfBirth,
    this.country,
    this.state,
    this.city,
    this.street,
    this.postalCode,
    this.address,
    this.phoneNumber,
    this.idType,
    this.idNumber,
    required this.status,
    required this.refreshToken,
    required this.isDeleted,
    this.verificationToken,
    this.verificationTokenExpiryTime,
    this.passwordResetToken,
    this.passwordResetTokenExpiryTime,
    this.verificationEmail,
    required this.createdAt,
    required this.updatedAt,
    this.token, // Made nullable in constructor
    this.expires, // Made nullable in constructor
    this.level, // Added to constructor
    this.transactionPin, // Added to constructor
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      userId: json['user_id'] as String? ?? '',
      email: json['email'] as String? ?? '',
      password: json['password'] as String? ?? '',
      userType: json['user_type'] as String? ?? '',
      firstName: json['first_name'] as String? ?? '',
      lastName: json['last_name'] as String? ?? '',
      middleName: json['middle_name'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] as String?,
      country: json['country'] as String?,
      state: json['state'] as String?,
      city: json['city'] as String?,
      street: json['street'] as String?,
      postalCode: json['postal_code'] as String?,
      address: json['address'] as String?,
      phoneNumber: json['phone_number'] as String?,
      idType: json['id_type'] as String?,
      idNumber: json['id_number'] as String?,
      status: json['status'] as String? ?? '',
      refreshToken: json['refresh_token'] as String? ?? '',
      isDeleted: json['is_deleted'] as bool? ?? false,
      verificationToken: json['verification_token'] as String?,
      verificationTokenExpiryTime:
          json['verification_token_expiry_time'] as String?,
      passwordResetToken: json['password_reset_token'] as String?,
      passwordResetTokenExpiryTime:
          json['password_reset_token_expiry_time'] as String?,
      verificationEmail: json['verification_email'] as String?,
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
      token: json['token'] as String?,
      expires: json['expires'] as String?,
      level: json['level'] as String?,
      transactionPin: json['transaction_pin'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'email': email,
      'password': password,
      'user_type': userType,
      'first_name': firstName,
      'last_name': lastName,
      'middle_name': middleName,
      'gender': gender,
      'date_of_birth': dateOfBirth,
      'country': country,
      'state': state,
      'city': city,
      'street': street,
      'postal_code': postalCode,
      'address': address,
      'phone_number': phoneNumber,
      'id_type': idType,
      'id_number': idNumber,
      'status': status,
      'refresh_token': refreshToken,
      'is_deleted': isDeleted,
      'verification_token': verificationToken,
      'verification_token_expiry_time': verificationTokenExpiryTime,
      'password_reset_token': passwordResetToken,
      'password_reset_token_expiry_time': passwordResetTokenExpiryTime,
      'verification_email': verificationEmail,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'token': token,
      'expires': expires,
      'level': level,
      'transaction_pin': transactionPin,
    };
  }
}
