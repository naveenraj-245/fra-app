import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'firebase_options.dart';
import 'language_provider.dart';
import 'features/auth/role_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(
    
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
      ],
      child: const SatyaShieldApp(),
    ),
  );
}

class SatyaShieldApp extends StatelessWidget {
  const SatyaShieldApp({super.key});

  @override
  Widget build(BuildContext context) {
    
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      title: 'Satya-Shield',
      debugShowCheckedModeBanner: false,
      
      theme: ThemeData(
        primarySwatch: Colors.green,
        useMaterial3: true,
        scaffoldBackgroundColor: const Color(0xFFF9FAFB), // light gray-50
      ),

      locale: languageProvider.currentLocale,
      supportedLocales: const [
        Locale('en'), 
        Locale('ta'), 
        Locale('hi'), 
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],

      // Entry point: The "Who are you?" screen
      home: const RoleSelectionScreen(),
    );
  }
}
