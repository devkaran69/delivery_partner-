import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/kyc_document.dart';
import '../../providers/registration_provider.dart';
import '../widgets/document_upload_box.dart';
import 'kyc_status_screen.dart';

class KycOnboardingScreen extends StatefulWidget {
  const KycOnboardingScreen({super.key});

  @override
  State<KycOnboardingScreen> createState() => _KycOnboardingScreenState();
}

class _KycOnboardingScreenState extends State<KycOnboardingScreen> {
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();
  final _formKey3 = GlobalKey<FormState>();
  final _formKey4 = GlobalKey<FormState>();

  // Step 1 Controllers
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _cityController;
  late TextEditingController _emergNameController;
  late TextEditingController _emergPhoneController;
  late TextEditingController _emergRelController;

  // Step 2 Controllers
  String _selectedVehicleType = 'Motorcycle';
  late TextEditingController _vehicleModelController;
  late TextEditingController _vehicleNumberController;
  late TextEditingController _rcNumberController;
  late TextEditingController _insuranceController;

  // Step 3 Controllers
  late TextEditingController _dlNumberController;
  late TextEditingController _aadhaarController;
  late TextEditingController _panController;

  // Step 4 Controllers
  late TextEditingController _bankNameController;
  late TextEditingController _accountNumberController;
  late TextEditingController _ifscController;
  late TextEditingController _holderNameController;
  late TextEditingController _upiIdController;

