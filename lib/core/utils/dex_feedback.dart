import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/providers.dart';
import '../../widgets/dex_notification.dart';

/// Haptics + optional DB notification + in-app push toast.
class DexFeedback {
  static Future<void> haptic(WidgetRef ref, {bool light = true}) async {
    final prefs = ref.read(userPreferencesProvider(ref.read(authProvider).email ?? ''));
    final enabled = prefs.valueOrNull?.hapticsEnabled ?? true;
    if (!enabled) return;
    if (light) {
      await HapticFeedback.selectionClick();
    } else {
      await HapticFeedback.mediumImpact();
    }
  }

  static Future<void> notify(
    WidgetRef ref,
    BuildContext context, {
    required String title,
    required String body,
    String kind = 'info',
    bool showPush = true,
  }) async {
    final email = ref.read(authProvider).email;
    if (email != null) {
      await ref.read(microFeaturesRepoProvider).pushNotification(
            title: title,
            body: body,
            kind: kind,
          );
      ref.invalidate(appNotificationsProvider(email));
    }
    if (showPush && context.mounted) {
      DexNotification.push(
        context,
        title: title,
        body: body,
        icon: Icons.bolt_rounded,
      );
    }
  }
}
