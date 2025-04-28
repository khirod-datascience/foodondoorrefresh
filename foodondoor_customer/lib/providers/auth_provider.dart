import 'package:flutter/material.dart';
import 'dart:async';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config.dart';
import '../utils/auth_storage.dart';
import '../services/api_service.dart';

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

  final Completer<void> _initCompleter = Completer<void>();
  Future<void> get initializationComplete => _initCompleter.future;
  bool _isInitialized = false;

  AuthProvider() {
    _initialize();
  }

  Future<void> _initialize() async {
    if (_isInitialized) return;
    try {
      await _loadAuthState();
      _isInitialized = true;
      _initCompleter.complete();
    } catch (e) {
      debugPrint('[AuthProvider] Initialization failed: $e');
      _initCompleter.completeError(e);
    }
  }

  Future<void> _loadAuthState() async {
    _token = await AuthStorage.getToken();
    _customerId = await AuthStorage.getCustomerId();
    debugPrint('[AuthProvider] Loaded token:  [32m$_token [0m, customerId:  [32m$_customerId [0m');
    _isAuthenticated = _token != null && _customerId != null;
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
        '${AppConfig.baseUrl}/verify-otp/', // Ensure this endpoint is correct
        data: {'phone': phoneNumber, 'otp': otp},
      );

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
          final data = response.data as Map<String, dynamic>;
          debugPrint('[AuthProvider] Raw verifyOtp response data: $data'); // Log the raw data

          // Attempt to extract customer ID (now checking nested user object)
          String? customerId;
          if (data['user'] is Map<String, dynamic>) {
            customerId = (data['user'] as Map<String, dynamic>)['user_id']?.toString();
          }
          // Fallback to top-level keys if nested structure not found (optional, adjust as needed)
          customerId ??= data['user_id']?.toString() ?? data['customer_id']?.toString();

          // Attempt to extract token (checking multiple common keys)
          String? token;
          for (final key in ['auth_token', 'token', 'access_token', 'jwt', 'authentication_token', 'id_token']) {
            if (data.containsKey(key) && data[key] != null) {
              token = data[key].toString();
              break;
            }
          }

          // Check if signup is required (handle potential null or non-boolean value)
          String isSignup = (data['is_signup'] == true || data['is_signup'] == 'true') ? 'true' : 'false';

          debugPrint('[AuthProvider] verifyOtp received token: $token, customerId: $customerId, isSignup: $isSignup');

          if (token != null && customerId != null) {
             // If signup is required, don't update auth state yet, just signal success and signup needed
             if (isSignup == 'true') {
                return {'success': 'true', 'is_signup': 'true'};
             }
             // Otherwise, it's a successful login
             else {
                await AuthStorage.saveToken(token);
                await AuthStorage.saveCustomerId(customerId);
                _token = token;
                _customerId = customerId;
                _isAuthenticated = true;
                notifyListeners();
                // Return success, not signup
                return {'success': 'true', 'is_signup': 'false'};
             }
          } else {
             // Missing token or customer ID
             debugPrint('[AuthProvider] verifyOtp failed: Missing token or customer ID.');
             return {'success': 'false', 'error': 'Login failed: Missing token or customer ID.'};
          }
      } else {
         // Handle non-200 status code or unexpected response format
         debugPrint('[AuthProvider] verifyOtp failed: Status code ${response.statusCode}, Response: ${response.data}');
         return {'success': 'false', 'error': 'Verification failed: Server error (${response.statusCode})'};
      }
    } catch (e) {
      debugPrint('[AuthProvider] verifyOtp exception: $e');
      // Return error on exception
      return {'success': 'false', 'error': 'An error occurred: ${e.toString()}'};
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
    _isInitialized = false;
    notifyListeners();
  }

  Future<void> requestOtpAndLoginIfNeeded(BuildContext context) async {
    if (_token != null && _customerId != null) {
      debugPrint('[AuthProvider] Token and customerId already present, skipping OTP request.');
      return;
    }
    String? phone = await _promptPhoneNumber(context);
    if (phone == null || phone.isEmpty) {
      debugPrint('[AuthProvider] Phone number not provided, cannot request OTP.');
      return;
    }
    final apiService = ApiService();
    final otpResponse = await apiService.sendOtp(phone);
    if (otpResponse['success'] == true || otpResponse.containsKey('debug_otp')) {
      debugPrint('[AuthProvider] OTP sent successfully for $phone');
      String? otp = await _promptOtp(context);
      if (otp == null || otp.isEmpty) {
        debugPrint('[AuthProvider] OTP not entered, aborting login.');
        return;
      }
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
        debugPrint('[AuthProvider] OTP verification failed:  [31m${verifyResponse['error']} [0m');
      }
    } else {
      debugPrint('[AuthProvider] Failed to send OTP:  [31m${otpResponse['error']} [0m');
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