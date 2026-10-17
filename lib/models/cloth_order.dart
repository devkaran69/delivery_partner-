import 'apparel_item.dart';

enum ClothOrderStatus {
  pending,
  accepted,
  arrivedAtStore,
  pickedUp,
  arrivedAtCustomer,
  delivered,
  cancelled,
  returnPickup,
}

enum PaymentType {
  prepaid,
  cashOnDelivery,
}

class ClothOrder {
  final String id;
  final String orderNumber;
  final ClothOrderStatus status;

  // Store / Seller Details
  final String storeName;
  final String storeAddress;
  final String storePhone;
  final String storeContactPerson;
  final double storeLatitude;
  final double storeLongitude;
  final String storePickupOtp;

  // Customer Details
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String? deliveryInstructions;
  final double customerLatitude;
  final double customerLongitude;
  final String customerDeliveryOtp;

  // Items & Package
  final List<ApparelItem> items;
  final int packageCount;
  final String? bagSealCode;

  // Payment & Earnings
  final PaymentType paymentType;
  final double orderTotalAmount;
  final double codAmountToCollect;
  final double partnerEarnings;
  final double distanceKm;
  final int estimatedDurationMinutes;

  // Timestamps
  final DateTime createdAt;
  final DateTime? pickedUpAt;
  final DateTime? deliveredAt;

  ClothOrder({
    required this.id,
    required this.orderNumber,
    required this.status,
    required this.storeName,
    required this.storeAddress,
    required this.storePhone,
    required this.storeContactPerson,
    required this.storeLatitude,
    required this.storeLongitude,
    required this.storePickupOtp,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    this.deliveryInstructions,
    required this.customerLatitude,
    required this.customerLongitude,
    required this.customerDeliveryOtp,
    required this.items,
    this.packageCount = 1,
    this.bagSealCode,
    required this.paymentType,
    required this.orderTotalAmount,
    required this.codAmountToCollect,
    required this.partnerEarnings,
    required this.distanceKm,
    required this.estimatedDurationMinutes,
    required this.createdAt,
    this.pickedUpAt,
    this.deliveredAt,
  });

  bool get isCod => paymentType == PaymentType.cashOnDelivery;
  int get totalGarmentCount => items.fold(0, (sum, item) => sum + item.quantity);

  ClothOrder copyWith({
    String? id,
    String? orderNumber,
    ClothOrderStatus? status,
    String? storeName,
    String? storeAddress,
    String? storePhone,
    String? storeContactPerson,
    double? storeLatitude,
    double? storeLongitude,
    String? storePickupOtp,
    String? customerName,
    String? customerPhone,
    String? customerAddress,
    String? deliveryInstructions,
    double? customerLatitude,
    double? customerLongitude,
    String? customerDeliveryOtp,
    List<ApparelItem>? items,
    int? packageCount,
    String? bagSealCode,
    PaymentType? paymentType,
    double? orderTotalAmount,
    double? codAmountToCollect,
    double? partnerEarnings,
    double? distanceKm,
    int? estimatedDurationMinutes,
    DateTime? createdAt,
    DateTime? pickedUpAt,
    DateTime? deliveredAt,
  }) {
    return ClothOrder(
      id: id ?? this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      status: status ?? this.status,
      storeName: storeName ?? this.storeName,
      storeAddress: storeAddress ?? this.storeAddress,
      storePhone: storePhone ?? this.storePhone,
      storeContactPerson: storeContactPerson ?? this.storeContactPerson,
      storeLatitude: storeLatitude ?? this.storeLatitude,
      storeLongitude: storeLongitude ?? this.storeLongitude,
      storePickupOtp: storePickupOtp ?? this.storePickupOtp,
      customerName: customerName ?? this.customerName,
      customerPhone: customerPhone ?? this.customerPhone,
      customerAddress: customerAddress ?? this.customerAddress,
      deliveryInstructions: deliveryInstructions ?? this.deliveryInstructions,
      customerLatitude: customerLatitude ?? this.customerLatitude,
      customerLongitude: customerLongitude ?? this.customerLongitude,
      customerDeliveryOtp: customerDeliveryOtp ?? this.customerDeliveryOtp,
      items: items ?? this.items,
      packageCount: packageCount ?? this.packageCount,
      bagSealCode: bagSealCode ?? this.bagSealCode,
      paymentType: paymentType ?? this.paymentType,
      orderTotalAmount: orderTotalAmount ?? this.orderTotalAmount,
      codAmountToCollect: codAmountToCollect ?? this.codAmountToCollect,
      partnerEarnings: partnerEarnings ?? this.partnerEarnings,
      distanceKm: distanceKm ?? this.distanceKm,
      estimatedDurationMinutes: estimatedDurationMinutes ?? this.estimatedDurationMinutes,
      createdAt: createdAt ?? this.createdAt,
      pickedUpAt: pickedUpAt ?? this.pickedUpAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_number': orderNumber,
      'status': status.name,
      'store_name': storeName,
      'store_address': storeAddress,
      'store_phone': storePhone,
      'store_contact_person': storeContactPerson,
      'store_latitude': storeLatitude,
      'store_longitude': storeLongitude,
      'store_pickup_otp': storePickupOtp,
      'customer_name': customerName,
      'customer_phone': customerPhone,
      'customer_address': customerAddress,
      'delivery_instructions': deliveryInstructions,
      'customer_latitude': customerLatitude,
      'customer_longitude': customerLongitude,
      'customer_delivery_otp': customerDeliveryOtp,
      'items': items.map((i) => i.toJson()).toList(),
      'package_count': packageCount,
      'bag_seal_code': bagSealCode,
      'payment_type': paymentType.name,
      'order_total': orderTotalAmount,
      'cod_amount_to_collect': codAmountToCollect,
      'partner_earnings': partnerEarnings,
      'distance_km': distanceKm,
      'estimated_duration_mins': estimatedDurationMinutes,
      'created_at': createdAt.toIso8601String(),
      'picked_up_at': pickedUpAt?.toIso8601String(),
      'delivered_at': deliveredAt?.toIso8601String(),
    };
  }

