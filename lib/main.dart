import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'data/supabase_client.dart';
import 'core/theme/dex_theme.dart';
import 'core/router/app_router.dart';

import 'dart:js' as js;
import 'package:flutter/foundation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  await SupabaseConfig.initialize();
  runApp(const ProviderScope(child: DextradeApp()));

  if (kIsWeb) {
    try {
      js.context.callMethod('eval', ["document.getElementById('loading-indicator')?.remove()"]);
    } catch (e) {
      // Avoid crash on non-js environments if any
    }
  }
}

class DextradeApp extends ConsumerWidget {
  const DextradeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'Dextrade',
      debugShowCheckedModeBanner: false,
      theme: DexTheme.dark,
      routerConfig: router,
    );
  }
}
