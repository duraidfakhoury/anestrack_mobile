import 'package:anestrack_mobile/core/config/app_config.dart';
import 'package:anestrack_mobile/core/constants/api_urls.dart';
import 'package:anestrack_mobile/core/network/app_errors_handler.dart';
import 'package:anestrack_mobile/core/network/network_helper.dart';
import 'package:anestrack_mobile/core/routes/app_routes.dart';
import 'package:anestrack_mobile/core/services/cache_service.dart';
import 'package:anestrack_mobile/core/services/notifications/firebase_messaging_service.dart';
import 'package:anestrack_mobile/core/services/offline_cosign_sync/offline_attestation_sync_service.dart';
import 'package:anestrack_mobile/core/services/offline_cosign_sync/offline_cosigned_procedure_sync_service.dart';
import 'package:anestrack_mobile/core/services/procedure_sync/procedure_sync_service.dart';
import 'package:anestrack_mobile/core/services/service_locator.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:anestrack_mobile/core/themes/app_theme.dart';
import 'package:anestrack_mobile/core/themes/bloc/theme_bloc.dart';
import 'package:anestrack_mobile/core/translations/app_locale.dart';
import 'package:anestrack_mobile/core/utils/app_headers.dart';
import 'package:anestrack_mobile/generated/codegen_loader.g.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:responsive_sizer/responsive_sizer.dart';

Future<void> initVariables() async {
  ServicesLocator().init();
  await AppConfig().initVariables();
  ApisUrls().initBaseUrl(AppConfig().baseUrl);
  await CacheService.init();
  await CacheService().initCacheLanguage();
  await CacheService().initCacheTheme();
  NetworkHelper().init(headers: AppHeaders(), handler: AppErrorsHandler());
  await EasyLocalization.ensureInitialized();
  // Firebase Cloud Messaging (notifications). Reads android/app/google-services.json.
  // firebase_messaging has no Windows/web plugin implementation — both are
  // real `flutter run` targets for local dev on this repo, so skip there.
  if (isPushNotificationSupportedPlatform) {
    await Firebase.initializeApp();
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
    await FirebaseMessagingService.instance.init();
  }
  // Cheap no-op if the offline queue is empty or the user isn't logged in
  // yet (see SyncPendingProceduresUseCase's hasToken gate).
  await sl<ProcedureSyncService>().start();
  // Offline co-sign — both directions started unconditionally; each is a
  // no-op unless the signed-in role actually populated its own queue.
  await sl<OfflineCosignedProcedureSyncService>().start();
  await sl<OfflineAttestationSyncService>().start();
}

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await initVariables();

  runApp(
    EasyLocalization(
      supportedLocales: AppLocale().supportedLocales,
      startLocale: AppLocale().arabic,
      fallbackLocale: AppLocale().arabic,
      path: 'resources/langs',
      assetLoader: const CodegenLoader(),
      child: const MyApp(),
    ),
  );

  FlutterNativeSplash.remove();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // return Sizer Builder (Responsive UI)
    return BlocProvider(
      create: (context) => sl<ThemeBloc>(),
      child: BlocBuilder<ThemeBloc, ThemeState>(
        builder: (context, state) {
          return ResponsiveSizer(
            maxTabletWidth: 1024,
            maxMobileWidth: 600,
            builder: (context, orientation, deviceType) {
              return MaterialApp.router(
                localizationsDelegates: context.localizationDelegates,
                supportedLocales: context.supportedLocales,
                locale: context.locale,
                title: 'AnesTrack',
                theme: AppTheme().lightTheme(context),
                themeMode: state is DarkThemeActionState
                    ? ThemeMode.dark
                    : ThemeMode.light,
                darkTheme: AppTheme().darkTheme(context),
                routerConfig: AppRoutes.router,
                debugShowCheckedModeBanner: false,
              );
            },
          );
        },
      ),
    );
  }
}
