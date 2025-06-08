// lib/providers/theme_provider.dart
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  // Theme modes: system (auto), light, dark
  ThemeMode _themeMode = ThemeMode.system;
  bool _isLoading = true;

  ThemeMode get themeMode => _themeMode;
  bool get isLoading => _isLoading;
  
  // Check if current effective theme is dark
  bool get isDarkMode {
    if (_themeMode == ThemeMode.system) {
      // Follow device setting
      return SchedulerBinding.instance.platformDispatcher.platformBrightness == Brightness.dark;
    }
    return _themeMode == ThemeMode.dark;
  }

  // Get current theme mode as text
  String get currentThemeName {
    switch (_themeMode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System (${isDarkMode ? 'Dark' : 'Light'})';
    }
  }

  ThemeProvider() {
    _loadThemeFromPrefs();
  }

  // Load saved theme preference
  Future<void> _loadThemeFromPrefs() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedTheme = prefs.getString('theme_mode') ?? 'system';
      
      switch (savedTheme) {
        case 'light':
          _themeMode = ThemeMode.light;
          break;
        case 'dark':
          _themeMode = ThemeMode.dark;
          break;
        default:
          _themeMode = ThemeMode.system; // Default: follow device
      }
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      print('Error loading theme: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save theme preference
  Future<void> _saveThemeToPrefs(String theme) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('theme_mode', theme);
    } catch (e) {
      print('Error saving theme: $e');
    }
  }

  // Set theme mode
  Future<void> setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    
    String themeString;
    switch (mode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      default:
        themeString = 'system';
    }
    
    await _saveThemeToPrefs(themeString);
  }

  // Cycle through theme modes: system → light → dark → system
  Future<void> cycleTheme() async {
    switch (_themeMode) {
      case ThemeMode.system:
        await setThemeMode(ThemeMode.light);
        break;
      case ThemeMode.light:
        await setThemeMode(ThemeMode.dark);
        break;
      case ThemeMode.dark:
        await setThemeMode(ThemeMode.system);
        break;
    }
  }

  // Light theme with accessible colors
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // Primary colors
    primarySwatch: Colors.brown,
    primaryColor: const Color(0xFF8B4513), // Saddle Brown
    
    // Accessible color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF8B4513),
      brightness: Brightness.light,
      // Ensure good contrast ratios
      primary: const Color(0xFF8B4513),
      onPrimary: Colors.white,
      secondary: const Color(0xFFD2691E), // Chocolate
      onSecondary: Colors.white,
      surface: Colors.white,
      onSurface: const Color(0xFF1C1B1F),
      background: const Color(0xFFFFFBFE),
      onBackground: const Color(0xFF1C1B1F),
    ),
    
    scaffoldBackgroundColor: const Color(0xFFFFFBFE),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Color(0xFF1C1B1F),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFF1C1B1F)),
      titleTextStyle: TextStyle(
        color: Color(0xFF1C1B1F),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ),
    ),
    
    cardTheme: CardTheme(
      color: Colors.white,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: Colors.black.withOpacity(0.1),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: Color(0xFF8B4513),
      unselectedItemColor: Color(0xFF79747E),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF8B4513),
        foregroundColor: Colors.white,
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFF1C1B1F)),
      bodyMedium: TextStyle(color: Color(0xFF1C1B1F)),
      titleLarge: TextStyle(color: Color(0xFF1C1B1F)),
    ),
  );

  // Dark theme with accessible colors
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    
    // Primary colors for dark mode
    primarySwatch: Colors.brown,
    primaryColor: const Color(0xFFD2691E), // Chocolate (lighter for dark mode)
    
    // Accessible dark color scheme
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFD2691E),
      brightness: Brightness.dark,
      // Ensure good contrast ratios for dark mode
      primary: const Color(0xFFD2691E),
      onPrimary: const Color(0xFF1C1B1F),
      secondary: const Color(0xFFCD853F), // Peru
      onSecondary: const Color(0xFF1C1B1F),
      surface: const Color(0xFF1C1B1F),
      onSurface: const Color(0xFFE6E1E5),
      background: const Color(0xFF121212),
      onBackground: const Color(0xFFE6E1E5),
    ),
    
    scaffoldBackgroundColor: const Color(0xFF121212),
    
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF1C1B1F),
      foregroundColor: Color(0xFFE6E1E5),
      elevation: 0,
      iconTheme: IconThemeData(color: Color(0xFFE6E1E5)),
      titleTextStyle: TextStyle(
        color: Color(0xFFE6E1E5),
        fontSize: 24,
        fontWeight: FontWeight.w300,
      ),
    ),
    
    cardTheme: CardTheme(
      color: const Color(0xFF1C1B1F),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      shadowColor: Colors.black.withOpacity(0.3),
    ),
    
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF1C1B1F),
      selectedItemColor: Color(0xFFD2691E),
      unselectedItemColor: Color(0xFF79747E),
      elevation: 8,
      type: BottomNavigationBarType.fixed,
    ),
    
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFD2691E),
        foregroundColor: const Color(0xFF1C1B1F),
        elevation: 2,
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
    ),
    
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: Color(0xFFE6E1E5)),
      bodyMedium: TextStyle(color: Color(0xFFE6E1E5)),
      titleLarge: TextStyle(color: Color(0xFFE6E1E5)),
    ),
  );
}