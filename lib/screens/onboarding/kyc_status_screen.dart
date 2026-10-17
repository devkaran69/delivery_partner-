import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/registration_provider.dart';
import '../../providers/duty_provider.dart';
import '../dashboard/main_navigation_screen.dart';
import 'kyc_onboarding_screen.dart';

class KycStatusScreen extends StatelessWidget {
  const KycStatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final regProvider = Provider.of<RegistrationProvider>(context);
    final profile = regProvider.profile;
    final isApproved = profile.isKycApproved;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Partner Verification Status'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            tooltip: 'Check Status',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Status checked: Application is under review.')),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Main Status Banner Card
            // Main Status Banner Card (Light Mode)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isApproved ? null : Colors.white,
                gradient: isApproved
                    ? const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isApproved ? Colors.transparent : const Color(0xFFFED7AA),
                  width: 1.2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: isApproved
                        ? const Color(0xFF10B981).withValues(alpha: 0.25)
                        : Colors.black.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: isApproved
                          ? Colors.white.withValues(alpha: 0.2)
                          : const Color(0xFFFEF3C7),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isApproved ? Icons.verified_rounded : Icons.hourglass_top_rounded,
                      color: isApproved ? Colors.white : const Color(0xFFD97706),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    isApproved ? 'Profile Verified & Active!' : 'Application Under Review',
                    style: TextStyle(
                      color: isApproved ? Colors.white : AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isApproved
                        ? 'Congratulations! You are now eligible to pick up retail cloth orders.'
                        : 'Our operations team is verifying your Driving License, Vehicle RC, and Aadhaar documents.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: isApproved ? Colors.white70 : AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  if (!isApproved) ...[
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: const Color(0xFFFFEDD5)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.schedule, color: Color(0xFFD97706), size: 14),
                          SizedBox(width: 6),
                          Text(
                            'Estimated verification: 2-4 hours',
                            style: TextStyle(color: Color(0xFF92400E), fontSize: 12, fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Partner Summary Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Partner Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const Divider(height: 24),
                  _buildDetailRow('Partner Name', profile.name.isNotEmpty ? profile.name : 'Delivery Partner'),
                  _buildDetailRow('Phone Number', profile.phone.isNotEmpty ? profile.phone : 'Not provided'),
                  _buildDetailRow('Operating City', profile.city != null && profile.city!.isNotEmpty ? profile.city! : 'Not specified'),
                  _buildDetailRow(
                    'Vehicle Type',
                    profile.vehicleModel != null && profile.vehicleModel!.isNotEmpty
                        ? '${profile.vehicleType} (${profile.vehicleModel})'
                        : profile.vehicleType,
                  ),
                  _buildDetailRow('Vehicle Number', profile.vehicleNumber != null && profile.vehicleNumber!.isNotEmpty ? profile.vehicleNumber! : 'Not specified'),
                  _buildDetailRow('Driving License', profile.drivingLicenseNumber != null && profile.drivingLicenseNumber!.isNotEmpty ? profile.drivingLicenseNumber! : 'Not submitted'),
                  _buildDetailRow('Payout UPI ID', profile.upiId != null && profile.upiId!.isNotEmpty ? profile.upiId! : 'Not submitted'),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Document Checklist Card
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Document Verification Checklist',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 14),
                  _buildDocStatusItem('Driving License (Front & Back)', isApproved),
                  _buildDocStatusItem('Vehicle RC Registration', isApproved),
                  _buildDocStatusItem('Government Aadhaar / ID', isApproved),
                  _buildDocStatusItem('Income Tax PAN Card', isApproved),
                  _buildDocStatusItem('Bank Account & IFSC Verification', true),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Actions
            if (isApproved)
              ElevatedButton(
                onPressed: () {
                  // Sync updated profile to DutyProvider
                  final duty = Provider.of<DutyProvider>(context, listen: false);
                  duty.updateProfile(profile);
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const MainNavigationScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.onlineGreen,
                  minimumSize: const Size.fromHeight(54),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('Enter Partner Dashboard', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    SizedBox(width: 8),
                    Icon(Icons.arrow_forward_rounded, size: 20),
                  ],
                ),
              )
            else ...[
              // Fast-Track Demo Approval Button
              ElevatedButton.icon(
                onPressed: () {
                  regProvider.fastTrackApprove();
                  final duty = Provider.of<DutyProvider>(context, listen: false);
                  duty.updateProfile(regProvider.profile);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.onlineGreen,
                      content: Text('⚡ Fast-Track Approved! All features are now unlocked.'),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(52),
                ),
                icon: const Icon(Icons.flash_on_rounded, color: AppColors.accent),
                label: const Text(
                  'Fast-Track Approval (Demo Mode)',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () {
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(builder: (ctx) => const KycOnboardingScreen()),
                  );
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Edit Documents / Application'),
              ),
            ],
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          Text(value, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _buildDocStatusItem(String title, bool isVerified) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Icon(
            isVerified ? Icons.check_circle_rounded : Icons.pending_rounded,
            color: isVerified ? AppColors.onlineGreen : AppColors.pendingAmber,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
            ),
          ),
          Text(
            isVerified ? 'Verified' : 'Pending',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: isVerified ? AppColors.onlineGreen : AppColors.pendingAmber,
            ),
          ),
        ],
      ),
    );
  }
}
