import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/partner_profile.dart';
import '../models/kyc_document.dart';
import '../services/auth_service.dart';

class RegistrationProvider with ChangeNotifier {
  final ImagePicker _picker = ImagePicker();

  int _currentStep = 0;
  bool _isLoading = false;
  String? _errorMessage;
  bool _isDebugBypass = false;

  // Working Profile
  late PartnerProfile _profile;

  RegistrationProvider({String? initialPhone, String? initialName}) {
    _profile = PartnerProfile.initial(
      initialPhone ?? '',
      name: initialName ?? '',
    );
  }

  // Getters
  int get currentStep => _currentStep;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  PartnerProfile get profile => _profile;
  KycApplicationStatus get kycStatus => _profile.kycStatus;
  bool get isDebugBypass => _isDebugBypass;

  // Step Controllers
  void setStep(int step) {
    if (step >= 0 && step <= 3) {
      _currentStep = step;
      notifyListeners();
    }
  }

  void nextStep() {
    if (_currentStep < 3) {
      _currentStep++;
      notifyListeners();
    }
  }

  void previousStep() {
    if (_currentStep > 0) {
      _currentStep--;
      notifyListeners();
    }
  }

  // Update Personal Details
  void updatePersonalDetails({
    required String fullName,
    required String email,
    required String city,
    required String emergencyName,
    required String emergencyPhone,
    required String emergencyRelation,
  }) {
    _profile = _profile.copyWith(
      name: fullName.trim(),
      email: email.trim(),
      city: city.trim(),
      emergencyContactName: emergencyName.trim(),
      emergencyContactPhone: emergencyPhone.trim(),
      emergencyContactRelation: emergencyRelation.trim(),
    );
    notifyListeners();
  }

  // Update Vehicle Details
  void updateVehicleDetails({
    required String vehicleType,
    required String vehicleModel,
    required String vehicleNumber,
    required String rcNumber,
    required String insurancePolicyNumber,
  }) {
    _profile = _profile.copyWith(
      vehicleType: vehicleType,
      vehicleModel: vehicleModel.trim(),
      vehicleNumber: vehicleNumber.trim().toUpperCase(),
      rcNumber: rcNumber.trim().toUpperCase(),
      insurancePolicyNumber: insurancePolicyNumber.trim().toUpperCase(),
    );
    notifyListeners();
  }

  // Update KYC Identifiers
  void updateKycIdentifiers({
    required String dlNumber,
    required String aadhaarNumber,
    required String panNumber,
  }) {
    _profile = _profile.copyWith(
      drivingLicenseNumber: dlNumber.trim().toUpperCase(),
      aadhaarNumber: aadhaarNumber.trim(),
      panNumber: panNumber.trim().toUpperCase(),
    );
    notifyListeners();
  }

  // Update Bank Details
  void updateBankDetails({
    required String bankName,
    required String accountNumber,
    required String ifscCode,
    required String accountHolderName,
    required String upiId,
  }) {
    _profile = _profile.copyWith(
      bankName: bankName.trim(),
      bankAccountNumber: accountNumber.trim(),
      bankIfsc: ifscCode.trim().toUpperCase(),
      accountHolderName: accountHolderName.trim(),
      upiId: upiId.trim(),
    );
    notifyListeners();
  }

  // Pick Document Photo
  Future<bool> pickDocumentImage({
    required KycDocumentType type,
    required ImageSource source,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 1280,
      );

      if (pickedFile != null) {
        final existingDoc = _profile.documents[type];
        final updatedDoc = (existingDoc ?? _createDefaultDoc(type)).copyWith(
          localFilePath: pickedFile.path,
          status: DocumentStatus.uploaded,
        );

        final updatedMap = Map<KycDocumentType, KycDocument>.from(_profile.documents);
        updatedMap[type] = updatedDoc;

        if (type == KycDocumentType.profilePhoto) {
          _profile = _profile.copyWith(
            localAvatarPath: pickedFile.path,
            documents: updatedMap,
          );
        } else {
          _profile = _profile.copyWith(documents: updatedMap);
        }

        _isLoading = false;
        notifyListeners();
        return true;
      }
    } catch (e) {
      _errorMessage = 'Failed to capture photo: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    return false;
  }

  KycDocument _createDefaultDoc(KycDocumentType type) {
    switch (type) {
      case KycDocumentType.drivingLicenseFront:
        return KycDocument(
          type: type,
          title: 'Driving License (Front)',
          description: 'Clear photo showing name, photo & DL number',
        );
      case KycDocumentType.drivingLicenseBack:
        return KycDocument(
          type: type,
          title: 'Driving License (Back)',
          description: 'Back side showing validity and transport endorsements',
        );
      case KycDocumentType.vehicleRc:
        return KycDocument(
          type: type,
          title: 'Vehicle RC Book/Card',
          description: 'Registration Certificate issued by RTO',
        );
      case KycDocumentType.vehicleInsurance:
        return KycDocument(
          type: type,
          title: 'Vehicle Insurance Policy',
          description: 'Active third-party or comprehensive policy paper',
        );
      case KycDocumentType.aadhaarFront:
        return KycDocument(
          type: type,
          title: 'Aadhaar Card (Front)',
          description: 'Government National ID with photo and address',
        );
      case KycDocumentType.aadhaarBack:
        return KycDocument(
          type: type,
          title: 'Aadhaar Card (Back)',
          description: 'Back side showing full residential address',
        );
      case KycDocumentType.panCard:
        return KycDocument(
          type: type,
          title: 'PAN Card',
          description: 'Income Tax permanent account number card',
        );
      case KycDocumentType.profilePhoto:
        return KycDocument(
          type: type,
          title: 'Profile Selfie',
          description: 'Clear front-facing face photo in good lighting',
        );
    }
  }

  KycDocument? getDocument(KycDocumentType type) {
    return _profile.documents[type];
  }

  // Submit Application
  Future<void> submitApplication() async {
    _isLoading = true;
    notifyListeners();

    _profile = _profile.copyWith(
      kycStatus: KycApplicationStatus.underReview,
    );

    // Save profile data into Supabase
    try {
      await AuthService().savePartnerProfileToSupabase(_profile);
    } catch (e) {
      debugPrint('Save to Supabase error: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  void updateProfile(PartnerProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  // Fast-track Approval
  void fastTrackApprove() {
    _profile = _profile.copyWith(
      kycStatus: KycApplicationStatus.approved,
    );
    notifyListeners();
  }

  // Direct Debug Bypass: Activates direct app entry and fast-tracks approval
  void enterDebugMode() {
    _isDebugBypass = true;
    _profile = _profile.copyWith(
      kycStatus: KycApplicationStatus.approved,
    );
    notifyListeners();
  }

  // Deactivates debug bypass
  void exitDebugMode() {
    _isDebugBypass = false;
    notifyListeners();
  }

  // Reset to Incomplete for testing
  void resetKycForTesting() {
    _isDebugBypass = false;
    _profile = _profile.copyWith(
      kycStatus: KycApplicationStatus.incomplete,
    );
    _currentStep = 0;
    notifyListeners();
  }
}
