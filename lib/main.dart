import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

/* Import assoluti come richiesto dal modus operandi */
import 'package:dashboard_fabersoft_new/providers/auth_provider.dart';
import 'package:dashboard_fabersoft_new/screens/login_screen.dart';
import 'package:dashboard_fabersoft_new/screens/dashboard_screen.dart';

void main() {
  /* Inizializzazione dell'app con il provider di autenticazione */
  runApp(
    ChangeNotifierProvider(
      create: (context) => AuthProvider()..tryAutoLogin(),
      child: const FaberSoftApp(),
    ),
  );
}

class FaberSoftApp extends StatelessWidget {
  const FaberSoftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaberSoft Dashboard',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        /* Impostazione del colore Blu FaberSoft ufficiale */
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF005CAA),
          brightness: Brightness.light,
        ),
        textTheme: GoogleFonts.robotoTextTheme(),
      ),
      /* Visualizzazione dinamica della home in base allo stato di login */
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          if (auth.isAuthenticated) {
            /* Se loggato, mostriamo la vera Dashboard */
            return const DashboardScreen();
          } else {
            return const LoginScreen();
          }
        },
      ),
    );
  }
}
