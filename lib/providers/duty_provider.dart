import 'dart:async';
import 'package:flutter/material.dart';
import '../models/partner_profile.dart';

class DutyProvider with ChangeNotifier {
  bool _isOnline = false;
  Timer? _shiftTimer;
  int _shiftSeconds = 0;
  double _todayEarnings = 0.0;
  int _completedDeliveriesToday = 0;
  final double _acceptanceRate = 100.0;
  final int _batteryLevel = 100;
  final String _gpsSignal = 'High Accuracy';

  PartnerProfile _profile = PartnerProfile.initial('');

  DutyProvider() {
    // Idle until partner toggles online
  }

  // Getters
  bool get isOnline => _isOnline;
  int get shiftSeconds => _shiftSeconds;
  double get todayEarnings => _todayEarnings;
  int get completedDeliveriesToday => _completedDeliveriesToday;
  double get acceptanceRate => _acceptanceRate;
  int get batteryLevel => _batteryLevel;
  String get gpsSignal => _gpsSignal;
  PartnerProfile get profile => _profile;

  String get formattedShiftDuration {
    final hours = _shiftSeconds ~/ 3600;
    final minutes = (_shiftSeconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  // Toggle Online/Offline
  void toggleDuty() {
    _isOnline = !_isOnline;
    if (_isOnline) {
      _startShiftTimer();
    } else {
      _shiftTimer?.cancel();
    }
    notifyListeners();
  }

  void _startShiftTimer() {
    _shiftTimer?.cancel();
    _shiftTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isOnline) {
        _shiftSeconds++;
        notifyListeners();
      }
    });
  }

  // Add Earnings on Delivery Complete
  void creditDeliveryEarning(double amount, {double? codCollected}) {
    _todayEarnings += amount;
    _completedDeliveriesToday++;
    _profile = _profile.copyWith(
      todayEarnings: _todayEarnings,
      walletBalance: _profile.walletBalance + amount,
      totalTrips: _profile.totalTrips + 1,
      cashInHand: codCollected != null ? _profile.cashInHand + codCollected : _profile.cashInHand,
    );
    notifyListeners();
  }

  // Settle COD cash deposited at hub
  void depositCashInHand(double amount) {
    if (amount <= _profile.cashInHand) {
      _profile = _profile.copyWith(
        cashInHand: _profile.cashInHand - amount,
      );
      notifyListeners();
    }
  }

  void updateProfile(PartnerProfile newProfile) {
    _profile = newProfile;
    notifyListeners();
  }

  @override
  void dispose() {
    _shiftTimer?.cancel();
    super.dispose();
  }
}
