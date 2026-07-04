import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'screens/main_navigation_holder.dart';

// Top-level global themeNotifier referenced by screens
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Thai locale formatting for intl package
  await initializeDateFormatting('th_TH', null);
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'กระเป๋าเงินของฉัน',
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC4AB6C), // Premium Gold seed
              primary: const Color(0xFF976623),
              secondary: const Color(0xFFDDC484),
              brightness: Brightness.light,
            ),
            scaffoldBackgroundColor: const Color(0xFFF5EFE6),
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Color(0xFF1E293B)),
            ),
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFFC4AB6C), // Premium Gold seed
              primary: const Color(0xFFDDC484),
              secondary: const Color(0xFFC4AB6C),
              brightness: Brightness.dark,
            ),
            appBarTheme: const AppBarTheme(
              iconTheme: IconThemeData(color: Color(0xFFF1F5F9)),
            ),
          ),
          home: const MainNavigationHolder(),
        );
      },
    );
  }
}
