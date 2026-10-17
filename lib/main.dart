import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'core/constants/app_theme.dart';
import 'models/partner_profile.dart';
import 'providers/duty_provider.dart';
import 'providers/location_provider.dart';
import 'providers/order_provider.dart';
import 'providers/registration_provider.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard/main_navigation_screen.dart';
import 'screens/onboarding/kyc_onboarding_screen.dart';
import 'screens/onboarding/kyc_status_screen.dart';
import 'services/auth_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase for data storage
  await Supabase.initialize(
    url: 'https://bidazugysrpaeqghgemn.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImJpZGF6dWd5c3JwYWVxZ2hnZW1uIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODg2Mzg2MjgsImV4cCI6MjEwNDIxNDYyOH0.qPHSHNt6bxqywSeFovriHSbG9J9cWDEdVY1zLd_a4AI',
  );

  // Initialize Firebase for Phone OTP Auth
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Firebase init error: $e");
  }

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => RegistrationProvider()),
        ChangeNotifierProvider(create: (_) => DutyProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => LocationProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cloth Delivery Partner',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: const AuthWrapper(),
    );
  }
}

// ==========================================
// AUTH WRAPPER (Handles Auth & KYC Routing)
// ==========================================
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();

  bool _isFetchingProfile = false;

  @override
  void initState() {
    super.initState();

    // Listen to Firebase Auth State changes
    _authService.onAuthStateChange.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> _fetchAndSyncProfile(
    String phone,
    RegistrationProvider regProvider,
    DutyProvider dutyProvider,
    OrderProvider orderProvider,
  ) async {
    if (_isFetchingProfile) return;
    _isFetchingProfile = true;

    try {
      final profile = await _authService.fetchPartnerProfileFromSupabase(phone);
      if (profile != null) {
        regProvider.updateProfile(profile);
        dutyProvider.updateProfile(profile);
        orderProvider.setActivePartner(profile.id);
      } else {
        final newProfile = PartnerProfile.initial(
          phone,
          name: FirebaseAuth.instance.currentUser?.displayName,
        );
        regProvider.updateProfile(newProfile);
        dutyProvider.updateProfile(newProfile);
        orderProvider.setActivePartner(newProfile.id);
      }
    } catch (_) {} finally {
      _isFetchingProfile = false;
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final regProvider = Provider.of<RegistrationProvider>(context);
    final dutyProvider = Provider.of<DutyProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    // 0. Direct Debug Bypass (Allows direct entry without login / auth check)
    if (regProvider.isDebugBypass) {
      return const MainNavigationScreen();
    }

    final hasFirebaseSession = FirebaseAuth.instance.currentUser != null;

    // 1. If not authenticated, show simple Light Mode Login Screen
    if (!hasFirebaseSession) {
      return const LoginScreen();
    }

    final phone = FirebaseAuth.instance.currentUser?.phoneNumber ?? '';
    if (phone.isNotEmpty && regProvider.profile.phone != phone) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _fetchAndSyncProfile(phone, regProvider, dutyProvider, orderProvider);
      });
    }

    // 2. Check Partner Registration & KYC Verification Status
    final kycStatus = regProvider.kycStatus;

    if (kycStatus == KycApplicationStatus.approved) {
      return const MainNavigationScreen();
    } else if (kycStatus == KycApplicationStatus.underReview) {
      return const KycStatusScreen();
    } else {
      return const KycOnboardingScreen();
    }
  }
}
