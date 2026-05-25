import 'package:flutter/material.dart';
import 'custom_toast.dart';

/// Unified in-app "push notification" + toast API for the terminal.
class DexNotification {
  DexNotification._();

  static void toast(
    BuildContext context,
    String message, {
    ToastType type = ToastType.info,
  }) {
    DexToast.show(context, message, type: type);
  }

  static void push(
    BuildContext context, {
    required String title,
    required String body,
    IconData? icon,
    Color? accentColor,
    Duration autoDismiss = const Duration(seconds: 5),
    VoidCallback? onTap,
  }) {
    DexToast.showPushNotification(
      context,
      title: title,
      body: body,
      icon: icon,
      accentColor: accentColor,
      duration: autoDismiss,
      onTap: onTap,
    );
  }

  static void tradeExecuted(BuildContext context, String pair) {
    push(
      context,
      title: 'Order Queued',
      body: '$pair submitted for desk approval.',
      icon: Icons.bolt_rounded,
    );
  }

  static void mirrorSynced(BuildContext context, String trader) {
    push(
      context,
      title: 'Mirror Active',
      body: 'Capital allocated to $trader.',
      icon: Icons.hub_rounded,
    );
  }
}
