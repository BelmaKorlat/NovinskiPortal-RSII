import 'package:flutter/material.dart';
import 'package:elegant_notification/elegant_notification.dart';
import 'package:elegant_notification/resources/arrays.dart';

class NotificationService {
  static final navigatorKey = GlobalKey<NavigatorState>();

  static BuildContext _ctx() {
    final ctx = navigatorKey.currentContext;
    if (ctx == null) {
      throw StateError('Navigator context is null');
    }
    return ctx;
  }

  static void success(String title, String message) {
    final ctx = _ctx();
    final isDark = Theme.of(ctx).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : const Color(0xFF222222),
    );
    final descStyle = TextStyle(
      color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF444444),
    );

    ElegantNotification.success(
      title: Text(title, style: titleStyle),
      description: Text(message, style: descStyle),

      position: Alignment.topRight,
      width: 300,
      height: 78,
      notificationMargin: 8,
      background: bg,
      iconSize: 18,
      toastDuration: const Duration(seconds: 5),
      dismissDirection: DismissDirection.horizontal,
    ).show(_ctx());
  }

  static void error(String title, String message) {
    final ctx = _ctx();
    final isDark = Theme.of(ctx).brightness == Brightness.dark;
    final bg = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final titleStyle = TextStyle(
      fontWeight: FontWeight.w600,
      color: isDark ? Colors.white : const Color(0xFF222222),
    );
    final descStyle = TextStyle(
      color: isDark ? const Color(0xFFEDEDED) : const Color(0xFF444444),
    );

    ElegantNotification.error(
      title: Text(title, style: titleStyle),
      description: Text(message, style: descStyle),
      position: Alignment.topRight,
      width: 300,
      height: 78,
      notificationMargin: 8,
      background: bg,
      iconSize: 18,
      toastDuration: const Duration(seconds: 5),
      dismissDirection: DismissDirection.horizontal,
    ).show(_ctx());
  }

  // Info
  static void info(String title, String message, {Duration? duration}) {
    ElegantNotification.info(
      title: Text(title),
      description: Text(message),
      position: Alignment.topRight,
      animation: AnimationType.fromRight,
      dismissDirection: DismissDirection.horizontal,
      toastDuration: duration ?? const Duration(seconds: 3),
    ).show(_ctx());
  }
}
