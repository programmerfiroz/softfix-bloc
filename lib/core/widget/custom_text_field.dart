import 'package:flutter/material.dart';

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType keyboardType;
  final String? Function(String?)? validator;
  final int? maxLength;
  final bool obscureText;
  final Color? borderColor;
  final double borderRadius;
  final TextStyle? textStyle;
  final Function(String)? onChanged;

  const CustomTextField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType = TextInputType.text,
    this.validator,
    this.maxLength,
    this.obscureText = false,
    this.borderColor,
    this.borderRadius = 12.0,
    this.textStyle,
    this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final effectiveBorderColor = borderColor ?? theme.colorScheme.primary;

    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      style: textStyle ?? theme.textTheme.bodyLarge,
      obscureText: obscureText,
      maxLength: maxLength,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: theme.inputDecorationTheme.hintStyle,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        counterText: "",
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: isDark
                ? theme.dividerColor
                : effectiveBorderColor.withOpacity(0.5),
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: effectiveBorderColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: theme.colorScheme.error,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        filled: true,
        fillColor: theme.inputDecorationTheme.fillColor ??
            (isDark ? theme.cardColor : Colors.white),
      ),
      validator: validator,
    );
  }
}