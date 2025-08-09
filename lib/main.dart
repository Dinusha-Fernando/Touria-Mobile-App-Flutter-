import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;

import 'package:touria/screen/eventScreen.dart';
import 'package:touria/screen/home_screen.dart';
import 'package:touria/screen/login.dart';
import 'package:touria/screen/profileScreen.dart';
import 'package:touria/screen/search_screen.dart';
import 'package:touria/screen/signup.dart';
import 'package:touria/services/provider/language_provider.dart';
import 'package:touria/services/provider/theme_provider.dart';
import 'package:touria/splash_Screen/splash.dart';
import 'package:touria/widget/screens/home_Screen/bottomNavBar.dart';

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  // Initialize timezone data
  tz.initializeTimeZones();

  // Initialize local notifications
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
  );

  await flutterLocalNotificationsPlugin.initialize(initializationSettings);

  // Run the app with Providers
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        // Add more providers if needed
      ],
      child: const Touria(),
    ),
  );
}

class Touria extends StatelessWidget {
  const Touria({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Touria',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xff0091d5)),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff0091d5),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      themeMode: themeProvider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      initialRoute: '/',
      routes: {
        '/': (context) => const Splash(),
        '/login': (context) => const Login(),
        '/signup': (context) => const SignupScreen(),
        '/main': (context) => const BottomNavBar(),
        '/home': (context) => const HomeScreen(),
        '/search': (context) => SearchScreen(),
        '/event': (context) => const EventScreen(),
        '/profile': (context) => const Profilescreen(),
      },
    );
  }
}
