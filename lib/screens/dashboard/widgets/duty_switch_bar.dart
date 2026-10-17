import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/constants/app_colors.dart';
import '../../../providers/duty_provider.dart';

class DutySwitchBar extends StatelessWidget {
  const DutySwitchBar({super.key});

  @override
  Widget build(BuildContext context) {
    final duty = Provider.of<DutyProvider>(context);
    final isOnline = duty.isOnline;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isOnline ? const Color(0xFFECFDF5) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isOnline ? const Color(0xFF6EE7B7) : AppColors.border,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isOnline
                ? const Color(0xFF10B981).withValues(alpha: 0.12)
                : Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Live Pulsing Dot
          Container(
            height: 12,
            width: 12,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isOnline ? AppColors.onlineGreen : AppColors.offlineGrey,
              boxShadow: isOnline
                  ? [
                      BoxShadow(
                        color: AppColors.onlineGreen.withValues(alpha: 0.5),
                        blurRadius: 8,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 12),

          // Status Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isOnline ? 'DUTY ONLINE' : 'DUTY OFFLINE',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.5,
                    color: isOnline ? const Color(0xFF065F46) : AppColors.textPrimary,
                  ),
                ),
                Text(
                  isOnline ? 'Active for nearby cloth pickups' : 'Go online to receive store orders',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isOnline ? const Color(0xFF047857) : AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Switch
          Switch(
            value: isOnline,
            activeThumbColor: AppColors.onlineGreen,
            activeTrackColor: const Color(0xFFA7F3D0),
            inactiveThumbColor: AppColors.offlineGrey,
            inactiveTrackColor: AppColors.border,
            onChanged: (val) {
              duty.toggleDuty();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  duration: const Duration(seconds: 2),
                  backgroundColor: val ? AppColors.onlineGreen : AppColors.primary,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.all(16),
                  content: Text(
                    val
                        ? '🟢 You are now ONLINE. You will receive store orders.'
                        : '⚪ You are now OFFLINE. Shift paused.',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
