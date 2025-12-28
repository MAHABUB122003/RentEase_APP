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
  });
}