import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/l10n/app_strings.dart';
import 'core/theme/wild_theme.dart';
import 'features/shell/app_shell.dart';

class WildLogApp extends StatelessWidget {
  const WildLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        title: AppStrings.appTitle,
        debugShowCheckedModeBanner: false,
        theme: WildTheme.dark(),
        home: const AppShell(),
      ),
    );
  }
}