  factory ClothOrder.fromMap(Map<String, dynamic> map) {
    ClothOrderStatus parseStatus(String? val) {
      if (val == null) return ClothOrderStatus.pending;
      try {
        return ClothOrderStatus.values.firstWhere((e) => e.name == val);
      } catch (_) {
        return ClothOrderStatus.pending;
      }
    }

    PaymentType parsePaymentType(String? val) {
      if (val == 'cashOnDelivery' || val == 'cod') {
        return PaymentType.cashOnDelivery;
      }
      return PaymentType.prepaid;
    }

    List<ApparelItem> parseItems(dynamic rawItems) {
      if (rawItems is List) {
        return rawItems.map((item) {
          if (item is Map<String, dynamic>) {
            return ApparelItem.fromJson(item);
          } else if (item is Map) {
            return ApparelItem.fromJson(Map<String, dynamic>.from(item));
          }
          return ApparelItem(
            id: 'itm_${DateTime.now().millisecondsSinceEpoch}',
            name: 'Designer Retail Garment',
            brand: 'Fashion Store',
            size: 'Free Size',
            color: 'Assorted',
            price: 999.0,
          );
        }).toList();
      }
      return [
        ApparelItem(
          id: 'itm_item',
          name: 'Retail Garment Package',
          brand: 'Cloth Store',
          size: 'Standard',
          color: 'Assorted',
          price: 999.0,
        ),
      ];
    }

    return ClothOrder(
      id: map['id']?.toString() ?? 'ord_${DateTime.now().millisecondsSinceEpoch}',
      orderNumber: map['order_number']?.toString() ?? map['orderNumber']?.toString() ?? '#ORD-${DateTime.now().millisecondsSinceEpoch % 10000}',
      status: parseStatus(map['status']?.toString()),
      storeName: map['store_name']?.toString() ?? map['storeName']?.toString() ?? 'Retail Store',
      storeAddress: map['store_address']?.toString() ?? map['storeAddress']?.toString() ?? 'Store Address',
      storePhone: map['store_phone']?.toString() ?? map['storePhone']?.toString() ?? '',
      storeContactPerson: map['store_contact_person']?.toString() ?? map['storeContactPerson']?.toString() ?? 'Dispatch Desk',
      storeLatitude: (map['store_latitude'] as num?)?.toDouble() ?? (map['storeLatitude'] as num?)?.toDouble() ?? 28.6315,
      storeLongitude: (map['store_longitude'] as num?)?.toDouble() ?? (map['storeLongitude'] as num?)?.toDouble() ?? 77.2167,
      storePickupOtp: map['store_pickup_otp']?.toString() ?? map['storePickupOtp']?.toString() ?? '1234',
      customerName: map['customer_name']?.toString() ?? map['customerName']?.toString() ?? 'Customer',
      customerPhone: map['customer_phone']?.toString() ?? map['customerPhone']?.toString() ?? '',
      customerAddress: map['customer_address']?.toString() ?? map['customerAddress']?.toString() ?? 'Customer Address',
      deliveryInstructions: map['delivery_instructions']?.toString() ?? map['deliveryInstructions']?.toString(),
      customerLatitude: (map['customer_latitude'] as num?)?.toDouble() ?? (map['customerLatitude'] as num?)?.toDouble() ?? 28.5589,
      customerLongitude: (map['customer_longitude'] as num?)?.toDouble() ?? (map['customerLongitude'] as num?)?.toDouble() ?? 77.2028,
      customerDeliveryOtp: map['customer_delivery_otp']?.toString() ?? map['customerDeliveryOtp']?.toString() ?? '5678',
      items: parseItems(map['items']),
      packageCount: (map['package_count'] as num?)?.toInt() ?? (map['packageCount'] as num?)?.toInt() ?? 1,
      bagSealCode: map['bag_seal_code']?.toString() ?? map['bagSealCode']?.toString(),
      paymentType: parsePaymentType(map['payment_type']?.toString() ?? map['paymentType']?.toString()),
      orderTotalAmount: (map['order_total'] as num?)?.toDouble() ?? (map['orderTotalAmount'] as num?)?.toDouble() ?? 1499.0,
      codAmountToCollect: (map['cod_amount_to_collect'] as num?)?.toDouble() ?? (map['codAmountToCollect'] as num?)?.toDouble() ?? 0.0,
      partnerEarnings: (map['partner_earnings'] as num?)?.toDouble() ?? (map['partnerEarnings'] as num?)?.toDouble() ?? 95.0,
      distanceKm: (map['distance_km'] as num?)?.toDouble() ?? (map['distanceKm'] as num?)?.toDouble() ?? 3.5,
      estimatedDurationMinutes: (map['estimated_duration_mins'] as num?)?.toInt() ?? (map['estimatedDurationMinutes'] as num?)?.toInt() ?? 18,
      createdAt: map['created_at'] != null ? (DateTime.tryParse(map['created_at'].toString()) ?? DateTime.now()) : DateTime.now(),
      pickedUpAt: map['picked_up_at'] != null ? DateTime.tryParse(map['picked_up_at'].toString()) : null,
      deliveredAt: map['delivered_at'] != null ? DateTime.tryParse(map['delivered_at'].toString()) : null,
    );
  }
}
