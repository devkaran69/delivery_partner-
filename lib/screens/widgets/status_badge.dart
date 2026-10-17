import 'package:flutter/material.dart';
import '../../models/cloth_order.dart';

class StatusBadge extends StatelessWidget {
  final ClothOrderStatus status;

  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    String label;
    Color bgColor;
    Color textColor;
    IconData icon;

    switch (status) {
      case ClothOrderStatus.pending:
        label = 'Store Ready';
        bgColor = const Color(0xFFEFF6FF);
        textColor = const Color(0xFF1D4ED8);
        icon = Icons.store_mall_directory_rounded;
        break;
      case ClothOrderStatus.accepted:
        label = 'Going to Store';
        bgColor = const Color(0xFFFFFBEB);
        textColor = const Color(0xFFB45309);
        icon = Icons.directions_bike_rounded;
        break;
      case ClothOrderStatus.arrivedAtStore:
        label = 'At Store';
        bgColor = const Color(0xFFFEF3C7);
        textColor = const Color(0xFFD97706);
        icon = Icons.pin_drop_rounded;
        break;
      case ClothOrderStatus.pickedUp:
        label = 'In Transit';
        bgColor = const Color(0xFFF0FDF4);
        textColor = const Color(0xFF15803D);
        icon = Icons.local_shipping_rounded;
        break;
      case ClothOrderStatus.arrivedAtCustomer:
        label = 'At Doorstep';
        bgColor = const Color(0xFFECFDF5);
        textColor = const Color(0xFF047857);
        icon = Icons.door_front_door_rounded;
        break;
      case ClothOrderStatus.delivered:
        label = 'Delivered';
        bgColor = const Color(0xFFDCFCE7);
        textColor = const Color(0xFF166534);
        icon = Icons.check_circle_rounded;
        break;
      case ClothOrderStatus.cancelled:
        label = 'Cancelled';
        bgColor = const Color(0xFFFEF2F2);
        textColor = const Color(0xFFB91C1C);
        icon = Icons.cancel_rounded;
        break;
      case ClothOrderStatus.returnPickup:
        label = 'Return Trip';
        bgColor = const Color(0xFFF5F3FF);
        textColor = const Color(0xFF6D28D9);
        icon = Icons.replay_rounded;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: textColor),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
