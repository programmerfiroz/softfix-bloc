import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'package:responsive_sizer/responsive_sizer.dart';
import 'core/services/network/api_client.dart';
import 'core/services/translations/app_localizations.dart';

import 'core/services/translations/bloc/language_bloc.dart';
import 'core/services/translations/bloc/language_event.dart';
import 'core/services/translations/bloc/language_state.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/bloc/theme_bloc.dart';
import 'core/theme/bloc/theme_event.dart';
import 'core/theme/bloc/theme_state.dart';
import 'core/utils/constants/app_constants.dart';
import 'data/repository/user_repository.dart';
import 'init_app.dart';
import 'presentation/blocs/user/user_bloc.dart';
import 'presentation/blocs/favorite/favorite_bloc.dart';
import 'routes/route_helper.dart';

void main() async {
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
        RepositoryProvider(create: (context) => ApiClient()),
        RepositoryProvider(
          create: (context) => UserRepository(apiClient: context.read<ApiClient>()),
        ),
        RepositoryProvider(
          create: (context) =>
              UserService(context.read<UserRepository>()),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => ThemeBloc()..add(LoadThemeEvent()),
          ),
          BlocProvider(
            create: (context) => LanguageBloc()..add(LoadLanguagesEvent()),
          ),

          BlocProvider(
            create: (context) =>
                UserBloc(userService: context.read<UserService>()),
          ),
          BlocProvider(create: (context) => FavoriteBloc()),
        ],
        child: BlocBuilder<ThemeBloc, ThemeState>(
          builder: (context, themeState) {
            return BlocBuilder<LanguageBloc, LanguageState>(
              builder: (context, languageState) {
                return ResponsiveSizer(
                  builder: (context, orientation, screenType) {
                    return MaterialApp(
                      scaffoldMessengerKey: rootScaffoldMessengerKey,
                      title: AppConstants.appName,
                      debugShowCheckedModeBanner: false,
                      theme: AppTheme.getLightTheme(themeState.theme),
                      darkTheme: AppTheme.getDarkTheme(themeState.theme),
                      themeMode: AppTheme.getThemeMode(themeState.theme),

                      // Localization
                      locale: languageState.locale,
                      supportedLocales: languageState.languages
                          .map((e) => Locale(e.languageCode, e.countryCode))
                          .toList(),
                      localizationsDelegates:  [
                        AppLocalizationsDelegate(),
                        GlobalMaterialLocalizations.delegate,
                        GlobalWidgetsLocalizations.delegate,
                        GlobalCupertinoLocalizations.delegate,
                      ],

                      onGenerateRoute: RouteHelper.generateRoute,
                      initialRoute: RouteHelper.getSplashRoute(),
                      builder: (context, child) {
                        return MediaQuery(
                          data: MediaQuery.of(context).copyWith(textScaleFactor: 1.0),
                          child: child!,
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