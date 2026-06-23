import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class LocalNotifier {
  LocalNotifier._();
  static final LocalNotifier instance = LocalNotifier._();
  
  final plugin = FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const settings = InitializationSettings(android: android);
    await plugin.initialize(settings);
    
    final androidPlugin = plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();
  }

  Future<void> show(String title, String body) async {
    const android = AndroidNotificationDetails(
      'aeronet_general',
      'AeroNet',
      channelDescription: 'Notificaciones generales de la app AeroNet',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    
    await plugin.show(
      DateTime.now().millisecondsSinceEpoch ~/ 1000,
      title,
      body,
      const NotificationDetails(android: android),
    );
  }
}
