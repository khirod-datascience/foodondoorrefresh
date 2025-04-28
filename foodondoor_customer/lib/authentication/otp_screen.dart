import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import '../global/global.dart';
import '../mainScreens/home_screen.dart';
import '../providers/auth_provider.dart';
import '../services/api_service.dart';
import '../widgets/loading_dialog.dart';
import 'register.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({super.key, required this.phoneNumber});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController otpController = TextEditingController();
  bool _isLoading = false;
  final ApiService _apiService = ApiService();
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void dispose() {
    _resendTimer?.cancel();
    otpController.dispose();
    super.dispose();
  }

  void _startResendTimer() {
    setState(() {
      _resendSeconds = 60;
    });
    _resendTimer?.cancel();
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_resendSeconds > 0) {
        setState(() {
          _resendSeconds--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  Future<void> _resendOtp() async {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => LoadingDialog(message: "Resending OTP..."));
    setState(() { _isLoading = true; });
    try {
      final response = await _apiService.sendOtp(widget.phoneNumber);
      Navigator.pop(context);
      if (response['success'] == true || response.containsKey('debug_otp')) {
        Fluttertoast.showToast(msg: "OTP resent successfully.");
        _startResendTimer();
      } else {
        Fluttertoast.showToast(msg: "Error: ${response['error'] ?? 'Failed to resend OTP'}");
      }
    } catch (e) {
      Navigator.pop(context);
      Fluttertoast.showToast(msg: "Error: ${e.toString()}");
    } finally {
      setState(() { _isLoading = false; });
    }
  }

  Future<void> _verifyOtp() async {
    if (_formKey.currentState!.validate()) {
      setState(() { _isLoading = true; });
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (c) => LoadingDialog(message: "Verifying OTP..."));

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final result = await authProvider.verifyOtp(
            widget.phoneNumber, otpController.text.trim());

        Navigator.pop(context);

        if (result != null) {
          if (result['success'] == 'true') {
            if (result['is_signup'] == 'true') {
              Fluttertoast.showToast(msg: "OTP Verified. Please complete signup.");
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (c) => RegisterScreen(phone: widget.phoneNumber)),
              );
            } else {
              Fluttertoast.showToast(msg: "Login Successful.");
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (c) => const HomeScreen()),
                (route) => false,
              );
            }
          } else {
            setState(() { _isLoading = false; });
            Fluttertoast.showToast(msg: "Error: ${result['error'] ?? 'Invalid OTP or verification failed'}");
          }
        } else {
          setState(() { _isLoading = false; });
          Fluttertoast.showToast(msg: "Verification failed: No response from server.");
        }
      } catch (e) {
        Navigator.pop(context);
        setState(() { _isLoading = false; });
        Fluttertoast.showToast(msg: "Verification Error: ${e.toString()}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: Text("Verify OTP", style: Theme.of(context).appBarTheme.titleTextStyle), centerTitle: true, elevation: 0),
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Enter OTP sent to ${widget.phoneNumber}",
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(color: theme.textTheme.bodyMedium?.color),
                ),
                const SizedBox(height: 30),
                TextFormField(
                  controller: otpController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(fontSize: 24, letterSpacing: 10),
                  decoration: const InputDecoration(
                    hintText: "------",
                    counterText: "",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter the OTP';
                    }
                    if (value.length != 6) {
                      return 'OTP must be 6 digits';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _isLoading ? null : _verifyOtp,
                  child: _isLoading
                      ? const SizedBox(child: CircularProgressIndicator(color: Colors.white), height: 24, width: 24)
                      : const Text("Verify OTP"),
                ),
                const SizedBox(height: 20),
                TextButton(
                  onPressed: (_resendSeconds > 0 || _isLoading) ? null : _resendOtp,
                  style: TextButton.styleFrom(
                    foregroundColor: theme.primaryColor,
                  ),
                  child: Text(_resendSeconds > 0 ? "Resend OTP ($_resendSeconds s)" : "Resend OTP?"),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
