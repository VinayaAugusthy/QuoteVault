import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../constants/app_strings.dart';
import '../../features/quotes/domain/entities/quote.dart';
import 'daily_quote_service.dart';

class NotificationService {
  static const String _channelId = 'daily_quote_channel';
  static const String _channelName = 'Daily Quotes';
  static const String _channelDescription = 'Daily Quote of the Day reminders';

  static const int _dailyQuoteNotificationIdBase = 41000;

  static const String _prefsPermissionRequestedKey =
      'notif_permission_requested';
  static const String _prefsTimeHourKey = 'daily_quote_notif_hour';
  static const String _prefsTimeMinuteKey = 'daily_quote_notif_minute';

  final DailyQuoteService dailyQuoteService;
  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  NotificationService({required this.dailyQuoteService});

  Future<void> initialize() async {
    if (_initialized) return;
    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    await _androidPlugin()?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        description: _channelDescription,
        importance: Importance.high,
      ),
    );

    tz.initializeTimeZones();
    tz.setLocalLocation(await _resolveLocalLocation());

    _initialized = true;
  }

  AndroidFlutterLocalNotificationsPlugin? _androidPlugin() => _plugin
      .resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin
      >();

  Future<tz.Location> _resolveLocalLocation() async {
    final timezoneName = await FlutterTimezone.getLocalTimezone();
    try {
      return tz.getLocation(timezoneName);
    } catch (_) {
      if (timezoneName == 'Asia/Calcutta') {
        try {
          return tz.getLocation('Asia/Kolkata');
        } catch (_) {}
      }
      return tz.getLocation('Etc/UTC');
    }
  }

  Future<bool> requestPermissionOnFirstLaunch() async {
    final prefs = await SharedPreferences.getInstance();
    final alreadyRequested =
        prefs.getBool(_prefsPermissionRequestedKey) ?? false;
    if (alreadyRequested) {
      return _hasNotificationPermission();
    }

    await prefs.setBool(_prefsPermissionRequestedKey, true);
    await Permission.notification.request();
    return _hasNotificationPermission();
  }

  Future<bool> _hasNotificationPermission() async =>
      !Platform.isAndroid || (await Permission.notification.status).isGranted;

  Future<TimeOfDay> getDailyNotificationTime() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_prefsTimeHourKey) ?? 8;
    final minute = prefs.getInt(_prefsTimeMinuteKey) ?? 0;
    return TimeOfDay(hour: hour, minute: minute);
  }

  Future<void> setDailyNotificationTime(TimeOfDay time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefsTimeHourKey, time.hour);
    await prefs.setInt(_prefsTimeMinuteKey, time.minute);
  }

  Future<int> rescheduleDailyQuoteNotifications({
    TimeOfDay? time,
    int daysAhead = 30,
  }) async {
    await initialize();
    if (!await _hasNotificationPermission()) return 0;

    final chosenTime = time ?? await getDailyNotificationTime();
    await _cancelDailyQuoteNotifications(daysAhead: daysAhead);

    final quotes = await _tryGetQuotes(daysAhead);
    var count = 0;
    final now = tz.TZDateTime.now(tz.local);
    for (var i = 0; i < daysAhead; i++) {
      final scheduledDate = _scheduledDateForOffset(now, i, chosenTime);
      if (scheduledDate.isBefore(now)) continue;

      final quote = i < quotes.length ? quotes[i] : null;
      final body = quote == null
          ? AppStrings.dailyQuoteNotificationFallbackBody
          : '"${quote.body}" — ${quote.author}';

      final ok = await _schedule(
        id: _dailyQuoteNotificationIdBase + i,
        title: AppStrings.quoteOfTheDay,
        body: body,
        when: scheduledDate,
      );
      if (ok) count++;
    }

    return count;
  }

  Future<List<Quote>> _tryGetQuotes(int daysAhead) async {
    try {
      return await dailyQuoteService.getQuotesForNextDays(days: daysAhead);
    } catch (_) {
      return const <Quote>[];
    }
  }

  NotificationDetails get _details => const NotificationDetails(
    android: AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    ),
  );

  Future<bool> _schedule({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime when,
  }) async {
    try {
      await _plugin.zonedSchedule(
        id,
        title,
        body,
        when,
        _details,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
      return true;
    } on PlatformException catch (e) {
      // Android 12+ may block exact alarms unless the user explicitly allows them.
      if (e.code == 'exact_alarms_not_permitted') {
        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            when,
            _details,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          );
          return true;
        } catch (_) {
          return false;
        }
      }
      // Ignore other scheduling failures to avoid crashing the app.
      return false;
    } catch (_) {
      return false;
    }
  }

  tz.TZDateTime _scheduledDateForOffset(
    tz.TZDateTime now,
    int dayOffset,
    TimeOfDay time,
  ) => tz.TZDateTime(
    tz.local,
    now.year,
    now.month,
    now.day,
    time.hour,
    time.minute,
  ).add(Duration(days: dayOffset));

  Future<void> _cancelDailyQuoteNotifications({required int daysAhead}) async {
    for (var i = 0; i < daysAhead; i++) {
      await _plugin.cancel(_dailyQuoteNotificationIdBase + i);
    }
  }
}
