import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:google_fonts/google_fonts.dart';
import 'core/config/app_env.dart';
import 'data/supabase_client.dart';
import 'core/theme/dex_theme.dart';
import 'core/router/app_router.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (kIsWeb) {
    usePathUrlStrategy();
  }

  await AppEnv.load();

  try {
    await SupabaseConfig.initialize();
    runApp(const ProviderScope(child: DextradeApp()));
  } catch (e, st) {
    if (kIsWeb) {
      runApp(ProviderScope(child: _BootErrorApp(message: e.toString())));
    } else {
      FlutterError.reportError(FlutterErrorDetails(exception: e, stack: st));
      rethrow;
    }
  }
}

/// Shown on web when Supabase env is missing — avoids infinite splash.
class _BootErrorApp extends StatelessWidget {
  final String message;
  const _BootErrorApp({required this.message});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'DEXTRADE',
                  style: GoogleFonts.orbitron(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Terminal failed to boot',
                  style: GoogleFonts.spaceGrotesk(
                    color: Colors.white70,
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  message,
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(color: Colors.white38, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
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
