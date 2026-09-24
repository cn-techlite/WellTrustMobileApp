// Notifier to manage theme state
import 'package:well_trust_mobile_app/core/utils/package_export.dart';

const _modeKey = 'themeMode';
const _textKey = 'textSize';

class ThemeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    return ThemeMode.system; // "Match phone" is the design default
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_modeKey, mode.name);
  }

  // Toggle Theme & Persist to SharedPreferences
  Future<void> toggleTheme() =>
      setMode(state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark);

  // Load Theme from SharedPreferences
  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_modeKey);
    if (saved != null) {
      state = ThemeMode.values.firstWhere(
        (m) => m.name == saved,
        orElse: () => ThemeMode.system,
      );
      return;
    }
    final legacy = prefs.getBool('isDarkMode');
    if (legacy != null) {
      state = legacy ? ThemeMode.dark : ThemeMode.light;
    }
  }
}

// Riverpod Provider for Theme Management
final themeNotifierProvider = NotifierProvider<ThemeNotifier, ThemeMode>(() {
  return ThemeNotifier();
});

/// Text size from the design's Settings: standard, large (112.5%), xl (125%).
enum TextSizeOption {
  standard('Standard', 1.0),
  large('Large', 1.125),
  xl('Extra large', 1.25);

  final String label;
  final double scale;
  const TextSizeOption(this.label, this.scale);
}

class TextSizeNotifier extends Notifier<TextSizeOption> {
  @override
  TextSizeOption build() => TextSizeOption.standard;

  Future<void> set(TextSizeOption o) async {
    state = o;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_textKey, o.name);
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_textKey);
    state = TextSizeOption.values.firstWhere(
      (o) => o.name == saved,
      orElse: () => TextSizeOption.standard,
    );
  }
}

final textSizeProvider = NotifierProvider<TextSizeNotifier, TextSizeOption>(
  TextSizeNotifier.new,
);
