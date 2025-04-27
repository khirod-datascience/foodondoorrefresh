import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../utils/auth_storage.dart';

class AuthProvider extends ChangeNotifier {
  final Dio _dio = Dio();

  String? _customerId;
  String? get customerId => _customerId;
  String? _token;
  String? get token => _token;
  bool _isAuthenticated = false;
  bool get isAuthenticated => _isAuthenticated;
  Map<String, dynamic>? _currentAddress;
  Map<String, dynamic>? get currentAddress => _currentAddress;

  AuthProvider() {
    _loadAuthState();
  }

  Future<void> _loadAuthState() async {
    _token = await AuthStorage.getToken();
    _customerId = await AuthStorage.getCustomerId();
    debugPrint('[AuthProvider] Loaded token: [32m$_token[0m, customerId: [32m$_customerId[0m');
    _isAuthenticated = _token != null && _customerId != null;
    notifyListeners();
  }

  Future<bool> sendOtp(String phoneNumber) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/send-otp/',
        data: {'phone': phoneNumber},
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  Future<Map<String, String?>?> verifyOtp(String phoneNumber, String otp) async {
    try {
      final response = await _dio.post(
        '${AppConfig.baseUrl}/verify-otp/',
        data: {'phone': phoneNumber, 'otp': otp},
      );
      if (response.statusCode != 200) return null;
      final data = response.data as Map<String, dynamic>;
      final customerId = data['customer_id']?.toString();
      String? token;
      for (final key in ['auth_token', 'token', 'access_token', 'jwt', 'authentication_token', 'id_token']) {
        if (data.containsKey(key) && data[key] != null) {
          token = data[key].toString();
          break;
        }
      }
      debugPrint('[AuthProvider] verifyOtp received token: [32m$token[0m, customerId: [32m$customerId[0m');
      if (token != null && customerId != null) {
        await AuthStorage.saveToken(token);
        await AuthStorage.saveCustomerId(customerId);
        _token = token;
        _customerId = customerId;
        _isAuthenticated = true;
        notifyListeners();
        return {'customer_id': customerId, 'auth_token': token};
      }
      return null;
    } catch (e) {
      debugPrint('[AuthProvider] verifyOtp error: $e');
      return null;
    }
  }

  void setCurrentAddress(Map<String, dynamic> address) {
    _currentAddress = address;
    notifyListeners();
  }

  Future<void> logout() async {
    await AuthStorage.deleteToken();
    await AuthStorage.deleteCustomerId();
    _token = null;
    _customerId = null;
    _isAuthenticated = false;
    notifyListeners();
  }

  Future<void> requestOtpAndLoginIfNeeded(BuildContext context) async {
    if (_token != null && _customerId != null) {
      debugPrint('[AuthProvider] Token and customerId already present, skipping OTP request.');
      return;
    }
    // Prompt user for phone number if not present
    String? phone = await _promptPhoneNumber(context);
    if (phone == null || phone.isEmpty) {
      debugPrint('[AuthProvider] Phone number not provided, cannot request OTP.');
      return;
    }
    // Send OTP
    final apiService = ApiService();
    final otpResponse = await apiService.sendOtp(phone);
    if (otpResponse['success'] == true || otpResponse.containsKey('debug_otp')) {
      debugPrint('[AuthProvider] OTP sent successfully for $phone');
      // Prompt for OTP
      String? otp = await _promptOtp(context);
      if (otp == null || otp.isEmpty) {
        debugPrint('[AuthProvider] OTP not entered, aborting login.');
        return;
      }
      // Verify OTP
      final verifyResponse = await apiService.verifyOtp(phone, otp);
      if (verifyResponse['success'] == true && verifyResponse.containsKey('auth_token')) {
        await AuthStorage.saveToken(verifyResponse['auth_token']);
        await AuthStorage.saveCustomerId(verifyResponse['customer_id']);
        _token = verifyResponse['auth_token'];
        _customerId = verifyResponse['customer_id'];
        _isAuthenticated = true;
        notifyListeners();
        debugPrint('[AuthProvider] OTP verified and token saved.');
      } else {
        debugPrint('[AuthProvider] OTP verification failed: [31m${verifyResponse['error']}[0m');
      }
    } else {
      debugPrint('[AuthProvider] Failed to send OTP: [31m${otpResponse['error']}[0m');
    }
  }

  Future<String?> _promptPhoneNumber(BuildContext context) async {
    String? phone;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter Phone Number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Phone Number'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                phone = controller.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return phone;
  }

  Future<String?> _promptOtp(BuildContext context) async {
    String? otp;
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: const Text('Enter OTP'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(hintText: 'OTP'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                otp = controller.text.trim();
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
    return otp;
  }
}