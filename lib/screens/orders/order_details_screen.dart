import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/cloth_order.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';
import '../widgets/status_badge.dart';
import 'task_navigation_screen.dart';
import 'order_verification_screen.dart';

class OrderDetailsScreen extends StatelessWidget {
  final ClothOrder order;

  const OrderDetailsScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final locProv = Provider.of<LocationProvider>(context);

    // Get live updated instance if it's the active order
    final liveOrder = (orderProv.activeOrder?.id == order.id)
        ? orderProv.activeOrder!
        : order;

    final isAvailable = orderProv.availableOrders.any((o) => o.id == liveOrder.id);
    final isActive = orderProv.activeOrder?.id == liveOrder.id;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(liveOrder.orderNumber),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(child: StatusBadge(status: liveOrder.status)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Store Pickup Section Card
            _buildStoreCard(context, liveOrder, locProv),
            const SizedBox(height: 16),

            // Customer Delivery Section Card
            _buildCustomerCard(context, liveOrder, locProv),
            const SizedBox(height: 16),

            // Packaged Apparel Items Checklist Card
            _buildItemsCard(liveOrder),
            const SizedBox(height: 16),

            // Payment & Earnings Breakdown Card
            _buildPaymentCard(liveOrder),
            const SizedBox(height: 24),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: SafeArea(
          child: _buildBottomActions(context, liveOrder, orderProv, isAvailable, isActive),
        ),
      ),
    );
  }

  Widget _buildStoreCard(BuildContext context, ClothOrder order, LocationProvider loc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFEF3C7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.storefront_rounded, color: Color(0xFFD97706), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'SELLER STORE (PICKUP)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFB45309),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.call, color: AppColors.onlineGreen),
                tooltip: 'Call Store',
                onPressed: () => loc.makePhoneCall(order.storePhone),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.storeName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            order.storeAddress,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.person_outline, size: 15, color: AppColors.textMuted),
              const SizedBox(width: 6),
              Text(
                'Contact: ${order.storeContactPerson}',
                style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.pin, size: 14, color: AppColors.textSecondary),
                const SizedBox(width: 6),
                Text(
                  'Store Pickup OTP: ${order.storePickupOtp}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerCard(BuildContext context, ClothOrder order, LocationProvider loc) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFDCFCE7),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.person_pin_circle_rounded, color: Color(0xFF15803D), size: 20),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'CUSTOMER (DELIVERY)',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF15803D),
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentDark),
                    tooltip: 'WhatsApp Customer',
                    onPressed: () => loc.openWhatsApp(order.customerPhone),
                  ),
                  IconButton(
                    icon: const Icon(Icons.call, color: AppColors.onlineGreen),
                    tooltip: 'Call Customer',
                    onPressed: () => loc.makePhoneCall(order.customerPhone),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            order.customerName,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            order.customerAddress,
            style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
          ),
          if (order.deliveryInstructions != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFBEB),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFFFDE68A)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, size: 16, color: Color(0xFFB45309)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Note: ${order.deliveryInstructions}',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF92400E)),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildItemsCard(ClothOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Packaged Clothes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${order.packageCount} Sealed Parcel',
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1D4ED8),
                  ),
                ),
              ),
            ],
          ),
          const Divider(height: 20),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: order.items.length,
            separatorBuilder: (ctx, i) => const Divider(height: 16),
            itemBuilder: (ctx, i) {
              final item = order.items[i];
              return Row(
                children: [
                  Container(
                    height: 48,
                    width: 48,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.checkroom_rounded, color: AppColors.accentDark),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.name,
                          style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
                        ),
                        Text(
                          '${item.brand} • Size: ${item.size} • Color: ${item.color}',
                          style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    'x${item.quantity}',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentCard(ClothOrder order) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Payment & Rider Earnings',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const Divider(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Payment Mode', style: TextStyle(color: AppColors.textSecondary)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: order.isCod ? const Color(0xFFFFFBEB) : const Color(0xFFF0FDF4),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  order.isCod ? 'CASH ON DELIVERY' : 'ONLINE PREPAID',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: order.isCod ? const Color(0xFFB45309) : const Color(0xFF15803D),
                  ),
                ),
              ),
            ],
          ),
          if (order.isCod) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Cash to Collect at Door', style: TextStyle(fontWeight: FontWeight.w600)),
                Text(
                  CurrencyFormatter.format(order.codAmountToCollect),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.urgentRed),
                ),
              ],
            ),
          ],
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Your Guaranteed Earning', style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                CurrencyFormatter.format(order.partnerEarnings),
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF15803D)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    ClothOrder order,
    OrderProvider orderProv,
    bool isAvailable,
    bool isActive,
  ) {
    if (isAvailable) {
      return ElevatedButton(
        onPressed: () {
          orderProv.acceptOrder(order);
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (ctx) => TaskNavigationScreen(order: order)),
          );
        },
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.onlineGreen),
        child: const Text('ACCEPT ORDER FOR STORE PICKUP'),
      );
    }

    if (isActive) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => TaskNavigationScreen(order: order)),
                );
              },
              icon: const Icon(Icons.navigation_rounded),
              label: const Text('Route Map'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (ctx) => OrderVerificationScreen(order: order)),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary),
              child: Text(
                order.status == ClothOrderStatus.arrivedAtStore || order.status == ClothOrderStatus.accepted
                    ? 'Verify Store Pickup'
                    : 'Verify Customer Delivery',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ),
        ],
      );
    }

    return ElevatedButton(
      onPressed: () => Navigator.pop(context),
      child: const Text('Back to Orders'),
    );
  }
}
