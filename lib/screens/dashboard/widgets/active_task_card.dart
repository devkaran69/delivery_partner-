import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/currency_formatter.dart';
import '../../../models/cloth_order.dart';
import '../../orders/task_navigation_screen.dart';
import '../../widgets/status_badge.dart';

class ActiveTaskCard extends StatelessWidget {
  final ClothOrder order;

  const ActiveTaskCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool isStoreLeg = order.status == ClothOrderStatus.accepted ||
        order.status == ClothOrderStatus.arrivedAtStore;

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => TaskNavigationScreen(order: order)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Badge & Earning
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isStoreLeg ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isStoreLeg ? const Color(0xFFFFEDD5) : const Color(0xFFA7F3D0),
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isStoreLeg ? Icons.store_rounded : Icons.local_shipping_rounded,
                            color: isStoreLeg ? const Color(0xFFC2410C) : const Color(0xFF047857),
                            size: 13,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isStoreLeg ? 'PICKUP FROM STORE' : 'DELIVER TO CUSTOMER',
                            style: TextStyle(
                              color: isStoreLeg ? const Color(0xFFC2410C) : const Color(0xFF047857),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      CurrencyFormatter.format(order.partnerEarnings),
                      style: const TextStyle(
                        color: AppColors.onlineGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Order Number & Status
                Row(
                  children: [
                    Text(
                      order.orderNumber,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    StatusBadge(status: order.status),
                  ],
                ),
                const SizedBox(height: 12),

                // Stop details (Store vs Customer)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isStoreLeg
                              ? const Color(0xFFFEF3C7)
                              : const Color(0xFFE0F2FE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isStoreLeg ? Icons.storefront_rounded : Icons.person_pin_circle_rounded,
                          color: isStoreLeg ? const Color(0xFFD97706) : const Color(0xFF0284C7),
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isStoreLeg ? order.storeName : order.customerName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            Text(
                              isStoreLeg ? order.storeAddress : order.customerAddress,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 14),

                // Item overview & Action button
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.checkroom_rounded, color: Color(0xFFF97316), size: 16),
                        const SizedBox(width: 6),
                        Text(
                          '${order.totalGarmentCount} Cloth Items (${order.packageCount} Pack)',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF97316),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Navigate',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
