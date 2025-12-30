import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:virtual_office/core/constants/image_constants.dart';
import 'package:virtual_office/core/widget/custom_image_widget.dart';
import '../../core/widget/custom_app_text.dart';
import '../../routes/route_helper.dart';
import '../../features/translations/bloc/language_bloc.dart';
import '../../features/translations/bloc/language_state.dart';
import '../auth/bloc/auth_bloc.dart';
import '../auth/bloc/auth_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _bottomController;

  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _bottomFade;

  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _startAnimations();
    _checkAuthAndNavigate();
  }

  void _initializeAnimations() {
    _logoController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _textController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _bottomController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _logoScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOut),
      ),
    );

    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOut),
    );

    _textSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
    );

    _bottomFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _bottomController, curve: Curves.easeIn),
    );
  }

  void _startAnimations() async {
    await _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 200));
    await _textController.forward();
    await Future.delayed(const Duration(milliseconds: 300));
    await _bottomController.forward();
  }

  void _checkAuthAndNavigate() async {
    print('⏱️ Splash: Waiting for animations...');

    // Wait for animations to complete
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted || _hasNavigated) return;

    // Listen to auth state changes
    final authBloc = context.read<AuthBloc>();

    authBloc.stream.listen((state) {
      if (_hasNavigated || !mounted) return;

      print('🔍 Splash Auth State Changed: $state');

      if (state is Authenticated) {
        _hasNavigated = true;
        print('✅ Navigating to Home');
        Navigator.pushReplacementNamed(context, RouteHelper.getHomeRoute());
      } else if (state is Unauthenticated) {
        _hasNavigated = true;
        print('❌ Navigating to Login');
        Navigator.pushReplacementNamed(context, RouteHelper.getLoginRoute());
      }
    });

    // Also check current state immediately
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted || _hasNavigated) return;

    final currentState = authBloc.state;
    print('🔍 Current Auth State: $currentState');

    if (currentState is Authenticated) {
      _hasNavigated = true;
      print('✅ Navigating to Home (current state)');
      Navigator.pushReplacementNamed(context, RouteHelper.getHomeRoute());
    } else if (currentState is Unauthenticated) {
      _hasNavigated = true;
      print('❌ Navigating to Login (current state)');
      Navigator.pushReplacementNamed(context, RouteHelper.getLoginRoute());
    } else {
      print('⏳ Still loading, waiting for state change...');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _bottomController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return BlocBuilder<LanguageBloc, LanguageState>(
      builder: (context, languageState) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: Stack(
            children: [
              // Subtle gradient overlay
              Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.center,
                    radius: 1.5,
                    colors: [
                      colorScheme.primary.withOpacity(0.03),
                      colorScheme.surface,
                      colorScheme.surface,
                    ],
                    stops: const [0.0, 0.5, 1.0],
                  ),
                ),
              ),

              // Main content - centered logo and name
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated Logo with glow effect
                    AnimatedBuilder(
                      animation: _logoController,
                      builder: (context, child) {
                        return FadeTransition(
                          opacity: _logoFade,
                          child: ScaleTransition(
                            scale: _logoScale,
                            child: Container(
                              width: 110,
                              height: 110,
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.4),
                                    blurRadius: 40,
                                    offset: const Offset(0, 20),
                                    spreadRadius: -8,
                                  ),
                                  BoxShadow(
                                    color: colorScheme.primary.withOpacity(0.2),
                                    blurRadius: 60,
                                    offset: const Offset(0, 30),
                                    spreadRadius: -10,
                                  ),
                                ],
                              ),
                              padding: const EdgeInsets.all(24),
                              child: CustomImageWidget(
                                imagePath: ImageConstants.appIcon,
                                color: colorScheme.onPrimary,
                              ),
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 28),

                    // App Name with slide animation
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: CustomAppText(
                          'Desklyn',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: colorScheme.onSurface,
                            letterSpacing: -1,
                            height: 1.2,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 8),

                    // Tagline
                    SlideTransition(
                      position: _textSlide,
                      child: FadeTransition(
                        opacity: _textFade,
                        child: CustomAppText(
                          'Connect. Collaborate. Create.',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: colorScheme.onSurface.withOpacity(0.6),
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom section with enhanced branding
              Positioned(
                bottom: 60,
                left: 0,
                right: 0,
                child: FadeTransition(
                  opacity: _bottomFade,
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 3,
                        margin: const EdgeInsets.only(bottom: 16),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      CustomAppText(
                        'from',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.4),
                          fontSize: 12,
                          letterSpacing: 0.8,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            width: 20,
                            height: 20,
                            margin: const EdgeInsets.only(right: 8),
                            decoration: BoxDecoration(
                              color: colorScheme.primary,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Icon(
                              Icons.bolt_rounded,
                              size: 14,
                              color: colorScheme.onPrimary,
                            ),
                          ),
                          CustomAppText(
                            'Brainket',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: colorScheme.primary,
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}