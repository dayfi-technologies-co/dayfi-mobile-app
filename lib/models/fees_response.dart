class FeesResponse {
  final bool success;
  final String message;
  final int code;
  final FeesData data;

  FeesResponse({
    required this.success,
    required this.message,
    required this.code,
    required this.data,
  });

  factory FeesResponse.fromJson(Map<String, dynamic> json) {
    return FeesResponse(
      success: json['status'] == 'success',
      message: json['message'] ?? '',
      code: json['code'] ?? 0,
      data: FeesData.fromJson(json['data'] ?? {}),
    );
  }
}

class FeesData {
  final TransferFees transfer;
  final WithdrawalFees withdrawal;

  FeesData({
    required this.transfer,
    required this.withdrawal,
  });

  factory FeesData.fromJson(Map<String, dynamic> json) {
    return FeesData(
      transfer: TransferFees.fromJson(json['transfer'] ?? {}),
      withdrawal: WithdrawalFees.fromJson(json['withdrawal'] ?? {}),
    );
  }
}

class TransferFees {
  final int dayfiToDayfi;
  final int dayfiToBank;

  TransferFees({
    required this.dayfiToDayfi,
    required this.dayfiToBank,
  });

  factory TransferFees.fromJson(Map<String, dynamic> json) {
    return TransferFees(
      dayfiToDayfi: json['dayfi_to_dayfi'] ?? 0,
      dayfiToBank: json['dayfi_to_bank'] ?? 0,
    );
  }
}

class WithdrawalFees {
  final int local;
  final int international;

  WithdrawalFees({
    required this.local,
    required this.international,
  });

  factory WithdrawalFees.fromJson(Map<String, dynamic> json) {
    return WithdrawalFees(
      local: json['local'] ?? 0,
      international: json['international'] ?? 0,
    );
  }
}