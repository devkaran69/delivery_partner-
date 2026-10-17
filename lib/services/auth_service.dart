import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sp;
import '../models/partner_profile.dart';

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final sp.SupabaseClient _supabase = sp.Supabase.instance.client;

  // Firebase current user
  User? get currentFirebaseUser => _firebaseAuth.currentUser;
  String? get currentUserPhone => _firebaseAuth.currentUser?.phoneNumber;

  // Firebase Auth State stream
  Stream<User?> get onAuthStateChange => _firebaseAuth.authStateChanges();
  Stream<User?> get onFirebaseAuthStateChange => _firebaseAuth.authStateChanges();

  // ==========================================
  // FIREBASE: PHONE OTP AUTHENTICATION
  // ==========================================

  /// Sends verification OTP code via Firebase Phone Auth
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String verificationId, int? resendToken) codeSent,
    required Function(String verificationId) codeAutoRetrievalTimeout,
    int? forceResendingToken,
  }) async {
    await _firebaseAuth.verifyPhoneNumber(
      phoneNumber: phoneNumber,
      verificationCompleted: verificationCompleted,
      verificationFailed: verificationFailed,
      codeSent: codeSent,
      codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
      forceResendingToken: forceResendingToken,
    );
  }

  /// Verifies OTP code and signs in with Firebase
  Future<UserCredential> verifyOTPAndSignIn({
    required String verificationId,
    required String smsCode,
    String? displayName,
  }) async {
    PhoneAuthCredential credential = PhoneAuthProvider.credential(
      verificationId: verificationId,
      smsCode: smsCode,
    );
    final userCredential = await _firebaseAuth.signInWithCredential(credential);

    if (userCredential.user != null) {
      if (displayName != null && displayName.trim().isNotEmpty) {
        try {
          await userCredential.user!.updateDisplayName(displayName.trim());
        } catch (_) {}
      }

      // Automatically sync/store partner entry in Supabase upon successful phone login
      final phone = userCredential.user!.phoneNumber ?? '';
      if (phone.isNotEmpty) {
        await upsertPartnerBasicInfoInSupabase(
          phone: phone,
          firebaseUid: userCredential.user!.uid,
          name: displayName ?? userCredential.user!.displayName ?? 'Delivery Partner',
        );
      }
    }

    return userCredential;
  }

  /// Sign in with PhoneAuthCredential
  Future<UserCredential> signInWithPhoneAuthCredential(
    PhoneAuthCredential credential, {
    String? displayName,
  }) async {
    final userCredential = await _firebaseAuth.signInWithCredential(credential);
    if (userCredential.user != null && userCredential.user!.phoneNumber != null) {
      await upsertPartnerBasicInfoInSupabase(
        phone: userCredential.user!.phoneNumber!,
        firebaseUid: userCredential.user!.uid,
        name: displayName ?? userCredential.user!.displayName ?? 'Delivery Partner',
      );
    }
    return userCredential;
  }

  /// Sign Out of both Firebase and Supabase
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      debugPrint('Firebase sign out error: $e');
    }
    try {
      await _supabase.auth.signOut();
    } catch (_) {}
  }

  // ==========================================
  // SUPABASE: DATA STORAGE & PARTNER RECORDS
  // ==========================================

  /// Upsert basic partner record in Supabase upon login
  Future<void> upsertPartnerBasicInfoInSupabase({
    required String phone,
    required String firebaseUid,
    required String name,
  }) async {
    try {
      await _supabase.from('delivery_partners').upsert({
        'phone': phone,
        'firebase_uid': firebaseUid,
        'name': name,
        'last_login_at': DateTime.now().toIso8601String(),
      }, onConflict: 'phone');
      debugPrint('✅ Partner record stored in Supabase for: $phone');
    } catch (e) {
      // Graceful fallback if table not yet created
      debugPrint('ℹ️ Supabase partner upsert note: $e');
    }
  }

  /// Save full partner profile in Supabase
  Future<bool> savePartnerProfileToSupabase(PartnerProfile profile) async {
    try {
      await _supabase
          .from('delivery_partners')
          .upsert(profile.toMap(), onConflict: 'phone');
      debugPrint('✅ Full partner profile saved to Supabase: ${profile.phone}');
      return true;
    } catch (e) {
      debugPrint('ℹ️ Supabase save profile note: $e');
      return false;
    }
  }

  /// Fetch partner profile from Supabase
  Future<PartnerProfile?> fetchPartnerProfileFromSupabase(String phone) async {
    try {
      final data = await _supabase
          .from('delivery_partners')
          .select()
          .eq('phone', phone)
          .maybeSingle();

      if (data != null) {
        return PartnerProfile.fromMap(data, fallbackPhone: phone);
      }
    } catch (e) {
      debugPrint('ℹ️ Supabase fetch partner note: $e');
    }
    return null;
  }

  /// Update Duty status in Supabase
  Future<void> updateDutyStatusInSupabase({
    required String phone,
    required bool isOnline,
  }) async {
    try {
      await _supabase.from('delivery_partners').update({
        'is_online': isOnline,
        'last_duty_toggle': DateTime.now().toIso8601String(),
      }).eq('phone', phone);
    } catch (e) {
      debugPrint('ℹ️ Supabase duty update note: $e');
    }
  }
}
