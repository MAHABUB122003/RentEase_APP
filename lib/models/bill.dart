class Bill {
  final String id;
  final String tenantId;
  final String landlordId;
  final double rentAmount;
  final double electricityBill;
  final double waterBill;
  final double gasBill;
  final double totalAmount;
  final DateTime dueDate;
  final DateTime billDate;
  final DateTime? paidDate;
  final String status;

  Bill({
    required this.id,
    required this.tenantId,
    required this.landlordId,
    required this.rentAmount,
    required this.electricityBill,
    required this.waterBill,
    required this.gasBill,
    required this.totalAmount,
    required this.dueDate,
    required this.billDate,
    required this.status,
    this.paidDate,
  });

  factory Bill.fromJson(Map<String, dynamic> json) {
    return Bill(
      id: json['id'] ?? '',
      tenantId: json['tenantId'] ?? '',
      landlordId: json['landlordId'] ?? '',
      rentAmount: (json['rentAmount'] as num?)?.toDouble() ?? 0.0,
      electricityBill: (json['electricityBill'] as num?)?.toDouble() ?? 0.0,
      waterBill: (json['waterBill'] as num?)?.toDouble() ?? 0.0,
      gasBill: (json['gasBill'] as num?)?.toDouble() ?? 0.0,
      totalAmount: (json['totalAmount'] as num?)?.toDouble() ?? 0.0,
      dueDate: json['dueDate'] != null
          ? DateTime.parse(json['dueDate'])
          : DateTime.now(),
      billDate: json['billDate'] != null
          ? DateTime.parse(json['billDate'])
          : DateTime.now(),
      paidDate: json['paidDate'] != null
          ? DateTime.parse(json['paidDate'])
          : null,
      status: json['status'] ?? 'pending',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tenantId': tenantId,
      'landlordId': landlordId,
      'rentAmount': rentAmount,
      'electricityBill': electricityBill,
      'waterBill': waterBill,
      'gasBill': gasBill,
      'totalAmount': totalAmount,
      'dueDate': dueDate.toIso8601String(),
      'billDate': billDate.toIso8601String(),
      'paidDate': paidDate?.toIso8601String(),
      'status': status,
    };
  }
}