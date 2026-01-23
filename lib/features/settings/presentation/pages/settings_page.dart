import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.navSettings)),
      body: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
            children: [
              const _SectionLabel(text: AppStrings.appearance),
              const SizedBox(height: 10),
              _Card(
                child: Column(
                  children: [
                    _RowTile(
                      leading: _IconBubble(
                        color: scheme.primary.withValues(alpha: 0.15),
                        child: Icon(
                          Icons.nights_stay_rounded,
                          color: scheme.primary,
                        ),
                      ),
                      title: AppStrings.darkMode,
                      trailing: Switch(
                        value: state.themeMode == ThemeMode.dark,
                        onChanged: (v) {
                          context.read<SettingsCubit>().toggleTheme(
                            v ? ThemeMode.dark : ThemeMode.light,
                          );
                        },
                      ),
                    ),
                    const _Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _IconBubble(
                                color: scheme.primary.withValues(alpha: 0.15),
                                child: Icon(
                                  Icons.palette_rounded,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  AppStrings.accentColor,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              _AccentDot(
                                accentKey: 'teal',
                                selected: state.accentColor == 'teal',
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .changeAccentColor('teal'),
                              ),
                              const SizedBox(width: 16),
                              _AccentDot(
                                accentKey: 'red',
                                selected: state.accentColor == 'red',
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .changeAccentColor('red'),
                              ),
                              const SizedBox(width: 16),
                              _AccentDot(
                                accentKey: 'indigo',
                                selected: state.accentColor == 'indigo',
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .changeAccentColor('indigo'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const _Divider(),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _IconBubble(
                                color: scheme.primary.withValues(alpha: 0.15),
                                child: Icon(
                                  Icons.text_fields_rounded,
                                  color: scheme.primary,
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  AppStrings.fontSize,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Text(
                                'Tt',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              Expanded(
                                child: Slider(
                                  min: 0.8,
                                  max: 1.4,
                                  divisions: 6,
                                  value: state.fontScale,
                                  onChanged: (v) => context
                                      .read<SettingsCubit>()
                                      .changeFontScale(v),
                                ),
                              ),
                              Text(
                                'Tt',
                                style: TextStyle(
                                  fontSize: 18,
                                  color: scheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 22),
              const _SectionLabel(text: AppStrings.dailyReminders),
              const SizedBox(height: 10),
              _Card(
                child: _RowTile(
                  leading: _IconBubble(
                    color: scheme.primary.withValues(alpha: 0.15),
                    child: Icon(
                      Icons.notifications_rounded,
                      color: scheme.primary,
                    ),
                  ),
                  title: AppStrings.notificationTime,
                  trailing: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.primary.withValues(alpha: 0.10),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      AppStrings.defaultNotificationTime,
                      style: TextStyle(
                        color: scheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel({required this.text});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Text(
      text,
      style: TextStyle(
        letterSpacing: 1.2,
        fontWeight: FontWeight.w700,
        fontSize: 13,
        color: scheme.onSurfaceVariant,
      ),
    );
  }
}

class _Card extends StatelessWidget {
  final Widget child;
  const _Card({required this.child});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Theme.of(context).dividerColor.withValues(alpha: 0.25),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: child,
    );
  }
}

class _RowTile extends StatelessWidget {
  final Widget leading;
  final String title;
  final Widget trailing;

  const _RowTile({
    required this.leading,
    required this.title,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          leading,
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: scheme.onSurface,
              ),
            ),
          ),
          trailing,
        ],
      ),
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Divider(
      height: 1,
      thickness: 1,
      color: Theme.of(context).dividerColor.withValues(alpha: 0.18),
    );
  }
}

class _IconBubble extends StatelessWidget {
  final Color color;
  final Widget child;
  const _IconBubble({required this.color, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      child: Center(child: child),
    );
  }
}

class _AccentDot extends StatelessWidget {
  final String accentKey;
  final bool selected;
  final VoidCallback onTap;

  const _AccentDot({
    required this.accentKey,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final dotColor = AppTheme.seedColorFor(accentKey);
    final borderColor = selected
        ? Theme.of(context).colorScheme.primary
        : Theme.of(context).dividerColor.withValues(alpha: 0.35);

    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: borderColor, width: selected ? 2.2 : 1.4),
        ),
        child: Center(
          child: Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle),
          ),
        ),
      ),
    );
  }
}
