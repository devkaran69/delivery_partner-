import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/cloth_order.dart';
import '../../providers/location_provider.dart';
import '../../providers/order_provider.dart';
import 'order_verification_screen.dart';

class TaskNavigationScreen extends StatelessWidget {
  final ClothOrder order;

  const TaskNavigationScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final locProv = Provider.of<LocationProvider>(context);

    final currentOrder = (orderProv.activeOrder?.id == order.id)
        ? orderProv.activeOrder!
        : order;

    final bool isStoreLeg = currentOrder.status == ClothOrderStatus.accepted ||
        currentOrder.status == ClothOrderStatus.arrivedAtStore;

    final destName = isStoreLeg ? currentOrder.storeName : currentOrder.customerName;
    final destAddress = isStoreLeg ? currentOrder.storeAddress : currentOrder.customerAddress;
    final destPhone = isStoreLeg ? currentOrder.storePhone : currentOrder.customerPhone;
    final destLat = isStoreLeg ? currentOrder.storeLatitude : currentOrder.customerLatitude;
    final destLng = isStoreLeg ? currentOrder.storeLongitude : currentOrder.customerLongitude;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isStoreLeg ? 'Navigating to Store' : 'Navigating to Customer'),
        actions: [
          IconButton(
            icon: const Icon(Icons.near_me_rounded, color: AppColors.accentDark),
            tooltip: 'Open in Google Maps',
            onPressed: () {
              locProv.launchNavigation(destLat, destLng, label: destName);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // Visual Map & Route Simulation View
          Positioned.fill(
            child: _buildInteractiveMapSimulation(
              context,
              isStoreLeg: isStoreLeg,
              destName: destName,
              order: currentOrder,
            ),
          ),

          // Top Floating Navigation Bar (Direction Banner)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: isStoreLeg ? const Color(0xFFFFF7ED) : const Color(0xFFECFDF5),
                      border: Border.all(
                        color: isStoreLeg ? const Color(0xFFFFEDD5) : const Color(0xFFA7F3D0),
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isStoreLeg ? Icons.turn_right_rounded : Icons.straight_rounded,
                      color: isStoreLeg ? const Color(0xFFC2410C) : const Color(0xFF047857),
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          isStoreLeg ? 'In 350m, turn right onto Main Ring Road' : 'In 600m, head straight towards Tower 4',
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Destination: $destName',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Stop Card & Arrival Trigger
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 15,
                    offset: Offset(0, -4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Distance & Duration Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: isStoreLeg ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              isStoreLeg ? 'STORE PICKUP' : 'CUSTOMER DROP',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isStoreLeg ? const Color(0xFFB45309) : const Color(0xFF15803D),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${currentOrder.distanceKm} km • ${currentOrder.estimatedDurationMinutes} mins',
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        CurrencyFormatter.format(currentOrder.partnerEarnings),
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF15803D),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Stop Name & Address
                  Text(
                    destName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    destAddress,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Actions row (Call, WhatsApp, Google Maps)
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => locProv.makePhoneCall(destPhone),
                        icon: const Icon(Icons.call, color: AppColors.onlineGreen),
                        tooltip: 'Call Phone',
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: () => locProv.openWhatsApp(destPhone),
                        icon: const Icon(Icons.chat_bubble_outline_rounded, color: AppColors.accentDark),
                        tooltip: 'WhatsApp Message',
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton.icon(
                        onPressed: () => locProv.launchNavigation(destLat, destLng, label: destName),
                        icon: const Icon(Icons.map_outlined, size: 18),
                        label: const Text('Google Maps'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Arrival Button
                  ElevatedButton(
                    onPressed: () {
                      if (isStoreLeg) {
                        orderProv.markArrivedAtStore();
                      } else {
                        orderProv.markArrivedAtCustomer();
                      }
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (ctx) => OrderVerificationScreen(order: currentOrder),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isStoreLeg ? AppColors.pendingAmber : AppColors.onlineGreen,
                      minimumSize: const Size.fromHeight(52),
                    ),
                    child: Text(
                      isStoreLeg ? 'I HAVE ARRIVED AT STORE' : 'I HAVE ARRIVED AT CUSTOMER',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
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

  Widget _buildInteractiveMapSimulation(
    BuildContext context, {
    required bool isStoreLeg,
    required String destName,
    required ClothOrder order,
  }) {
    return Container(
      color: const Color(0xFFE2E8F0),
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Simulated Grid Roads
          CustomPaint(
            size: Size.infinite,
            painter: _MapRoadPainter(),
          ),

          // Destination Waypoint Pin
          Positioned(
            top: 180,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: isStoreLeg ? AppColors.pendingAmber : AppColors.onlineGreen,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 6)],
                  ),
                  child: Text(
                    destName,
                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
                Icon(
                  isStoreLeg ? Icons.store_rounded : Icons.location_on_rounded,
                  size: 44,
                  color: isStoreLeg ? AppColors.pendingAmber : AppColors.onlineGreen,
                ),
              ],
            ),
          ),

          // Rider Waypoint Pin
          Positioned(
            bottom: 270,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: const BoxDecoration(
                    color: AppColors.primary,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 2)],
                  ),
                  child: const Icon(Icons.two_wheeler_rounded, color: Colors.white, size: 28),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.black87,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'You',
                    style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MapRoadPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final bgPaint = Paint()..color = const Color(0xFFE5E9F0);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), bgPaint);

    final roadPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 32
      ..style = PaintingStyle.stroke;

    final polylinePaint = Paint()
      ..color = const Color(0xFF06B6D4)
      ..strokeWidth = 6
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.7);
    path.lineTo(size.width * 0.5, size.height * 0.5);
    path.lineTo(size.width * 0.65, size.height * 0.4);
    path.lineTo(size.width * 0.5, size.height * 0.28);

    canvas.drawPath(path, roadPaint);
    canvas.drawPath(path, polylinePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
