import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:quote_vault/core/constants/app_colors.dart';
import 'package:quote_vault/core/constants/app_strings.dart';
import 'package:quote_vault/core/theme/app_theme.dart';
import '../cubit/settings_cubit.dart';
import '../cubit/settings_state.dart';
import 'package:quote_vault/core/di/injection_container.dart';
import 'package:quote_vault/core/services/notification_service.dart';
import 'package:quote_vault/core/utils/snackbar_utils.dart';
import 'package:quote_vault/features/settings/presentation/widgets/settings_tile.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late final NotificationService _notificationService;
  TimeOfDay? _time;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _notificationService = InjectionContainer().notificationService;
    _init();
  }

  Future<void> _init() async {
    try {
      final t = await _notificationService.getDailyNotificationTime();
      if (!mounted) return;
      setState(() {
        _time = t;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
      SnackbarUtils.showError(context, AppStrings.somethingWentWrong);
    }
  }

  String _formatTime(BuildContext context, TimeOfDay time) {
    return MaterialLocalizations.of(context).formatTimeOfDay(time);
  }

  Future<void> _pickTime() async {
    if (!mounted) return;

    final initial = _time ?? const TimeOfDay(hour: 8, minute: 0);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (picked == null) return;

    await _notificationService.setDailyNotificationTime(picked);
    final granted = await _notificationService.requestPermissionOnFirstLaunch();
    if (!granted) {
      if (!mounted) return;
      SnackbarUtils.showError(
        context,
        AppStrings.notificationsPermissionDenied,
      );
      setState(() => _time = picked);
      return;
    }

    final scheduledCount = await _notificationService
        .rescheduleDailyQuoteNotifications(time: picked);
    if (!mounted) return;
    setState(() => _time = picked);
    if (scheduledCount > 0) {
      SnackbarUtils.showSuccess(context, AppStrings.notificationTimeSaved);
    } else {
      SnackbarUtils.showError(context, AppStrings.notificationScheduleFailed);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final subtitle = _loading
        ? AppStrings.loading
        : _time == null
        ? AppStrings.dailyQuoteReminderSubtitle
        : '${AppStrings.notificationTime}: ${_formatTime(context, _time!)}';

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
                                accentKey: AppStrings.accentKeyTeal,
                                selected:
                                    state.accentColor ==
                                    AppStrings.accentKeyTeal,
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .changeAccentColor(
                                      AppStrings.accentKeyTeal,
                                    ),
                              ),
                              const SizedBox(width: 16),
                              _AccentDot(
                                accentKey: AppStrings.accentKeyRed,
                                selected:
                                    state.accentColor ==
                                    AppStrings.accentKeyRed,
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .changeAccentColor(AppStrings.accentKeyRed),
                              ),
                              const SizedBox(width: 16),
                              _AccentDot(
                                accentKey: AppStrings.accentKeyIndigo,
                                selected:
                                    state.accentColor ==
                                    AppStrings.accentKeyIndigo,
                                onTap: () => context
                                    .read<SettingsCubit>()
                                    .changeAccentColor(
                                      AppStrings.accentKeyIndigo,
                                    ),
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
              SettingsTile(
                icon: Icons.notifications_active_outlined,
                title: AppStrings.dailyQuoteReminder,
                subtitle: subtitle,
                onTap: _pickTime,
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
            color: AppColors.shadowBlack.withValues(alpha: 0.05),
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
