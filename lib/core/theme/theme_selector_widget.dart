import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/theme_bloc.dart';
import 'bloc/theme_event.dart';
import 'bloc/theme_state.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Theme Settings',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 16),

                // Theme Options
                RadioListTile<AppThemeEnum>(
                  title: const Text('System Default'),
                  subtitle: const Text('Follow system theme'),
                  value: AppThemeEnum.system,
                  groupValue: state.theme,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                    }
                  },
                  secondary: const Icon(Icons.brightness_auto),
                ),
                RadioListTile<AppThemeEnum>(
                  title: const Text('Light'),
                  value: AppThemeEnum.light,
                  groupValue: state.theme,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                    }
                  },
                  secondary: const Icon(Icons.light_mode),
                ),
                RadioListTile<AppThemeEnum>(
                  title: const Text('Dark'),
                  value: AppThemeEnum.dark,
                  groupValue: state.theme,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                    }
                  },
                  secondary: const Icon(Icons.dark_mode),
                ),
                RadioListTile<AppThemeEnum>(
                  title: const Text('Blue Theme'),
                  value: AppThemeEnum.blue,
                  groupValue: state.theme,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                    }
                  },
                  secondary: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
                RadioListTile<AppThemeEnum>(
                  title: const Text('Yellow Theme'),
                  value: AppThemeEnum.yellow,
                  groupValue: state.theme,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<ThemeBloc>().add(ChangeThemeEvent(value));
                    }
                  },
                  secondary: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

// Compact Color Selector (for quick switching between colors only)
class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildColorButton(
              context,
              AppThemeEnum.blue,
              Colors.blue,
              state.theme == AppThemeEnum.blue,
            ),
            const SizedBox(width: 16),
            _buildColorButton(
              context,
              AppThemeEnum.yellow,
              Colors.amber,
              state.theme == AppThemeEnum.yellow,
            ),
          ],
        );
      },
    );
  }

  Widget _buildColorButton(
      BuildContext context,
      AppThemeEnum theme,
      Color displayColor,
      bool isSelected,
      ) {
    return InkWell(
      onTap: () {
        context.read<ThemeBloc>().add(ChangeThemeEvent(theme));
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: displayColor.withOpacity(0.5),
              blurRadius: 8,
              spreadRadius: 2,
            ),
          ]
              : null,
        ),
        child: isSelected ? const Icon(Icons.check, color: Colors.white) : null,
      ),
    );
  }
}

// Brightness Toggle (cycles through system -> light -> dark)
class ThemeBrightnessToggle extends StatelessWidget {
  const ThemeBrightnessToggle({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return IconButton(
          icon: Icon(
            state.theme == AppThemeEnum.dark
                ? Icons.light_mode
                : state.theme == AppThemeEnum.light
                ? Icons.dark_mode
                : Icons.brightness_auto,
          ),
          onPressed: () {
            AppThemeEnum newTheme;
            if (state.theme == AppThemeEnum.system) {
              newTheme = AppThemeEnum.light;
            } else if (state.theme == AppThemeEnum.light) {
              newTheme = AppThemeEnum.dark;
            } else {
              newTheme = AppThemeEnum.system;
            }
            context.read<ThemeBloc>().add(ChangeThemeEvent(newTheme));
          },
        );
      },
    );
  }
}