class Recipient {
  final String id;
  final String name;
  final String bankName;
  final String accountNumber;
  final String? email;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const Recipient({
    required this.id,
    required this.name,
    required this.bankName,
    required this.accountNumber,
    this.email,
    required this.createdAt,
    this.updatedAt,
  });

  factory Recipient.fromJson(Map<String, dynamic> json) {
    return Recipient(
      id: json['id'] as String,
      name: json['name'] as String,
      bankName: json['bankName'] as String,
      accountNumber: json['accountNumber'] as String,
      email: json['email'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: json['updatedAt'] != null 
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'bankName': bankName,
      'accountNumber': accountNumber,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  Recipient copyWith({
    String? id,
    String? name,
    String? bankName,
    String? accountNumber,
    String? email,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Recipient(
      id: id ?? this.id,
      name: name ?? this.name,
      bankName: bankName ?? this.bankName,
      accountNumber: accountNumber ?? this.accountNumber,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Recipient && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
