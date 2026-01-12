import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(const FaberSoftApp());
}

class FaberSoftApp extends StatelessWidget {
  const FaberSoftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FaberSoft Dashboard',
      debugShowCheckedModeBanner: false, // Rimuove il banner "Debug"

      theme: ThemeData(
        useMaterial3: true,
        // Generiamo tutti i colori partendo dal Blu FaberSoft
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF007BFF),
          brightness: Brightness.light,
        ),
        // Applichiamo Roboto (standard Material) tramite Google Fonts
        textTheme: GoogleFonts.robotoTextTheme(),

        // Configurazione AppBar per evitare "linee" o ombre indesiderate
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          scrolledUnderElevation: 0, // Evita che cambi colore scrollando
        ),
      ),

      home: const TestPage(),
    );
  }
}

class TestPage extends StatelessWidget {
  const TestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('FaberSoft Dashboard'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.lock_person_outlined,
              size: 80,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'Ambiente Configurato',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            const Text('Pronti per il collegamento API'),
          ],
        ),
      ),
    );
  }
}
