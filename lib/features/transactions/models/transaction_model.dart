enum TransactionStatus {
  pending,
  completed,
  failed,
  requiresAction,
}

class Transaction {
  final String id;
  final String recipientName;
  final double amount;
  final DateTime date;
  final TransactionStatus status;
  final String? reference;
  final String? description;

  const Transaction({
    required this.id,
    required this.recipientName,
    required this.amount,
    required this.date,
    required this.status,
    this.reference,
    this.description,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as String,
      recipientName: json['recipientName'] as String,
      amount: (json['amount'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
      status: TransactionStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => TransactionStatus.pending,
      ),
      reference: json['reference'] as String?,
      description: json['description'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recipientName': recipientName,
      'amount': amount,
      'date': date.toIso8601String(),
      'status': status.name,
      'reference': reference,
      'description': description,
    };
  }

  Transaction copyWith({
    String? id,
    String? recipientName,
    double? amount,
    DateTime? date,
    TransactionStatus? status,
    String? reference,
    String? description,
  }) {
    return Transaction(
      id: id ?? this.id,
      recipientName: recipientName ?? this.recipientName,
      amount: amount ?? this.amount,
      date: date ?? this.date,
      status: status ?? this.status,
      reference: reference ?? this.reference,
      description: description ?? this.description,
    );
  }
}
