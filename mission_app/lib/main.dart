import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go4me/core/theme/app_theme.dart';
import 'package:go4me/core/routing/app_router.dart';
import 'package:go4me/core/services/supabase_service.dart';
import 'package:go4me/core/services/notification_service.dart';
import 'package:go4me/core/services/social_repository.dart';
import 'package:go4me/core/services/locale_service.dart';
import 'package:go4me/l10n/generated/app_localizations.dart';
import 'package:flutter_stripe/flutter_stripe.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await SupabaseService.initialize();
    await dotenv.load();

    Stripe.publishableKey = dotenv.env['STRIPE_PUBLISHABLE_KEY'] ??
        'pk_test_51BTj65LH5s664654_placeholder';

    if (!kIsWeb) {
      final container = ProviderContainer();
      await container.read(notificationServiceProvider).init();
    }

    final container = ProviderContainer();
    container.read(socialRepositoryProvider).subscribeToNewPosts();
  } catch (e) {
    debugPrint('Erro na inicialização: $e');
  }

  runApp(const ProviderScope(child: Go4MeApp()));
}

class Go4MeApp extends ConsumerWidget {
  const Go4MeApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Go4Me',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.themeData,
      routerConfig: router,
      locale: currentLocale.flutterLocale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
