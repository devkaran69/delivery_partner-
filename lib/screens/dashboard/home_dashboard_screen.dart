import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/cloth_order.dart';
import '../../providers/duty_provider.dart';
import '../../providers/order_provider.dart';
import '../orders/order_details_screen.dart';
import 'widgets/active_task_card.dart';
import 'widgets/duty_switch_bar.dart';
import 'widgets/incoming_order_sheet.dart';
import 'widgets/shift_stats_header.dart';

class HomeDashboardScreen extends StatelessWidget {
  const HomeDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final duty = Provider.of<DutyProvider>(context);
    final orderProv = Provider.of<OrderProvider>(context);
    final incomingOrder = orderProv.incomingOrder;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Hello, ${duty.profile.name}',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            Row(
              children: [
                Icon(
                  Icons.delivery_dining_rounded,
                  size: 13,
                  color: duty.isOnline ? AppColors.onlineGreen : AppColors.textMuted,
                ),
                const SizedBox(width: 4),
                Text(
                  duty.profile.vehicleNumber != null && duty.profile.vehicleNumber!.isNotEmpty
                      ? '${duty.profile.vehicleType} • ${duty.profile.vehicleNumber}'
                      : duty.profile.vehicleType,
                  style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                ),
              ],
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded, color: AppColors.pendingAmber),
            tooltip: 'Broadcast Live Order via Supabase',
            onPressed: () {
              orderProv.createAndBroadcastLiveOrderInSupabase();
            },
          ),
          Container(
            margin: const EdgeInsets.only(right: 16),
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.accent, width: 2),
            ),
            child: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.primary,
              child: Text(
                duty.profile.name.isNotEmpty ? duty.profile.name[0] : 'K',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {
              await Future.delayed(const Duration(milliseconds: 600));
            },
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(18, 14, 18, 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Online / Offline Duty Switcher
                  const DutySwitchBar(),
                  const SizedBox(height: 16),

                  // 2. Today's Shift & Earnings Card
                  const ShiftStatsHeader(),
                  const SizedBox(height: 20),

                  // 3. Active Delivery Card (If in progress)
                  if (orderProv.hasActiveOrder) ...[
                    const Text(
                      'ACTIVE TRIP IN PROGRESS',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: AppColors.accentDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ActiveTaskCard(order: orderProv.activeOrder!),
                  ],

                  // 4. Available Store Pickups in Zone
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Available Store Orders',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        '${orderProv.availableOrders.length} in your zone',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (orderProv.availableOrders.isEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          const Icon(Icons.store_mall_directory_outlined, size: 48, color: AppColors.textMuted),
                          const SizedBox(height: 12),
                          const Text(
                            'No pending orders right now',
                            style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            'Stay online! As soon as an onboarded cloth store dispatches an order, you will be notified.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () => orderProv.createAndBroadcastLiveOrderInSupabase(),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            ),
                            icon: const Icon(Icons.add_shopping_cart, size: 16),
                            label: const Text('Broadcast Live Order (Supabase)', style: TextStyle(fontSize: 13)),
                          ),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: orderProv.availableOrders.length,
                      itemBuilder: (ctx, idx) {
                        final order = orderProv.availableOrders[idx];
                        return _buildAvailableOrderCard(context, order, orderProv);
                      },
                    ),
                ],
              ),
            ),
          ),

          // Incoming Order Alert Modal Sheet (Bottom Overlay)
          if (incomingOrder != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: IncomingOrderSheet(
                order: incomingOrder,
                countdownSeconds: orderProv.incomingCountdown,
                onAccept: () {
                  orderProv.acceptOrder(incomingOrder);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      backgroundColor: AppColors.onlineGreen,
                      content: Text('Order ${incomingOrder.orderNumber} accepted! Navigating to store.'),
                    ),
                  );
                },
                onDecline: () => orderProv.declineIncomingOrder(),
              ),
            ),
        ],
      ),
      floatingActionButton: orderProv.incomingOrder == null && !orderProv.hasActiveOrder
          ? FloatingActionButton.extended(
              onPressed: () {
                orderProv.triggerIncomingOrderAlert();
              },
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.flash_on_rounded, color: AppColors.accent),
              label: const Text('Simulate Order', style: TextStyle(fontWeight: FontWeight.bold)),
            )
          : null,
    );
  }

  Widget _buildAvailableOrderCard(
    BuildContext context,
    ClothOrder order,
    OrderProvider orderProv,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (ctx) => OrderDetailsScreen(order: order)),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top Row: Store Name & Earning
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.storefront_rounded, color: AppColors.pendingAmber, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          order.storeName,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    Text(
                      CurrencyFormatter.format(order.partnerEarnings),
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Pickup address
                Text(
                  order.storeAddress,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                ),
                const Divider(height: 20),

                // Garment summary & Action
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: const Color(0xFFEFF6FF),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${order.totalGarmentCount} Items',
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF1D4ED8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${order.distanceKm} km away',
                          style: const TextStyle(fontSize: 12, color: AppColors.textMuted),
                        ),
                      ],
                    ),
                    ElevatedButton(
                      onPressed: () {
                        orderProv.acceptOrder(order);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            backgroundColor: AppColors.onlineGreen,
                            content: Text('Accepted ${order.orderNumber}! Navigating to store.'),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        minimumSize: Size.zero,
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text('Accept', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
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
