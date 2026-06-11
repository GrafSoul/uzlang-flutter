import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

/// Локальные уведомления: ежедневное напоминание об учёбе.
///
/// Включается тумблером «Напоминания» в профиле. Время фиксированное —
/// [reminderHour]:00 (вечер: успеть продлить серию до конца дня).
/// Все нативные вызовы обёрнуты: сбой уведомлений не роняет приложение.
class NotificationService {
  /// Создаёт сервис.
  NotificationService();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// Час ежедневного напоминания (локальное время устройства).
  static const int reminderHour = 19;

  static const int _reminderId = 1;

  bool _ready = false;

  /// Инициализация плагина и базы часовых поясов.
  Future<void> init() async {
    try {
      tz_data.initializeTimeZones();
      try {
        final name = await FlutterTimezone.getLocalTimezone();
        tz.setLocalLocation(tz.getLocation(name));
      } catch (_) {
        // Не определили пояс — остаёмся на дефолтном (UTC): напоминание
        // просто сдвинется, это не критично.
      }
      const settings = InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      );
      await _plugin.initialize(settings);
      _ready = true;
    } catch (_) {
      _ready = false;
    }
  }

  /// Запрашивает разрешение на уведомления (Android 13+ / iOS).
  Future<bool> requestPermission() async {
    if (!_ready) return false;
    try {
      final android = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android != null) {
        return await android.requestNotificationsPermission() ?? false;
      }
      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      if (ios != null) {
        return await ios.requestPermissions(alert: true, badge: true) ?? false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Планирует ежедневное напоминание в [reminderHour]:00.
  Future<void> scheduleDailyReminder() async {
    if (!_ready) return;
    try {
      await _plugin.zonedSchedule(
        _reminderId,
        'Vaqt keldi! Время узбекского 🇺🇿',
        'Пара карточек — и серия не сгорит 🔥',
        _nextInstanceOf(reminderHour),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_reminder',
            'Напоминания об учёбе',
            channelDescription: 'Ежедневное напоминание заниматься',
            importance: Importance.defaultImportance,
            priority: Priority.defaultPriority,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        matchDateTimeComponents: DateTimeComponents.time, // ежедневно
      );
    } catch (_) {
      // Планирование не удалось (нет разрешения и т.п.) — молча пропускаем.
    }
  }

  /// Отменяет напоминание.
  Future<void> cancelReminder() async {
    if (!_ready) return;
    try {
      await _plugin.cancel(_reminderId);
    } catch (_) {
      // Нечего отменять — не критично.
    }
  }

  /// Ближайший момент «сегодня или завтра в [hour]:00» в локальном поясе.
  tz.TZDateTime _nextInstanceOf(int hour) {
    final now = tz.TZDateTime.now(tz.local);
    var when = tz.TZDateTime(tz.local, now.year, now.month, now.day, hour);
    if (!when.isAfter(now)) {
      when = when.add(const Duration(days: 1));
    }
    return when;
  }
}
