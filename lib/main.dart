import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add kiya
import 'firebase_options.dart'; // CLI ne ye file banayi hogi
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/book_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/main_wrapper.dart';
import 'screens/user_view_screen.dart';
void main() async {
  // 1. Flutter binding initialize karein
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Firebase Initialize karein (Requirement for Firebase)
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const LibraryApp());
}

class LibraryApp extends StatelessWidget {
  const LibraryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BookProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Library Management',
        
        // Professional Theme
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.indigo,
            primary: const Color(0xFF3F51B5),
            secondary: const Color(0xFF03A9F4),
            surface: const Color(0xFFF8F9FA), 
          ),
          scaffoldBackgroundColor: const Color(0xFFF8F9FA),
          cardTheme: CardThemeData(
            elevation: 0,
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: Colors.grey.shade200),
            ),
          ),
        ),

        // Named Routes Configuration
        initialRoute: '/',
        routes: {
          '/': (context) => const LoginScreen(),
          '/register': (context) => const RegisterScreen(),
          '/home': (context) => const MainWrapper(),
          '/user_view': (context) => const UserViewScreen(),
        },
      ),
    );
  }
}