import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/location_provider.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LocationProvider>(context, listen: false);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Help & Partner Support'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Emergency SOS Card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFFFEF2F2),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFFECACA), width: 1.5),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: AppColors.urgentRed,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.sos_rounded, color: Colors.white, size: 28),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Emergency Road SOS',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.urgentRed),
                        ),
                        const SizedBox(height: 2),
                        const Text(
                          'Accident or medical emergency during transit',
                          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => loc.makePhoneCall('112'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.urgentRed,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text('Call 112', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Operations Dispatch Hotline
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Row(
                children: [
                  const Icon(Icons.headset_mic_rounded, color: AppColors.accentDark, size: 26),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Operations Support Desk', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                        Text('Available 8 AM - 11 PM', style: TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      ],
                    ),
                  ),
                  IconButton.filledTonal(
                    onPressed: () => loc.makePhoneCall('+911800123456'),
                    icon: const Icon(Icons.call, color: AppColors.onlineGreen),
                    tooltip: 'Call Support',
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Quick Issue Resolutions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),

            _buildIncidentTile(
              context,
              icon: Icons.store_mall_directory_outlined,
              title: 'Clothing Store is Closed / Unreachable',
              subtitle: 'Wait 5 minutes, call seller manager, or report unfulfilled pickup',
            ),
            _buildIncidentTile(
              context,
              icon: Icons.person_off_outlined,
              title: 'Customer Not Responding / Door Locked',
              subtitle: 'Ringing bell twice and attempted phone calls before return request',
            ),
            _buildIncidentTile(
              context,
              icon: Icons.inventory_2_outlined,
              title: 'Torn Packing or Damaged Garments',
              subtitle: 'Report defective parcel packaging before accepting pickup from store',
            ),
            _buildIncidentTile(
              context,
              icon: Icons.build_outlined,
              title: 'Vehicle Flat Tyre / Mechanical Breakdown',
              subtitle: 'Re-assign active order to nearby backup rider in zone',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIncidentTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppColors.primary, size: 20),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textMuted),
        onTap: () {
          showDialog(
            context: context,
            builder: (ctx) => AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              content: Text('$subtitle\n\nWould you like to notify dispatch or connect to live agent?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Dismiss')),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ticket created. Dispatch notified.')),
                    );
                  },
                  child: const Text('Notify Dispatch'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
