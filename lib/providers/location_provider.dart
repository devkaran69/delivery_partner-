import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationProvider with ChangeNotifier {
  double _currentLatitude = 28.6250;
  double _currentLongitude = 77.2150;
  bool _hasPermission = false;
  bool _isLocating = false;

  LocationProvider() {
    _initLocation();
  }

  double get currentLatitude => _currentLatitude;
  double get currentLongitude => _currentLongitude;
  bool get hasPermission => _hasPermission;
  bool get isLocating => _isLocating;

  Future<void> _initLocation() async {
    try {
      _isLocating = true;
      notifyListeners();

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.always || permission == LocationPermission.whileInUse) {
        _hasPermission = true;
        final position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.high,
            timeLimit: Duration(seconds: 5),
          ),
        );
        _currentLatitude = position.latitude;
        _currentLongitude = position.longitude;
      }
    } catch (_) {
      // Fallback coordinates preserved for realistic demo
    } finally {
      _isLocating = false;
      notifyListeners();
    }
  }

  // Calculate distance in km
  double calculateDistance(double targetLat, double targetLng) {
    try {
      final meters = Geolocator.distanceBetween(
        _currentLatitude,
        _currentLongitude,
        targetLat,
        targetLng,
      );
      return double.parse((meters / 1000).toStringAsFixed(1));
    } catch (_) {
      return 2.5;
    }
  }

  // Launch External Google Maps Navigation
  Future<bool> launchNavigation(double destLat, double destLng, {String? label}) async {
    final googleMapsUrl = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=$destLat,$destLng&travelmode=two-wheeler',
    );

    try {
      if (await canLaunchUrl(googleMapsUrl)) {
        await launchUrl(googleMapsUrl, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Launch Phone Call
  Future<bool> makePhoneCall(String phoneNumber) async {
    final telUri = Uri.parse('tel:$phoneNumber');
    try {
      if (await canLaunchUrl(telUri)) {
        await launchUrl(telUri);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // Launch WhatsApp Chat
  Future<bool> openWhatsApp(String phoneNumber, {String? text}) async {
    final cleanPhone = phoneNumber.replaceAll(RegExp(r'[^\d]'), '');
    final msg = Uri.encodeComponent(text ?? 'Hello, I am your Cloth Delivery Partner.');
    final url = Uri.parse('https://wa.me/$cleanPhone?text=$msg');
    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
        return true;
      }
    } catch (_) {}
    return false;
  }
}
