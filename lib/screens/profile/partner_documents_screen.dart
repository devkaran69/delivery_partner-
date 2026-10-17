import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../models/kyc_document.dart';
import '../../providers/registration_provider.dart';

class PartnerDocumentsScreen extends StatelessWidget {
  const PartnerDocumentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final regProvider = Provider.of<RegistrationProvider>(context);
    final profile = regProvider.profile;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('My KYC & Documents'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFDCFCE7),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFF86EFAC)),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified_user_rounded, color: Color(0xFF15803D), size: 28),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'KYC Verified & Approved',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Color(0xFF166534)),
                        ),
                        Text(
                          'All documents have been verified by the safety & compliance operations desk.',
                          style: TextStyle(fontSize: 12, color: Color(0xFF15803D)),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            const Text(
              'Submitted Documents',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildDocItem(
              context,
              title: 'Driving License',
              subtext: profile.drivingLicenseNumber != null && profile.drivingLicenseNumber!.isNotEmpty
                  ? 'Number: ${profile.drivingLicenseNumber}'
                  : 'Not submitted',
              doc: regProvider.getDocument(KycDocumentType.drivingLicenseFront),
              type: KycDocumentType.drivingLicenseFront,
              regProvider: regProvider,
            ),
            _buildDocItem(
              context,
              title: 'Vehicle RC (Registration Certificate)',
              subtext: profile.rcNumber != null && profile.rcNumber!.isNotEmpty
                  ? 'Number: ${profile.rcNumber}'
                  : (profile.vehicleNumber != null && profile.vehicleNumber!.isNotEmpty
                      ? 'Plate: ${profile.vehicleNumber}'
                      : 'Not submitted'),
              doc: regProvider.getDocument(KycDocumentType.vehicleRc),
              type: KycDocumentType.vehicleRc,
              regProvider: regProvider,
            ),
            _buildDocItem(
              context,
              title: 'Vehicle Insurance Policy',
              subtext: profile.insurancePolicyNumber != null && profile.insurancePolicyNumber!.isNotEmpty
                  ? 'Policy: ${profile.insurancePolicyNumber}'
                  : 'Not submitted',
              doc: regProvider.getDocument(KycDocumentType.vehicleInsurance),
              type: KycDocumentType.vehicleInsurance,
              regProvider: regProvider,
            ),
            _buildDocItem(
              context,
              title: 'Aadhaar / National ID',
              subtext: profile.aadhaarNumber != null && profile.aadhaarNumber!.isNotEmpty
                  ? 'Number: ${profile.aadhaarNumber}'
                  : 'Not submitted',
              doc: regProvider.getDocument(KycDocumentType.aadhaarFront),
              type: KycDocumentType.aadhaarFront,
              regProvider: regProvider,
            ),
            _buildDocItem(
              context,
              title: 'Income Tax PAN Card',
              subtext: profile.panNumber != null && profile.panNumber!.isNotEmpty
                  ? 'Number: ${profile.panNumber}'
                  : 'Not submitted',
              doc: regProvider.getDocument(KycDocumentType.panCard),
              type: KycDocumentType.panCard,
              regProvider: regProvider,
            ),
            _buildDocItem(
              context,
              title: 'Partner Profile Selfie',
              subtext: 'Verified Face Match',
              doc: regProvider.getDocument(KycDocumentType.profilePhoto),
              type: KycDocumentType.profilePhoto,
              regProvider: regProvider,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocItem(
    BuildContext context, {
    required String title,
    required String subtext,
    required KycDocument? doc,
    required KycDocumentType type,
    required RegistrationProvider regProvider,
  }) {
    final hasFile = doc?.localFilePath != null;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.description_outlined, color: AppColors.accentDark, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    Text(subtext, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Text(
                  'Verified',
                  style: TextStyle(color: Color(0xFF15803D), fontSize: 11, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          if (hasFile) ...[
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: Image.file(
                File(doc!.localFilePath!),
                height: 120,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const SizedBox.shrink(),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
