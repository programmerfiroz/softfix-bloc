import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/widget/custom_app_text.dart';
import '../bloc/theme_bloc.dart';
import '../bloc/theme_event.dart';
import '../bloc/theme_state.dart';

class ThemeSelector extends StatelessWidget {
  const ThemeSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        return DraggableScrollableSheet(
          initialChildSize: 0.5, // Aadhi screen (50%)
          minChildSize: 0.3, // Minimum 30%
          maxChildSize: 0.9, // Maximum 90%
          builder: (context, scrollController) {
            if (state.isLoading) {
              return Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).cardColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                ),
                child: const Center(child: CircularProgressIndicator()),
              );
            }

            return Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Drag Handle
                  Container(
                    margin: const EdgeInsets.only(top: 12, bottom: 8),
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade400,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Scrollable Content
                  Expanded(
                    child: ListView(
                      controller: scrollController,
                      padding: const EdgeInsets.all(16.0),
                      children: [
                        CustomAppText(
                          'Theme Settings',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 16),

                        // Brightness Options
                        CustomAppText(
                          'Brightness',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        RadioListTile<ThemeBrightnessMode>(
                          title: const CustomAppText('System Default'),
                          subtitle: const CustomAppText('Follow system theme'),
                          value: ThemeBrightnessMode.system,
                          groupValue: state.brightnessMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeBloc>().add(ChangeBrightnessModeEvent(value));
                            }
                          },
                          secondary: const Icon(Icons.brightness_auto),
                        ),
                        RadioListTile<ThemeBrightnessMode>(
                          title: const CustomAppText('Light'),
                          value: ThemeBrightnessMode.light,
                          groupValue: state.brightnessMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeBloc>().add(ChangeBrightnessModeEvent(value));
                            }
                          },
                          secondary: const Icon(Icons.light_mode),
                        ),
                        RadioListTile<ThemeBrightnessMode>(
                          title: const CustomAppText('Dark'),
                          value: ThemeBrightnessMode.dark,
                          groupValue: state.brightnessMode,
                          onChanged: (value) {
                            if (value != null) {
                              context.read<ThemeBloc>().add(ChangeBrightnessModeEvent(value));
                            }
                          },
                          secondary: const Icon(Icons.dark_mode),
                        ),

                        const Divider(height: 32),

                        // Color Themes
                        CustomAppText(
                          'Color Theme',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        ...state.availableThemes.map((theme) {
                          return RadioListTile<int>(
                            title: CustomAppText('${theme.name}'),
                            value: theme.id,
                            groupValue: state.selectedThemeId,
                            onChanged: (value) {
                              if (value != null) {
                                context.read<ThemeBloc>().add(ChangeThemeColorEvent(value));
                              }
                            },
                            secondary: Container(
                              width: 24,
                              height: 24,
                              decoration: BoxDecoration(
                                color: theme.primaryColor,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.grey.shade300),
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }
}

// Compact Color Selector (for quick switching)
class ThemeColorSelector extends StatelessWidget {
  const ThemeColorSelector({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeBloc, ThemeState>(
      builder: (context, state) {
        if (state.isLoading || state.availableThemes.isEmpty) {
          return const SizedBox.shrink();
        }

        return Wrap(
          spacing: 16,
          runSpacing: 16,
          alignment: WrapAlignment.center,
          children: state.availableThemes.map((theme) {
            final isSelected = state.selectedThemeId == theme.id;
            return _buildColorButton(
              context,
              theme.id,
              theme.primaryColor,
              isSelected,
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildColorButton(
      BuildContext context,
      int themeId,
      Color displayColor,
      bool isSelected,
      ) {
    return InkWell(
      onTap: () {
        context.read<ThemeBloc>().add(ChangeThemeColorEvent(themeId));
      },
      child: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          color: displayColor,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.white, width: 3)
              : Border.all(color: Colors.grey.shade300, width: 1),
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
            state.brightnessMode == ThemeBrightnessMode.dark
                ? Icons.light_mode
                : state.brightnessMode == ThemeBrightnessMode.light
                ? Icons.dark_mode
                : Icons.brightness_auto,
          ),
          onPressed: () {
            ThemeBrightnessMode newMode;
            if (state.brightnessMode == ThemeBrightnessMode.system) {
              newMode = ThemeBrightnessMode.light;
            } else if (state.brightnessMode == ThemeBrightnessMode.light) {
              newMode = ThemeBrightnessMode.dark;
            } else {
              newMode = ThemeBrightnessMode.system;
            }
            context.read<ThemeBloc>().add(ChangeBrightnessModeEvent(newMode));
          },
        );
      },
    );
  }
}