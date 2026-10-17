import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../providers/order_provider.dart';
import '../earnings/earnings_screen.dart';
import '../orders/order_list_screen.dart';
import '../profile/partner_profile_screen.dart';
import 'home_dashboard_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    HomeDashboardScreen(),
    OrderListScreen(),
    EarningsScreen(),
    PartnerProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final orderProv = Provider.of<OrderProvider>(context);

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border, width: 1)),
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          backgroundColor: Colors.white,
          indicatorColor: AppColors.primary.withValues(alpha: 0.08),
          elevation: 0,
          onDestinationSelected: (idx) => setState(() => _currentIndex = idx),
          destinations: [
            const NavigationDestination(
              icon: Icon(Icons.dashboard_outlined),
              selectedIcon: Icon(Icons.dashboard_rounded, color: AppColors.primary),
              label: 'Dashboard',
            ),
            NavigationDestination(
              icon: Badge(
                isLabelVisible: orderProv.hasActiveOrder || orderProv.availableOrders.isNotEmpty,
                label: Text('${orderProv.hasActiveOrder ? 1 : orderProv.availableOrders.length}'),
                backgroundColor: orderProv.hasActiveOrder ? AppColors.accentDark : AppColors.primary,
                child: const Icon(Icons.local_shipping_outlined),
              ),
              selectedIcon: Badge(
                isLabelVisible: orderProv.hasActiveOrder || orderProv.availableOrders.isNotEmpty,
                label: Text('${orderProv.hasActiveOrder ? 1 : orderProv.availableOrders.length}'),
                backgroundColor: orderProv.hasActiveOrder ? AppColors.accentDark : AppColors.primary,
                child: const Icon(Icons.local_shipping_rounded, color: AppColors.primary),
              ),
              label: 'Orders',
            ),
            const NavigationDestination(
              icon: Icon(Icons.account_balance_wallet_outlined),
              selectedIcon: Icon(Icons.account_balance_wallet_rounded, color: AppColors.primary),
              label: 'Earnings',
            ),
            const NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded, color: AppColors.primary),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}
