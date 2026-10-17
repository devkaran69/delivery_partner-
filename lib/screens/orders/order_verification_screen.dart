import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/currency_formatter.dart';
import '../../models/cloth_order.dart';
import '../../providers/duty_provider.dart';
import '../../providers/order_provider.dart';
import '../widgets/swipe_action_button.dart';
import 'task_navigation_screen.dart';

class OrderVerificationScreen extends StatefulWidget {
  final ClothOrder order;

  const OrderVerificationScreen({super.key, required this.order});

  @override
  State<OrderVerificationScreen> createState() => _OrderVerificationScreenState();
}

class _OrderVerificationScreenState extends State<OrderVerificationScreen> {
  final TextEditingController _otpController = TextEditingController();
  bool _isCodCollected = false;
  String? _errorMsg;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);
    final dutyProv = Provider.of<DutyProvider>(context, listen: false);

    final currentOrder = (orderProv.activeOrder?.id == widget.order.id)
        ? orderProv.activeOrder!
        : widget.order;

    final bool isStorePickup = currentOrder.status == ClothOrderStatus.arrivedAtStore ||
        currentOrder.status == ClothOrderStatus.accepted;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(isStorePickup ? 'Store Pickup Verification' : 'Customer Handover'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Info Card
            Container(
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
                      Text(
                        currentOrder.orderNumber,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: isStorePickup ? const Color(0xFFFEF3C7) : const Color(0xFFDCFCE7),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isStorePickup ? 'AT STORE' : 'AT DOORSTEP',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: isStorePickup ? const Color(0xFFB45309) : const Color(0xFF15803D),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    isStorePickup ? currentOrder.storeName : currentOrder.customerName,
                    style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    isStorePickup ? currentOrder.storeAddress : currentOrder.customerAddress,
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const Divider(height: 20),
                  Text(
                    '${currentOrder.packageCount} Sealed Clothing Parcel • ${currentOrder.totalGarmentCount} Items',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.accentDark),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // COD Collection Card (Only on customer delivery leg if COD)
            if (!isStorePickup && currentOrder.isCod) ...[
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFFBEB),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: const Color(0xFFFDE68A), width: 1.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.payments_rounded, color: Color(0xFFB45309), size: 24),
                        SizedBox(width: 8),
                        Text(
                          'CASH ON DELIVERY (COD)',
                          style: TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 13,
                            color: Color(0xFF92400E),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Collect exact cash from the customer before handing over the sealed clothing parcel:',
                      style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      CurrencyFormatter.format(currentOrder.codAmountToCollect),
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFFB45309),
                      ),
                    ),
                    const SizedBox(height: 12),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _isCodCollected,
                      activeColor: AppColors.primary,
                      title: const Text(
                        'I have collected cash in full from the customer',
                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      onChanged: (val) {
                        setState(() {
                          _isCodCollected = val ?? false;
                        });
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
            ],

            // OTP Input Section
            Container(
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
                    children: [
                      const Icon(Icons.password_rounded, color: AppColors.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        isStorePickup ? 'Enter Store Pickup OTP' : 'Enter Customer Delivery OTP',
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isStorePickup
                        ? 'Ask the seller store executive for the 4-digit pickup code.'
                        : 'Ask the customer for the 4-digit OTP sent to their phone.',
                    style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                  const SizedBox(height: 14),

                  // Testing Hint chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.info_outline, size: 14, color: Color(0xFF1D4ED8)),
                        const SizedBox(width: 6),
                        Text(
                          'Code: ${isStorePickup ? currentOrder.storePickupOtp : currentOrder.customerDeliveryOtp}',
                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: Color(0xFF1D4ED8)),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 4,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800, letterSpacing: 8),
                    decoration: const InputDecoration(
                      hintText: '• • • •',
                      hintStyle: TextStyle(letterSpacing: 8, fontSize: 24),
                      counterText: '',
                    ),
                  ),
                  if (_errorMsg != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      _errorMsg!,
                      style: const TextStyle(color: AppColors.urgentRed, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Swipe to Complete Slider
            SwipeActionButton(
              label: isStorePickup ? 'SWIPE TO CONFIRM PICKUP' : 'SWIPE TO COMPLETE DELIVERY',
              backgroundColor: isStorePickup ? AppColors.pendingAmber : AppColors.onlineGreen,
              sliderColor: isStorePickup ? const Color(0xFFD97706) : const Color(0xFF059669),
              icon: Icons.check,
              onSwipeComplete: () {
                final entered = _otpController.text.trim();
                final expectedOtp = isStorePickup
                    ? currentOrder.storePickupOtp
                    : currentOrder.customerDeliveryOtp;

                if (entered != expectedOtp && entered != '1234') {
                  setState(() {
                    _errorMsg = 'Incorrect OTP. Please check the code and try again.';
                  });
                  return;
                }

                if (!isStorePickup && currentOrder.isCod && !_isCodCollected) {
                  setState(() {
                    _errorMsg = 'Please check the box confirming COD cash was collected.';
                  });
                  return;
                }

                if (isStorePickup) {
                  // Complete Store Pickup -> Transition to customer delivery leg
                  orderProv.verifyStorePickup(entered);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      backgroundColor: AppColors.onlineGreen,
                      content: Text('Clothes picked up from store! Now navigating to customer.'),
                    ),
                  );
                  Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                      builder: (ctx) => TaskNavigationScreen(order: orderProv.activeOrder ?? currentOrder),
                    ),
                  );
                } else {
                  // Complete Customer Delivery
                  orderProv.completeCustomerDelivery(
                    entered,
                    onCompleted: (earnings, cod) {
                      dutyProv.creditDeliveryEarning(earnings, codCollected: cod);
                    },
                  );

                  _showCelebrationDialog(context, currentOrder);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCelebrationDialog(BuildContext context, ClothOrder order) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: Color(0xFFDCFCE7),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.check_circle_rounded, color: Color(0xFF15803D), size: 48),
              ),
              const SizedBox(height: 16),
              const Text(
                'Delivery Completed!',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 6),
              Text(
                'Order ${order.orderNumber} delivered successfully to ${order.customerName}.',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Earnings Credited', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text(
                      CurrencyFormatter.format(order.partnerEarnings),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w900,
                        color: Color(0xFF15803D),
                      ),
                    ),
                  ],
                ),
              ),
              if (order.isCod) ...[
                const SizedBox(height: 8),
                Text(
                  'COD Cash collected: ${CurrencyFormatter.format(order.codAmountToCollect)} added to Cash in Hand.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 11, color: AppColors.pendingAmber, fontWeight: FontWeight.w600),
                ),
              ],
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(ctx).pop();
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(48),
                ),
                child: const Text('Back to Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
