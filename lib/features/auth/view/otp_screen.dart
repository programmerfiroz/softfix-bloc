// lib/features/auth/view/otp_screen.dart

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widget/custom_app_text.dart';
import '../../../core/widget/custom_base_widget.dart';
import '../../../core/widget/custom_button.dart';
import '../../../core/widget/custom_otp_field.dart';
import '../../../routes/route_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class OtpScreen extends StatefulWidget {
  final String phoneNumber;

  const OtpScreen({
    Key? key,
    required this.phoneNumber,
  }) : super(key: key);

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final _otpController = TextEditingController();
  Timer? _timer;
  int _remainingSeconds = 60;
  bool _canResend = false;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _otpController.dispose();
    super.dispose();
  }

  void _startTimer() {
    _remainingSeconds = 60;
    _canResend = false;

    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        setState(() => _canResend = true);
        timer.cancel();
      }
    });
  }

  void _onVerifyOtp() {
    if (_otpController.text.length == 4) {
      context.read<AuthBloc>().add(
        VerifyOtpEvent(
          phoneNumber: widget.phoneNumber,
          otp: _otpController.text.trim(),
        ),
      );
    } else {
      CustomSnackbar.showError(message: 'Please enter valid 4-digit OTP');
    }
  }

  void _onResendOtp() {
    if (_canResend) {
      context.read<AuthBloc>().add(
        ResendOtpEvent(phoneNumber: widget.phoneNumber),
      );
      _startTimer();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomBaseWidget(
      useSafeArea: true,
      showAppBar: true,
      showLeadingAction: true,
      appBarTitle: 'Verify OTP',
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpVerifiedSuccess) {
            print('✅ OTP Verified - isNewUser: ${state.isNewUser}');
            print('✅ User data: ${state.user?.toJson()}');

            // ✅ Check if user is new (needs profile setup)
            if (state.isNewUser == true) {
              print('🔄 Navigating to Profile Setup...');
              CustomSnackbar.showSuccess(message: 'OTP verified! Complete your profile');

              // Navigate to profile setup
              Navigator.pushReplacementNamed(
                context,
                RouteHelper.getProfileSetupRoute(),
              );
            } else {
              print('🔄 Navigating to Home...');
              CustomSnackbar.showSuccess(message: 'Welcome back!');

              // Navigate to home (existing user)
              Navigator.pushNamedAndRemoveUntil(
                context,
                RouteHelper.getHomeRoute(),
                    (route) => false,
              );
            }
          } else if (state is OtpVerifyError) {
            CustomSnackbar.showError(message: state.message);
          } else if (state is OtpSentSuccess) {
            CustomSnackbar.showSuccess(message: 'OTP resent successfully');
            // Show OTP in development mode
            if (state.otp != null) {
              CustomSnackbar.showInfo(message: 'OTP: ${state.otp}');
            }
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpVerifying;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 4.h),

                // OTP Icon
                Container(
                  width: 20.w,
                  height: 20.w,
                  decoration: BoxDecoration(
                    color: colorScheme.primary.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.message_outlined,
                    size: 10.w,
                    color: colorScheme.primary,
                  ),
                ),

                SizedBox(height: 3.h),

                // Title
                CustomAppText(
                  'Enter Verification Code',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.onSurface,
                  ),
                ),

                SizedBox(height: 1.h),

                // Subtitle with phone number
                CustomAppText(
                  'We have sent a 4-digit code to',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface.withOpacity(0.6),
                  ),
                ),

                SizedBox(height: 0.5.h),

                CustomAppText(
                  widget.phoneNumber,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),

                SizedBox(height: 5.h),

                // OTP Input
                CustomOtpField(
                  controller: _otpController,
                  length: 4,
                  onCompleted: (otp) => _onVerifyOtp(),
                ),

                SizedBox(height: 4.h),

                // Verify Button
                CustomButton(
                  onPressed: isLoading ? null : _onVerifyOtp,
                  text: 'Verify OTP',
                  isLoading: isLoading,
                  width: double.infinity,
                ),

                SizedBox(height: 3.h),

                // Resend OTP Section
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomAppText(
                      "Didn't receive code? ",
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurface.withOpacity(0.6),
                      ),
                    ),
                    if (!_canResend)
                      CustomAppText(
                        'Resend in $_remainingSeconds s',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      )
                    else
                      GestureDetector(
                        onTap: _onResendOtp,
                        child: CustomAppText(
                          'Resend',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}