import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  static const _channelId = 'bac_pro_reminders';
  static const _channelName = 'Bac Pro Notificări';
  static const _channelDescription = 'Mementouri de studiu și progres';

  static const int _dailyReminderId = 4001;
  static const int _streakReminderId = 4002;
  static const int _examReminderId = 4003;
  static const int _gradeUpdateId = 4004;
  static const String _examAlertStoragePrefix = 'exam_alert_sent_v1';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  String? _lastSettingsFingerprint;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );

    await _plugin.initialize(settings: settings);
    _initialized = true;
  }

  Future<void> requestPermissions() async {
    if (!_initialized) await init();

    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.requestNotificationsPermission();

    final ios = _plugin
        .resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin
        >();
    await ios?.requestPermissions(alert: true, badge: true, sound: true);

    final macos = _plugin
        .resolvePlatformSpecificImplementation<
          MacOSFlutterLocalNotificationsPlugin
        >();
    await macos?.requestPermissions(alert: true, badge: true, sound: true);
  }

  Future<void> syncFromSettings({
    required bool dailyReminder,
    required bool streakReminder,
    required bool examAlerts,
    required DateTime examDate,
  }) async {
    if (!_initialized) await init();

    final fingerprint =
        '$dailyReminder|$streakReminder|$examAlerts|'
        '${_dateOnly(examDate).toIso8601String()}';
    if (_lastSettingsFingerprint == fingerprint) return;
    _lastSettingsFingerprint = fingerprint;

    if (dailyReminder || streakReminder || examAlerts) {
      await requestPermissions();
    }

    if (dailyReminder) {
      await _plugin.periodicallyShow(
        id: _dailyReminderId,
        title: 'Bac Pro',
        body:
            'Reamintire zilnică: deschide planul de azi și bifează task-urile.',
        repeatInterval: RepeatInterval.daily,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _plugin.cancel(id: _dailyReminderId);
    }

    if (streakReminder) {
      await _plugin.periodicallyShow(
        id: _streakReminderId,
        title: 'Streak zilnic',
        body: 'Nu-ți rupe streak-ul. Rezolvă măcar un task azi.',
        repeatInterval: RepeatInterval.daily,
        notificationDetails: _notificationDetails,
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    } else {
      await _plugin.cancel(id: _streakReminderId);
    }

    if (examAlerts) {
      await _maybeSendExamAlert(examDate);
    } else {
      await _plugin.cancel(id: _examReminderId);
    }
  }

  Future<void> showGradeUpdate(double grade) async {
    if (!_initialized) await init();
    await _plugin.show(
      id: _gradeUpdateId,
      title: 'Notă actualizată',
      body: 'Ai finalizat un subiect cu nota ${grade.toStringAsFixed(1)}.',
      notificationDetails: _notificationDetails,
    );
  }

  NotificationDetails get _notificationDetails {
    const android = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const darwin = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );
    return const NotificationDetails(
      android: android,
      iOS: darwin,
      macOS: darwin,
    );
  }

  Future<void> _maybeSendExamAlert(DateTime examDate) async {
    final now = _dateOnly(DateTime.now());
    final exam = _dateOnly(examDate);
    final daysLeft = exam.difference(now).inDays;
    if (daysLeft != 7 && daysLeft != 1) return;

    final prefs = await SharedPreferences.getInstance();
    final key = '$_examAlertStoragePrefix:${exam.toIso8601String()}:$daysLeft';
    if (prefs.getBool(key) == true) return;

    final body = daysLeft == 7
        ? 'Au rămas 7 zile până la Bac. Intră azi pe recapitulare.'
        : 'Mâine este Bacul. Recapitulare ușoară și odihnă.';

    await _plugin.show(
      id: _examReminderId,
      title: 'Alertă Bac',
      body: body,
      notificationDetails: _notificationDetails,
    );
    await prefs.setBool(key, true);
  }

  static DateTime _dateOnly(DateTime value) {
    return DateTime(value.year, value.month, value.day);
  }
}
