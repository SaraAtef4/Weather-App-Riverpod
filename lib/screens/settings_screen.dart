import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weather_app_riverpod/providers/theme_provider.dart';
import '../../providers/localization_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingScreen extends ConsumerWidget {
  const SettingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(ThemeNotifierProvider);
    final notifire = ref.read(ThemeNotifierProvider.notifier);
    final isDark = themeMode == ThemeMode.dark;

    final localizations = AppLocalizations.of(context);

    if (localizations == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.secondary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          localizations.settings,
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
          ),
        ),
      ),
      body: Column(
        children: [
          // Theme Setting
          ListTile(
            title: Text(
              localizations.theme,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            leading: GestureDetector(
              onTap: notifire.toggleTheme,
              child: Icon(
                isDark ? Icons.light_mode : Icons.dark_mode,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            subtitle: Text(
              isDark ?  localizations.lightMode:localizations.darkMode,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            trailing: Switch(
              value: isDark,
              onChanged: (_) {
                notifire.toggleTheme();
              },
            ),
          ),

          // Language Setting
          ListTile(
            leading: Icon(
              Icons.language,
              color: Theme.of(context).colorScheme.secondary,
            ),
            title: Text(
              localizations.language,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            trailing: DropdownButton<String>(
              value: ref.watch(LocalizationProvider).languageCode,
              dropdownColor: Theme.of(context).primaryColor,
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
              ),
              items: const [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'ar', child: Text('العربية')),
              ],
              onChanged: (value) {
                if (value != null) {
                  ref.read(LocalizationProvider.notifier).changeLocale(value);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}