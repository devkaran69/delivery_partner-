import 'kyc_document.dart';

enum KycApplicationStatus {
  incomplete,
  underReview,
  approved,
  rejected,
}

class PartnerProfile {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? avatarUrl;
  final String? localAvatarPath;
  final DateTime? dob;
  final String? gender;
  final String? city;

  // Emergency Contact
  final String? emergencyContactName;
  final String? emergencyContactPhone;
  final String? emergencyContactRelation;

  // Vehicle Details
  final String vehicleType;
  final String? vehicleModel;
  final String? vehicleNumber;
  final String? rcNumber;
  final String? insurancePolicyNumber;

  // KYC Identifiers
  final String? drivingLicenseNumber;
  final String? aadhaarNumber;
  final String? panNumber;

  // Bank & Payouts
  final String? bankName;
  final String? bankAccountNumber;
  final String? bankIfsc;
  final String? accountHolderName;
  final String? upiId;

  // Operational & Wallet State
  final KycApplicationStatus kycStatus;
  final String? rejectionReason;
  final double rating;
  final int totalTrips;
  final double walletBalance;
  final double todayEarnings;
  final double cashInHand;

  // Uploaded Documents
  final Map<KycDocumentType, KycDocument> documents;

  PartnerProfile({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.avatarUrl,
    this.localAvatarPath,
    this.dob,
    this.gender,
    this.city,
    this.emergencyContactName,
    this.emergencyContactPhone,
    this.emergencyContactRelation,
    this.vehicleType = 'Motorcycle',
    this.vehicleModel,
    this.vehicleNumber,
    this.rcNumber,
    this.insurancePolicyNumber,
    this.drivingLicenseNumber,
    this.aadhaarNumber,
    this.panNumber,
    this.bankName,
    this.bankAccountNumber,
    this.bankIfsc,
    this.accountHolderName,
    this.upiId,
    this.kycStatus = KycApplicationStatus.incomplete,
    this.rejectionReason,
    this.rating = 5.0,
    this.totalTrips = 0,
    this.walletBalance = 0.0,
    this.todayEarnings = 0.0,
    this.cashInHand = 0.0,
    Map<KycDocumentType, KycDocument>? documents,
  }) : documents = documents ?? {};

  bool get isKycApproved => kycStatus == KycApplicationStatus.approved;
  bool get isUnderReview => kycStatus == KycApplicationStatus.underReview;

