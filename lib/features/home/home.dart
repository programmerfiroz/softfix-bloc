import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/widget/custom_base_widget.dart';
import '../../core/widget/custom_app_text.dart';
import '../../core/widget/custom_button.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_event.dart';
import '../../routes/route_helper.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return CustomBaseWidget(
      useSafeArea: true,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 100,
                color: colorScheme.primary,
              ),
              const SizedBox(height: 20),
              CustomAppText(
                'Welcome to Home!',
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              CustomAppText(
                'You are successfully logged in',
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 40),
              CustomButton(
                text: 'Logout',
                onPressed: () {
                  context.read<AuthBloc>().add(LogoutEvent());
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    RouteHelper.getLoginRoute(),
                        (route) => false,
                  );
                },
                width: double.infinity,
              ),
            ],
          ),
        ),
      ),
    );
  }
}