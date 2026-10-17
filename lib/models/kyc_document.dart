enum KycDocumentType {
  drivingLicenseFront,
  drivingLicenseBack,
  vehicleRc,
  vehicleInsurance,
  aadhaarFront,
  aadhaarBack,
  panCard,
  profilePhoto,
}

enum DocumentStatus {
  notUploaded,
  uploaded,
  verified,
  rejected,
}

class KycDocument {
  final KycDocumentType type;
  final String title;
  final String description;
  final String? localFilePath;
  final String? remoteUrl;
  final DocumentStatus status;
  final String? documentNumber;
  final DateTime? expiryDate;
  final String? rejectionReason;

  KycDocument({
    required this.type,
    required this.title,
    required this.description,
    this.localFilePath,
    this.remoteUrl,
    this.status = DocumentStatus.notUploaded,
    this.documentNumber,
    this.expiryDate,
    this.rejectionReason,
  });

  bool get isUploaded => localFilePath != null || remoteUrl != null;

  KycDocument copyWith({
    KycDocumentType? type,
    String? title,
    String? description,
    String? localFilePath,
    String? remoteUrl,
    DocumentStatus? status,
    String? documentNumber,
    DateTime? expiryDate,
    String? rejectionReason,
  }) {
    return KycDocument(
      type: type ?? this.type,
      title: title ?? this.title,
      description: description ?? this.description,
      localFilePath: localFilePath ?? this.localFilePath,
      remoteUrl: remoteUrl ?? this.remoteUrl,
      status: status ?? this.status,
      documentNumber: documentNumber ?? this.documentNumber,
      expiryDate: expiryDate ?? this.expiryDate,
      rejectionReason: rejectionReason ?? this.rejectionReason,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'type': type.name,
      'title': title,
      'description': description,
      'localFilePath': localFilePath,
      'remoteUrl': remoteUrl,
      'status': status.name,
      'documentNumber': documentNumber,
      'expiryDate': expiryDate?.toIso8601String(),
      'rejectionReason': rejectionReason,
    };
  }

  factory KycDocument.fromJson(Map<String, dynamic> json) {
    return KycDocument(
      type: KycDocumentType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => KycDocumentType.drivingLicenseFront,
      ),
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      localFilePath: json['localFilePath'],
      remoteUrl: json['remoteUrl'],
      status: DocumentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => DocumentStatus.notUploaded,
      ),
      documentNumber: json['documentNumber'],
      expiryDate: json['expiryDate'] != null ? DateTime.tryParse(json['expiryDate']) : null,
      rejectionReason: json['rejectionReason'],
    );
  }
}