  PartnerProfile copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? avatarUrl,
    String? localAvatarPath,
    DateTime? dob,
    String? gender,
    String? city,
    String? emergencyContactName,
    String? emergencyContactPhone,
    String? emergencyContactRelation,
    String? vehicleType,
    String? vehicleModel,
    String? vehicleNumber,
    String? rcNumber,
    String? insurancePolicyNumber,
    String? drivingLicenseNumber,
    String? aadhaarNumber,
    String? panNumber,
    String? bankName,
    String? bankAccountNumber,
    String? bankIfsc,
    String? accountHolderName,
    String? upiId,
    KycApplicationStatus? kycStatus,
    String? rejectionReason,
    double? rating,
    int? totalTrips,
    double? walletBalance,
    double? todayEarnings,
    double? cashInHand,
    Map<KycDocumentType, KycDocument>? documents,
  }) {
    return PartnerProfile(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      localAvatarPath: localAvatarPath ?? this.localAvatarPath,
      dob: dob ?? this.dob,
      gender: gender ?? this.gender,
      city: city ?? this.city,
      emergencyContactName: emergencyContactName ?? this.emergencyContactName,
      emergencyContactPhone: emergencyContactPhone ?? this.emergencyContactPhone,
      emergencyContactRelation: emergencyContactRelation ?? this.emergencyContactRelation,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleModel: vehicleModel ?? this.vehicleModel,
      vehicleNumber: vehicleNumber ?? this.vehicleNumber,
      rcNumber: rcNumber ?? this.rcNumber,
      insurancePolicyNumber: insurancePolicyNumber ?? this.insurancePolicyNumber,
      drivingLicenseNumber: drivingLicenseNumber ?? this.drivingLicenseNumber,
      aadhaarNumber: aadhaarNumber ?? this.aadhaarNumber,
      panNumber: panNumber ?? this.panNumber,
      bankName: bankName ?? this.bankName,
      bankAccountNumber: bankAccountNumber ?? this.bankAccountNumber,
      bankIfsc: bankIfsc ?? this.bankIfsc,
      accountHolderName: accountHolderName ?? this.accountHolderName,
      upiId: upiId ?? this.upiId,
      kycStatus: kycStatus ?? this.kycStatus,
      rejectionReason: rejectionReason ?? this.rejectionReason,
      rating: rating ?? this.rating,
      totalTrips: totalTrips ?? this.totalTrips,
      walletBalance: walletBalance ?? this.walletBalance,
      todayEarnings: todayEarnings ?? this.todayEarnings,
      cashInHand: cashInHand ?? this.cashInHand,
      documents: documents ?? this.documents,
    );
  }

  // Clean blank profile for new partners
  factory PartnerProfile.initial(String phone, {String? name}) {
    final cleanPhone = phone.replaceAll(RegExp(r'[^\d+]'), '');
    return PartnerProfile(
      id: 'partner_${DateTime.now().millisecondsSinceEpoch}',
      name: name ?? (cleanPhone.isNotEmpty ? 'Partner $cleanPhone' : 'Delivery Partner'),
      phone: cleanPhone,
      email: null,
      city: '',
      vehicleType: 'Motorcycle',
      vehicleModel: null,
      vehicleNumber: null,
      drivingLicenseNumber: null,
      aadhaarNumber: null,
      panNumber: null,
      bankName: null,
      bankAccountNumber: null,
      bankIfsc: null,
      accountHolderName: name ?? '',
      upiId: null,
      kycStatus: KycApplicationStatus.incomplete,
      rating: 5.0,
      totalTrips: 0,
      walletBalance: 0.0,
      todayEarnings: 0.0,
      cashInHand: 0.0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'avatar_url': avatarUrl,
      'city': city,
      'vehicle_type': vehicleType,
      'vehicle_model': vehicleModel,
      'vehicle_number': vehicleNumber,
      'driving_license_number': drivingLicenseNumber,
      'aadhaar_number': aadhaarNumber,
      'pan_number': panNumber,
      'bank_name': bankName,
      'bank_account_number': bankAccountNumber,
      'bank_ifsc': bankIfsc,
      'upi_id': upiId,
      'kyc_status': kycStatus.name,
      'rating': rating,
      'total_trips': totalTrips,
      'wallet_balance': walletBalance,
      'today_earnings': todayEarnings,
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory PartnerProfile.fromMap(Map<String, dynamic> map, {String fallbackPhone = ''}) {
    KycApplicationStatus parseStatus(String? val) {
      if (val == null) return KycApplicationStatus.incomplete;
      try {
        return KycApplicationStatus.values.firstWhere((e) => e.name == val);
      } catch (_) {
        return KycApplicationStatus.incomplete;
      }
    }

    return PartnerProfile(
      id: map['id']?.toString() ?? 'partner_${DateTime.now().millisecondsSinceEpoch}',
      name: map['name']?.toString() ?? 'Delivery Partner',
      phone: map['phone']?.toString() ?? fallbackPhone,
      email: map['email']?.toString(),
      avatarUrl: map['avatar_url']?.toString(),
      city: map['city']?.toString() ?? 'Delhi NCR',
      vehicleType: map['vehicle_type']?.toString() ?? 'Motorcycle',
      vehicleModel: map['vehicle_model']?.toString(),
      vehicleNumber: map['vehicle_number']?.toString(),
      drivingLicenseNumber: map['driving_license_number']?.toString(),
      aadhaarNumber: map['aadhaar_number']?.toString(),
      panNumber: map['pan_number']?.toString(),
      bankName: map['bank_name']?.toString(),
      bankAccountNumber: map['bank_account_number']?.toString(),
      bankIfsc: map['bank_ifsc']?.toString(),
      upiId: map['upi_id']?.toString(),
      kycStatus: parseStatus(map['kyc_status']?.toString()),
      rating: (map['rating'] as num?)?.toDouble() ?? 4.95,
      totalTrips: (map['total_trips'] as num?)?.toInt() ?? 0,
      walletBalance: (map['wallet_balance'] as num?)?.toDouble() ?? 0.0,
      todayEarnings: (map['today_earnings'] as num?)?.toDouble() ?? 0.0,
    );
  }
}
