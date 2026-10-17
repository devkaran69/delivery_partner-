import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/registration_provider.dart';
import '../services/auth_service.dart';
import 'dashboard/main_navigation_screen.dart';
import 'onboarding/welcome_onboarding_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _authService = AuthService();

  final _countryCodeController = TextEditingController(text: '+91');
  final _phoneController = TextEditingController();
  final _nameController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _otpSent = false;
  String _verificationId = '';
  int? _resendToken;

  Timer? _countdownTimer;
  int _timerSeconds = 30;

  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _animController.dispose();
    _countryCodeController.dispose();
    _phoneController.dispose();
    _nameController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    _countdownTimer?.cancel();
    setState(() => _timerSeconds = 30);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timerSeconds > 0) {
        setState(() => _timerSeconds--);
      } else {
        timer.cancel();
      }
    });
  }

  String get _normalizedPhoneNumber {
    String phone = _phoneController.text.trim().replaceAll(RegExp(r'[\s\-]'), '');
    String countryCode = _countryCodeController.text.trim();
    if (!countryCode.startsWith('+')) {
      countryCode = '+$countryCode';
    }

    if (phone.startsWith(countryCode)) {
      phone = phone.substring(countryCode.length);
    } else if (countryCode == '+91' && phone.startsWith('91') && phone.length > 10) {
      phone = phone.substring(2);
    } else if (phone.startsWith('0')) {
      phone = phone.replaceFirst(RegExp(r'^0+'), '');
    }

    return '$countryCode$phone';
  }

  Future<void> _verifyPhone({bool isResend = false}) async {
    final fullPhone = _normalizedPhoneNumber;
    final digitsOnly = fullPhone.replaceAll(RegExp(r'[^\d]'), '');

    if (digitsOnly.length < 10) {
      _showToast('Please enter a valid 10-digit mobile number.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyPhoneNumber(
        phoneNumber: fullPhone,
        forceResendingToken: isResend ? _resendToken : null,
        verificationCompleted: (PhoneAuthCredential credential) async {
          try {
            await _authService.signInWithPhoneAuthCredential(
              credential,
              displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
            );
            if (mounted) {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
                (route) => false,
              );
            }
          } catch (e) {
            if (mounted) {
              _showToast('Auto-verification failed: $e', isError: true);
              setState(() => _isLoading = false);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint("❌ Firebase Phone Auth Error: ${e.code} - ${e.message}");
          if (mounted) {
            String errorMsg = e.message ?? 'Verification failed';
            if (e.code == 'billing-not-enabled') {
              errorMsg = 'SMS billing not enabled. Use Direct Enter or add this number in Firebase Console test numbers.';
            } else if (e.code == 'quota-exceeded') {
              errorMsg = 'SMS quota reached. Use the Direct Enter button below to test.';
            } else if (e.code == 'invalid-phone-number') {
              errorMsg = 'Invalid phone number format.';
            }
            _showToast(errorMsg, isError: true);
            setState(() => _isLoading = false);
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          if (mounted) {
            setState(() {
              _verificationId = verificationId;
              _resendToken = resendToken;
              _otpSent = true;
              _isLoading = false;
            });
            _startResendTimer();
            _showToast(isResend ? 'Verification code resent!' : 'OTP sent successfully via Firebase!');
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          if (mounted) {
            setState(() => _verificationId = verificationId);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        _showToast('Error: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _verifyOTP() async {
    final code = _otpController.text.trim();
    if (code.length < 6) {
      _showToast('Please enter the full 6-digit OTP code.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      await _authService.verifyOTPAndSignIn(
        verificationId: _verificationId,
        smsCode: code,
        displayName: _nameController.text.trim().isNotEmpty ? _nameController.text.trim() : null,
      );

      // Fast track KYC approval for verified driver
      if (mounted) {
        final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
        regProvider.fastTrackApprove();

        _showToast('Login verified successfully!');
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (mounted) {
        String msg = e.message ?? 'Invalid verification code';
        if (e.code == 'invalid-verification-code') {
          msg = 'Incorrect 6-digit code. Please check and try again.';
        } else if (e.code == 'session-expired') {
          msg = 'Verification code expired. Please tap Resend OTP.';
        }
        _showToast(msg, isError: true);
        setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) {
        _showToast('Verification failed: $e', isError: true);
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleDirectDebugEnter() {
    final regProvider = Provider.of<RegistrationProvider>(context, listen: false);
    regProvider.enterDebugMode();

    // Silently attempt anonymous login in background if available
    try {
      FirebaseAuth.instance.signInAnonymously().then<void>((_) {}).catchError((_) {});
    } catch (_) {}

    _showToast('⚡ Instant Access: Direct entry to dashboard');

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const MainNavigationScreen()),
      (route) => false,
    );
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
              color: isError ? Colors.red.shade700 : AppColors.onlineGreen,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: GoogleFonts.plusJakartaSans(
                  color: AppColors.textPrimary,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? const Color(0xFFFEF2F2) : const Color(0xFFF0FDF4),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isError ? const Color(0xFFFECACA) : const Color(0xFFBBF7D0),
            width: 1,
          ),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryColor = Color(0xFFF97316); // Delivery Orange
    const bgLight = Color(0xFFF8FAFC); // Clean light background

    return Scaffold(
      backgroundColor: bgLight,
      body: Stack(
        children: [
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // --- BRAND ICON HEADER ---
                        Center(
                          child: Container(
                            width: 76,
                            height: 76,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: const LinearGradient(
                                colors: [primaryColor, Color(0xFFEA580C)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: primaryColor.withValues(alpha: 0.28),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.electric_moped_rounded,
                              color: Colors.white,
                              size: 40,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Partner status pill
                        Center(
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF7ED),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: const Color(0xFFFFEDD5),
                                width: 1.2,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 8,
                                  height: 8,
                                  decoration: const BoxDecoration(
                                    color: AppColors.onlineGreen,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'DELIVERY PARTNER PORTAL',
                                  style: GoogleFonts.plusJakartaSans(
                                    color: const Color(0xFFC2410C),
                                    fontSize: 11,
                                    fontWeight: FontWeight.w800,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),

                        // Header Titles
                        Text(
                          _otpSent ? 'Enter Security Code' : 'Welcome Partner 👋',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 26,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textPrimary,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          _otpSent
                              ? 'Enter the 6-digit code sent to your phone'
                              : 'Sign in or register with your mobile number',
                          textAlign: TextAlign.center,
                          style: GoogleFonts.plusJakartaSans(
                            fontSize: 14,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 28),

                        // --- MAIN CARD (LIGHT MODE) ---
                        Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(0xFFE2E8F0),
                              width: 1.2,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.04),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              if (!_otpSent) ...[
                                // Full Name (Optional)
                                Text(
                                  'FULL NAME (OPTIONAL)',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Container(
                                  height: 52,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFE2E8F0)),
                                  ),
                                  child: TextFormField(
                                    controller: _nameController,
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textPrimary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your full name',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textMuted,
                                        fontSize: 14,
                                      ),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                      prefixIcon: const Icon(
                                        Icons.person_outline_rounded,
                                        color: AppColors.textSecondary,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 18),

                                // Phone Input
                                Text(
                                  'MOBILE NUMBER',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    // Country Code
                                    Container(
                                      width: 72,
                                      height: 52,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF8FAFC),
                                        borderRadius: BorderRadius.circular(14),
                                        border: Border.all(color: const Color(0xFFE2E8F0)),
                                      ),
                                      child: TextFormField(
                                        controller: _countryCodeController,
                                        textAlign: TextAlign.center,
                                        style: GoogleFonts.plusJakartaSans(
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.textPrimary,
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    // Phone Number
                                    Expanded(
                                      child: Container(
                                        height: 52,
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8FAFC),
                                          borderRadius: BorderRadius.circular(14),
                                          border: Border.all(color: const Color(0xFFE2E8F0)),
                                        ),
                                        child: TextFormField(
                                          controller: _phoneController,
                                          keyboardType: TextInputType.phone,
                                          inputFormatters: [
                                            FilteringTextInputFormatter.digitsOnly,
                                            LengthLimitingTextInputFormatter(10),
                                          ],
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textPrimary,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w700,
                                            letterSpacing: 1.2,
                                          ),
                                          decoration: InputDecoration(
                                            hintText: 'Enter 10-digit mobile',
                                            hintStyle: GoogleFonts.plusJakartaSans(
                                              color: AppColors.textMuted,
                                              fontSize: 15,
                                              letterSpacing: 1.0,
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                                            prefixIcon: const Icon(
                                              Icons.phone_iphone_rounded,
                                              color: AppColors.textSecondary,
                                              size: 20,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 22),

                                // Action: Send OTP
                                _buildPrimaryButton(
                                  label: 'Send Verification Code',
                                  icon: Icons.arrow_forward_rounded,
                                  onPressed: _isLoading ? null : () => _verifyPhone(),
                                ),
                                _buildDirectEnterButton(),
                              ] else ...[
                                // OTP Mode: Current Number
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFFFF7ED),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: const Color(0xFFFFEDD5)),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.verified_user_rounded,
                                            color: primaryColor,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _normalizedPhoneNumber,
                                            style: GoogleFonts.plusJakartaSans(
                                              color: AppColors.textPrimary,
                                              fontSize: 14,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ],
                                      ),
                                      InkWell(
                                        onTap: _isLoading
                                            ? null
                                            : () {
                                                setState(() {
                                                  _otpSent = false;
                                                  _otpController.clear();
                                                  _countdownTimer?.cancel();
                                                });
                                              },
                                        borderRadius: BorderRadius.circular(8),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          child: Text(
                                            'Edit',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: primaryColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 20),

                                Text(
                                  'ENTER 6-DIGIT CODE',
                                  style: GoogleFonts.plusJakartaSans(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.textSecondary,
                                    letterSpacing: 0.8,
                                  ),
                                ),
                                const SizedBox(height: 8),

                                // Styled OTP Box
                                Container(
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(
                                      color: primaryColor.withValues(alpha: 0.6),
                                      width: 1.5,
                                    ),
                                  ),
                                  alignment: Alignment.center,
                                  child: TextFormField(
                                    controller: _otpController,
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.center,
                                    maxLength: 6,
                                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                                    style: GoogleFonts.plusJakartaSans(
                                      color: AppColors.textPrimary,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 14,
                                    ),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      hintText: '••••••',
                                      hintStyle: GoogleFonts.plusJakartaSans(
                                        color: AppColors.textMuted,
                                        fontSize: 22,
                                        letterSpacing: 14,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),

                                // Verify Action
                                _buildPrimaryButton(
                                  label: 'Verify & Start Delivering',
                                  icon: Icons.check_circle_rounded,
                                  onPressed: _isLoading ? null : _verifyOTP,
                                ),
                                _buildDirectEnterButton(),
                                const SizedBox(height: 14),

                                // Resend Timer / Button
                                Center(
                                  child: _timerSeconds > 0
                                      ? Text(
                                          'Resend OTP in ${_timerSeconds}s',
                                          style: GoogleFonts.plusJakartaSans(
                                            color: AppColors.textSecondary,
                                            fontSize: 13,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      : TextButton.icon(
                                          onPressed: _isLoading ? null : () => _verifyPhone(isResend: true),
                                          icon: const Icon(Icons.refresh_rounded, size: 16, color: primaryColor),
                                          label: Text(
                                            'Resend OTP Code',
                                            style: GoogleFonts.plusJakartaSans(
                                              color: primaryColor,
                                              fontSize: 13,
                                              fontWeight: FontWeight.w700,
                                            ),
                                          ),
                                        ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Learn How It Works Link
                        Center(
                          child: TextButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (c) => const WelcomeOnboardingScreen()),
                              );
                            },
                            icon: const Icon(Icons.info_outline_rounded, size: 16, color: AppColors.textSecondary),
                            label: Text(
                              'How Cloth Delivery Works (3 Slides)',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textSecondary,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Security Footer
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.lock_outline_rounded,
                              size: 13,
                              color: AppColors.textMuted,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Firebase OTP Authentication • Supabase Cloud Store',
                              style: GoogleFonts.plusJakartaSans(
                                color: AppColors.textMuted,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

          // Floating Top-Right Debug Enter Chip
          Positioned(
            top: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.only(top: 8.0, right: 16.0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _handleDirectDebugEnter,
                    borderRadius: BorderRadius.circular(20),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFFFDE68A),
                          width: 1.2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.04),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.bolt_rounded,
                            color: Color(0xFFD97706),
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'DIRECT ENTER',
                            style: GoogleFonts.plusJakartaSans(
                              color: const Color(0xFF92400E),
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
  }) {
    final isEnabled = onPressed != null;

    return Container(
      height: 52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFFF97316), Color(0xFFEA580C)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: isEnabled ? null : const Color(0xFFE2E8F0),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFFF97316).withValues(alpha: 0.28),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? onPressed : null,
          borderRadius: BorderRadius.circular(14),
          child: Center(
            child: _isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        style: GoogleFonts.plusJakartaSans(
                          color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        icon,
                        color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
                        size: 18,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDirectEnterButton() {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: const Color(0xFFE2E8F0),
          width: 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: _handleDirectDebugEnter,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: const BoxDecoration(
                    color: Color(0xFFFEF3C7),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.bolt_rounded,
                    color: Color(0xFFD97706),
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Direct Enter Portal',
                            style: GoogleFonts.plusJakartaSans(
                              color: AppColors.textPrimary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: const Color(0xFFDCFCE7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'FAST PASS',
                              style: GoogleFonts.plusJakartaSans(
                                color: const Color(0xFF15803D),
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Instant entry to Dashboard with preconfigured profile',
                        style: GoogleFonts.plusJakartaSans(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: AppColors.textMuted,
                  size: 12,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
