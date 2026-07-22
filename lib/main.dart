import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:audio_session/audio_session.dart'; // New import

import 'package:watersort/data/services/hive_service.dart';
import 'package:watersort/ui/core/theme/app_theme.dart';
import 'package:watersort/ui/providers.dart';
import 'package:watersort/ui/features/home/views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure audio session to mix with other apps and duck volume
  final session = await AudioSession.instance;
  await session.configure(const AudioSessionConfiguration(
    avAudioSessionCategory: AVAudioSessionCategory.playback,
    avAudioSessionCategoryOptions: AVAudioSessionCategoryOptions.mixWithOthers,
    avAudioSessionMode: AVAudioSessionMode.defaultMode,
    avAudioSessionRouteSharingPolicy: AVAudioSessionRouteSharingPolicy.defaultPolicy,
    avAudioSessionSetActiveOptions: AVAudioSessionSetActiveOptions.notifyOthersOnDeactivation,
    androidAudioAttributes: const AndroidAudioAttributes(
      contentType: AndroidAudioContentType.sonification,
      flags: AndroidAudioFlags.none,
      usage: AndroidAudioUsage.game,
    ),
    androidAudioFocusGainType: AndroidAudioFocusGainType.gainTransient,
    androidWillPauseWhenDucked: false,
  ));

  final hiveService = HiveService();
  await hiveService.init();

  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
  ));

  runApp(
    ProviderScope(
      overrides: [
        hiveServiceProvider.overrideWithValue(hiveService),
      ],
      child: const WaterSortApp(),
    ),
  );
}

class WaterSortApp extends StatelessWidget {
  const WaterSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Water Sort',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
      home: const HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
