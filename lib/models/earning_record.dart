class EarningRecord {
  final String id;
  final DateTime date;
  final String orderNumber;
  final String storeName;
  final double basePay;
  final double distanceBonus;
  final double customerTip;
  final double peakIncentive;
  final double totalAmount;
  final double distanceKm;
  final int tripDurationMinutes;

  EarningRecord({
    required this.id,
    required this.date,
    required this.orderNumber,
    required this.storeName,
    required this.basePay,
    required this.distanceBonus,
    this.customerTip = 0.0,
    this.peakIncentive = 0.0,
    required this.totalAmount,
    required this.distanceKm,
    required this.tripDurationMinutes,
  });
}