  @override
  void initState() {
    super.initState();
    final provider = Provider.of<RegistrationProvider>(context, listen: false);
    final profile = provider.profile;

    _nameController = TextEditingController(text: profile.name);
    _emailController = TextEditingController(text: profile.email ?? '');
    _cityController = TextEditingController(text: profile.city ?? '');
    _emergNameController = TextEditingController(text: profile.emergencyContactName ?? '');
    _emergPhoneController = TextEditingController(text: profile.emergencyContactPhone ?? '');
    _emergRelController = TextEditingController(text: profile.emergencyContactRelation ?? '');

    _selectedVehicleType = profile.vehicleType;
    _vehicleModelController = TextEditingController(text: profile.vehicleModel ?? '');
    _vehicleNumberController = TextEditingController(text: profile.vehicleNumber ?? '');
    _rcNumberController = TextEditingController(text: profile.rcNumber ?? '');
    _insuranceController = TextEditingController(text: profile.insurancePolicyNumber ?? '');

    _dlNumberController = TextEditingController(text: profile.drivingLicenseNumber ?? '');
    _aadhaarController = TextEditingController(text: profile.aadhaarNumber ?? '');
    _panController = TextEditingController(text: profile.panNumber ?? '');

    _bankNameController = TextEditingController(text: profile.bankName ?? '');
    _accountNumberController = TextEditingController(text: profile.bankAccountNumber ?? '');
    _ifscController = TextEditingController(text: profile.bankIfsc ?? '');
    _holderNameController = TextEditingController(text: profile.accountHolderName ?? profile.name);
    _upiIdController = TextEditingController(text: profile.upiId ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cityController.dispose();
    _emergNameController.dispose();
    _emergPhoneController.dispose();
    _emergRelController.dispose();

    _vehicleModelController.dispose();
    _vehicleNumberController.dispose();
    _rcNumberController.dispose();
    _insuranceController.dispose();

    _dlNumberController.dispose();
    _aadhaarController.dispose();
    _panController.dispose();

    _bankNameController.dispose();
    _accountNumberController.dispose();
    _ifscController.dispose();
    _holderNameController.dispose();
    _upiIdController.dispose();
    super.dispose();
  }

  void _onNextStep(RegistrationProvider provider) {
    if (provider.currentStep == 0) {
      if (_formKey1.currentState?.validate() ?? false) {
        provider.updatePersonalDetails(
          fullName: _nameController.text,
          email: _emailController.text,
          city: _cityController.text,
          emergencyName: _emergNameController.text,
          emergencyPhone: _emergPhoneController.text,
          emergencyRelation: _emergRelController.text,
        );
        provider.nextStep();
      }
    } else if (provider.currentStep == 1) {
      if (_formKey2.currentState?.validate() ?? false) {
        provider.updateVehicleDetails(
          vehicleType: _selectedVehicleType,
          vehicleModel: _vehicleModelController.text,
          vehicleNumber: _vehicleNumberController.text,
          rcNumber: _rcNumberController.text,
          insurancePolicyNumber: _insuranceController.text,
        );
        provider.nextStep();
      }
    } else if (provider.currentStep == 2) {
      if (_formKey3.currentState?.validate() ?? false) {
        provider.updateKycIdentifiers(
          dlNumber: _dlNumberController.text,
          aadhaarNumber: _aadhaarController.text,
          panNumber: _panController.text,
        );
        provider.nextStep();
      }
    } else if (provider.currentStep == 3) {
      if (_formKey4.currentState?.validate() ?? false) {
        provider.updateBankDetails(
          bankName: _bankNameController.text,
          accountNumber: _accountNumberController.text,
          ifscCode: _ifscController.text,
          accountHolderName: _holderNameController.text,
          upiId: _upiIdController.text,
        );
        _submitApplication(provider);
      }
    }
  }

  Future<void> _submitApplication(RegistrationProvider provider) async {
    await provider.submitApplication();
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (ctx) => const KycStatusScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<RegistrationProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Registration & KYC'),
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () {
              // Quick demo prefill / skip to review
              provider.updatePersonalDetails(
                fullName: _nameController.text,
                email: _emailController.text,
                city: _cityController.text,
                emergencyName: _emergNameController.text,
                emergencyPhone: _emergPhoneController.text,
                emergencyRelation: _emergRelController.text,
              );
              provider.updateVehicleDetails(
                vehicleType: _selectedVehicleType,
                vehicleModel: _vehicleModelController.text,
                vehicleNumber: _vehicleNumberController.text,
                rcNumber: _rcNumberController.text,
                insurancePolicyNumber: _insuranceController.text,
              );
              provider.updateKycIdentifiers(
                dlNumber: _dlNumberController.text,
                aadhaarNumber: _aadhaarController.text,
                panNumber: _panController.text,
              );
              provider.updateBankDetails(
                bankName: _bankNameController.text,
                accountNumber: _accountNumberController.text,
                ifscCode: _ifscController.text,
                accountHolderName: _holderNameController.text,
                upiId: _upiIdController.text,
              );
              _submitApplication(provider);
            },
            child: const Text(
              'Quick Submit',
              style: TextStyle(color: AppColors.accentDark, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Step Progress Indicator
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _getStepTitle(provider.currentStep),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      'Step ${provider.currentStep + 1} of 4',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppColors.accentDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (provider.currentStep + 1) / 4,
                    backgroundColor: AppColors.border,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.accent),
                    minHeight: 6,
                  ),
                ),
              ],
            ),
          ),

          // Step Form Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: _buildCurrentStepView(provider),
            ),
          ),

          // Bottom Action Buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: SafeArea(
              child: Row(
                children: [
                  if (provider.currentStep > 0) ...[
                    Expanded(
                      flex: 1,
                      child: OutlinedButton(
                        onPressed: provider.isLoading ? null : provider.previousStep,
                        child: const Text('Back'),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: provider.isLoading ? null : () => _onNextStep(provider),
                      child: provider.isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : Text(provider.currentStep == 3 ? 'Submit for Verification' : 'Save & Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStepTitle(int step) {
    switch (step) {
      case 0:
        return 'Personal & Emergency Details';
      case 1:
        return 'Vehicle & Transit Info';
      case 2:
        return 'Driving License & KYC';
      case 3:
        return 'Bank & Payout Details';
      default:
        return '';
    }
  }

  Widget _buildCurrentStepView(RegistrationProvider provider) {
    switch (provider.currentStep) {
      case 0:
        return _buildStep1Personal(provider);
      case 1:
        return _buildStep2Vehicle(provider);
      case 2:
        return _buildStep3Kyc(provider);
      case 3:
        return _buildStep4Bank(provider);
      default:
        return const SizedBox.shrink();
    }
  }

  // ----------------------------------------------------
  // Step 1: Personal & Emergency Contact
  // ----------------------------------------------------
  Widget _buildStep1Personal(RegistrationProvider provider) {
    return Form(
      key: _formKey1,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tell us about yourself',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your legal name and details must match your government identity documents.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // Profile Photo
          DocumentUploadBox(
            documentType: KycDocumentType.profilePhoto,
            title: 'Partner Selfie / Profile Photo',
            description: 'Take a clear front-facing selfie (no sunglasses/caps)',
            currentDocument: provider.getDocument(KycDocumentType.profilePhoto),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),

          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'Full Legal Name*',
              prefixIcon: Icon(Icons.person_outline),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your full name' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            decoration: const InputDecoration(
              labelText: 'Email Address*',
              prefixIcon: Icon(Icons.email_outlined),
            ),
            validator: (val) => (val == null || !val.contains('@')) ? 'Please enter a valid email' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _cityController,
            decoration: const InputDecoration(
              labelText: 'Operating City / Hub Zone*',
              prefixIcon: Icon(Icons.location_city_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your city' : null,
          ),
          const SizedBox(height: 24),

          // Emergency Contact Header
          const Text(
            'Emergency Contact Person',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Someone we can reach out to in case of road incidents or safety emergencies.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 14),

          TextFormField(
            controller: _emergNameController,
            decoration: const InputDecoration(
              labelText: 'Contact Person Name*',
              prefixIcon: Icon(Icons.contact_phone_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Enter emergency contact name' : null,
          ),
          const SizedBox(height: 16),

          Row(
            children: [
              Expanded(
                flex: 3,
                child: TextFormField(
                  controller: _emergPhoneController,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(
                    labelText: 'Phone Number*',
                    prefixIcon: Icon(Icons.phone_outlined),
                  ),
                  validator: (val) => (val == null || val.length < 10) ? 'Enter valid 10-digit phone' : null,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: TextFormField(
                  controller: _emergRelController,
                  decoration: const InputDecoration(
                    labelText: 'Relation*',
                    hintText: 'Father/Spouse',
                  ),
                  validator: (val) => (val == null || val.trim().isEmpty) ? 'Required' : null,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Step 2: Vehicle & Transit Information
  // ----------------------------------------------------
  Widget _buildStep2Vehicle(RegistrationProvider provider) {
    final vehicleOptions = [
      {'type': 'Motorcycle', 'icon': Icons.two_wheeler_rounded},
      {'type': 'Scooter', 'icon': Icons.moped_rounded},
      {'type': 'Electric Vehicle', 'icon': Icons.electric_bike_rounded},
      {'type': 'Van / Four Wheeler', 'icon': Icons.local_shipping_outlined},
    ];

    return Form(
      key: _formKey2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Vehicle Details',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Provide details of the vehicle you will use for picking up and delivering clothes.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 16),

          // Vehicle Type Chips
          const Text('Select Vehicle Type*', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vehicleOptions.map((opt) {
              final isSelected = _selectedVehicleType == opt['type'];
              return ChoiceChip(
                label: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      opt['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                    ),
                    const SizedBox(width: 6),
                    Text(opt['type'] as String),
                  ],
                ),
                selected: isSelected,
                selectedColor: AppColors.primary,
                labelStyle: TextStyle(
                  color: isSelected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedVehicleType = opt['type'] as String);
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _vehicleModelController,
            decoration: const InputDecoration(
              labelText: 'Vehicle Brand & Model*',
              hintText: 'e.g. Honda Activa 6G / Hero Splendor',
              prefixIcon: Icon(Icons.commute_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter model name' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _vehicleNumberController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Vehicle Registration Number*',
              hintText: 'e.g. DL 01 AB 1234',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter vehicle registration no' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _rcNumberController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Vehicle RC Number',
              hintText: 'RC Certificate Number',
              prefixIcon: Icon(Icons.credit_card_outlined),
            ),
          ),
          const SizedBox(height: 20),

          // RC Document Photo
          DocumentUploadBox(
            documentType: KycDocumentType.vehicleRc,
            title: 'Vehicle Registration Certificate (RC)*',
            description: 'Upload clear photo of RC card or official certificate',
            currentDocument: provider.getDocument(KycDocumentType.vehicleRc),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),

          // Vehicle Insurance Photo
          DocumentUploadBox(
            documentType: KycDocumentType.vehicleInsurance,
            title: 'Vehicle Insurance Policy',
            description: 'Active third-party or comprehensive policy paper',
            currentDocument: provider.getDocument(KycDocumentType.vehicleInsurance),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Step 3: Identity & Legal KYC (DL, Aadhaar, PAN)
  // ----------------------------------------------------
  Widget _buildStep3Kyc(RegistrationProvider provider) {
    return Form(
      key: _formKey3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Government Identity & License',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Mandatory government documents required for legal background verification.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          // 1. Driving License
          TextFormField(
            controller: _dlNumberController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Driving License Number*',
              hintText: 'e.g. DL-0420180054321',
              prefixIcon: Icon(Icons.badge_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter your DL number' : null,
          ),
          const SizedBox(height: 14),

          DocumentUploadBox(
            documentType: KycDocumentType.drivingLicenseFront,
            title: 'Driving License (Front Side)*',
            description: 'Clear photo showing name, photograph, and license number',
            currentDocument: provider.getDocument(KycDocumentType.drivingLicenseFront),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),

          DocumentUploadBox(
            documentType: KycDocumentType.drivingLicenseBack,
            title: 'Driving License (Back Side)*',
            description: 'Back side showing transport vehicle endorsements & validity',
            currentDocument: provider.getDocument(KycDocumentType.drivingLicenseBack),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),
          const SizedBox(height: 12),

          // 2. Aadhaar Card
          TextFormField(
            controller: _aadhaarController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Aadhaar Card Number*',
              hintText: '12-digit Aadhaar Number',
              prefixIcon: Icon(Icons.perm_identity_rounded),
            ),
            validator: (val) => (val == null || val.trim().length < 12) ? 'Enter valid 12-digit Aadhaar' : null,
          ),
          const SizedBox(height: 14),

          DocumentUploadBox(
            documentType: KycDocumentType.aadhaarFront,
            title: 'Aadhaar Card (Front Photo)*',
            description: 'Front side of your Aadhaar card with photo & Aadhaar number',
            currentDocument: provider.getDocument(KycDocumentType.aadhaarFront),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),

          DocumentUploadBox(
            documentType: KycDocumentType.aadhaarBack,
            title: 'Aadhaar Card (Back Photo)*',
            description: 'Back side of your Aadhaar card with complete address',
            currentDocument: provider.getDocument(KycDocumentType.aadhaarBack),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),
          const SizedBox(height: 12),

          // 3. PAN Card
          TextFormField(
            controller: _panController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'PAN Card Number*',
              hintText: '10-character alphanumeric PAN',
              prefixIcon: Icon(Icons.credit_card_rounded),
            ),
            validator: (val) => (val == null || val.trim().length < 10) ? 'Enter valid 10-digit PAN' : null,
          ),
          const SizedBox(height: 14),

          DocumentUploadBox(
            documentType: KycDocumentType.panCard,
            title: 'PAN Card Photo*',
            description: 'Official Income Tax PAN card for tax & payout compliance',
            currentDocument: provider.getDocument(KycDocumentType.panCard),
            onPickImage: (type, source) => provider.pickDocumentImage(type: type, source: source),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------
  // Step 4: Bank Account & UPI Payout Setup
  // ----------------------------------------------------
  Widget _buildStep4Bank(RegistrationProvider provider) {
    return Form(
      key: _formKey4,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Bank Account & Instant Payouts',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your delivery earnings, tips, and incentives will be transferred directly to this account.',
            style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 20),

          TextFormField(
            controller: _holderNameController,
            decoration: const InputDecoration(
              labelText: 'Account Holder Name*',
              prefixIcon: Icon(Icons.person_pin_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter account holder name' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _bankNameController,
            decoration: const InputDecoration(
              labelText: 'Bank Name*',
              hintText: 'e.g. HDFC Bank, SBI, ICICI',
              prefixIcon: Icon(Icons.account_balance_outlined),
            ),
            validator: (val) => (val == null || val.trim().isEmpty) ? 'Please enter bank name' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _accountNumberController,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              labelText: 'Bank Account Number*',
              prefixIcon: Icon(Icons.pin_outlined),
            ),
            validator: (val) => (val == null || val.trim().length < 8) ? 'Enter valid account number' : null,
          ),
          const SizedBox(height: 16),

          TextFormField(
            controller: _ifscController,
            textCapitalization: TextCapitalization.characters,
            decoration: const InputDecoration(
              labelText: 'Bank IFSC Code*',
              hintText: 'e.g. HDFC0001234',
              prefixIcon: Icon(Icons.domain_verification_outlined),
            ),
            validator: (val) => (val == null || val.trim().length < 11) ? 'Enter valid 11-digit IFSC code' : null,
          ),
          const SizedBox(height: 24),

          // Instant UPI Payout
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0FDF4),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.onlineGreen.withValues(alpha: 0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Icon(Icons.bolt_rounded, color: AppColors.onlineGreen, size: 22),
                    SizedBox(width: 8),
                    Text(
                      'Instant Daily UPI Payouts',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Withdraw your daily delivery earnings instantly to Google Pay, PhonePe, or Paytm.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _upiIdController,
                  decoration: InputDecoration(
                    labelText: 'UPI ID / VPA*',
                    hintText: 'mobile@paytm / name@oksbi',
                    prefixIcon: const Icon(Icons.qr_code_2_rounded),
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  validator: (val) => (val == null || !val.contains('@')) ? 'Enter valid UPI ID (e.g. phone@paytm)' : null,
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Consent & Terms
          const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.verified_user_outlined, color: AppColors.onlineGreen, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  'By submitting this application, I declare that the vehicle and identification documents submitted belong to me and are valid.',
                  style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
