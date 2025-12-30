import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

import 'core/constants/app_constants.dart';
import 'core/services/network/api_client.dart';
import 'core/services/storage/shared_prefs.dart';
import 'features/auth/bloc/auth_bloc.dart';
import 'features/auth/bloc/auth_event.dart';
import 'features/auth/data/datasource/local/auth_local_datasource.dart';
import 'features/auth/data/datasource/remote/auth_remote_datasource.dart';
import 'features/auth/data/repository/auth_repository_impl.dart';
import 'init_app.dart';
import 'features/theme/app_theme/app_theme.dart';
import 'features/theme/bloc/theme_bloc.dart';
import 'features/theme/bloc/theme_event.dart';
import 'features/theme/bloc/theme_state.dart';
import 'features/translations/app_localizations.dart';
import 'features/translations/bloc/language_bloc.dart';
import 'features/translations/bloc/language_event.dart';
import 'features/translations/bloc/language_state.dart';
import 'routes/route_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize SharedPrefs
  await SharedPrefs.init();

  await initApp();
  runApp(const MyApp());
}

final GlobalKey<ScaffoldMessengerState> rootScaffoldMessengerKey =
GlobalKey<ScaffoldMessengerState>();

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        // ✅ API Client
        RepositoryProvider(create: (context) => ApiClient()),

        // ✅ Auth Data Sources (No SharedPreferences dependency)
        RepositoryProvider(
          create: (context) => AuthLocalDataSourceImpl(),
        ),
        RepositoryProvider(
          create: (context) => AuthRemoteDataSourceImpl(
            apiClient: context.read<ApiClient>(),
          ),
        ),

        // ✅ Auth Repository
        RepositoryProvider(
          create: (context) => AuthRepositoryImpl(
            remoteDataSource: context.read<AuthRemoteDataSourceImpl>(),
            localDataSource: context.read<AuthLocalDataSourceImpl>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc()..add(LoadThemesEvent()),
          ),
          BlocProvider(
            create: (context) => LanguageBloc()..add(LoadLanguagesEvent()),
          ),

          // ✅ Auth Bloc - Check auth status on app start
          BlocProvider(
            create: (context) => AuthBloc(
              authRepository: context.read<AuthRepositoryImpl>(),
            )..add(CheckAuthStatusEvent()),
          ),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, languageState) {
                final currentTheme = themeState.currentTheme;

                return ResponsiveSizer(
                  builder: (context, orientation, screenType) {
                    return MaterialApp(
                      scaffoldMessengerKey: rootScaffoldMessengerKey,
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,

                      // Dynamic Theme Implementation
                      theme: currentTheme != null
                          ? AppTheme.getLightTheme(currentTheme)
                          : ThemeData.light(),
                      darkTheme: currentTheme != null
                          ? AppTheme.getDarkTheme(currentTheme)
                          : ThemeData.dark(),
                      themeMode: AppTheme.getThemeMode(themeState.brightnessMode),

                      // Localization
                      locale: languageState.locale,
                      supportedLocales: languageState.languages.isNotEmpty
                          ? languageState.languages
                          .map((e) => Locale(e.languageCode, e.countryCode))
                          .toList()
                          : const [Locale('en', 'US')],

                      localizationsDelegates: const [
                        AppLocalizationsDelegate(),
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],

                      onGenerateRoute: RouteHelper.generateRoute,
                      initialRoute: RouteHelper.getSplashRoute(),
                      builder: (context, child) {
                        final locale = languageState.locale;
                        final isRTL = const ['ar', 'ur', 'fa', 'he']
                            .contains(locale.languageCode);

                        return MediaQuery(
                          data: MediaQuery.of(context)
                              .copyWith(textScaleFactor: 1.0),
                          child: Directionality(
                            textDirection:
                            isRTL ? TextDirection.rtl : TextDirection.ltr,
                            child: child!,
                          ),
                        );
                      },
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}