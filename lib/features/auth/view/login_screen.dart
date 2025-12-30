// lib/features/auth/view/login_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import '../../../core/constants/image_constants.dart';
import '../../../core/utils/app_validators.dart';
import '../../../core/utils/custom_snackbar.dart';
import '../../../core/widget/custom_app_text.dart';
import '../../../core/widget/custom_base_widget.dart';
import '../../../core/widget/custom_button.dart';
import '../../../core/widget/custom_image_widget.dart';
import '../../../core/widget/custom_text_field.dart';
import '../../../routes/route_helper.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_event.dart';
import '../bloc/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _mobileController = TextEditingController();
  final _countryCode = '+91';

  @override
  void dispose() {
    _mobileController.dispose();
    super.dispose();
  }

  void _onSendOtp() {
    if (_formKey.currentState!.validate()) {
      // Combine country code with mobile number
      final phoneNumber = '$_countryCode${_mobileController.text.trim()}';

      context.read<AuthBloc>().add(
        SendOtpEvent(phoneNumber: phoneNumber),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomBaseWidget(
      useSafeArea: true,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is OtpSentSuccess) {
            CustomSnackbar.showSuccess(message: state.message);

            // Show OTP in development mode
            if (state.otp != null) {
              CustomSnackbar.showInfo(message: 'OTP: ${state.otp}');
            }

            Navigator.pushNamed(
              context,
              RouteHelper.getOtpRoute(),
              arguments: {
                'phoneNumber': state.phoneNumber,
              },
            );
          } else if (state is OtpSendError) {
            CustomSnackbar.showError(message: state.message);
          }
        },
        builder: (context, state) {
          final isLoading = state is OtpSending;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 5.w),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 8.h),

                  // Logo
                  Container(
                    width: 25.w,
                    height: 25.w,
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.3),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    padding: EdgeInsets.all(4.w),
                    child: CustomImageWidget(
                      imagePath: ImageConstants.appIcon,
                      color: colorScheme.onPrimary,
                    ),
                  ),

                  SizedBox(height: 4.h),

                  // Title
                  CustomAppText(
                    'Welcome Back',
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: colorScheme.onSurface,
                    ),
                  ),

                  SizedBox(height: 1.h),

                  // Subtitle
                  CustomAppText(
                    'Enter your mobile number to continue',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.6),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  SizedBox(height: 5.h),

                  // Mobile Number Input
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Country Code
                      Container(
                        height: 56,
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: colorScheme.primary.withOpacity(0.5),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: CustomAppText(
                            _countryCode,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: 3.w),

                      // Mobile Number Field
                      Expanded(
                        child: CustomTextField(
                          controller: _mobileController,
                          hintText: 'Enter mobile number',
                          keyboardType: TextInputType.phone,
                          maxLength: 10,
                          validator: AppValidators.validatePhone,
                          prefixIcon: Icon(
                            Icons.phone_android,
                            color: colorScheme.primary,
                          ),
                        ),
                      ),
                    ],
                  ),

                  SizedBox(height: 4.h),

                  // Send OTP Button
                  CustomButton(
                    onPressed: isLoading ? null : _onSendOtp,
                    text: 'Send OTP',
                    isLoading: isLoading,
                    width: double.infinity,
                  ),

                  SizedBox(height: 3.h),

                  // Terms & Privacy
                  CustomAppText(
                    'By continuing, you agree to our Terms of Service and Privacy Policy',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurface.withOpacity(0.5),
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}