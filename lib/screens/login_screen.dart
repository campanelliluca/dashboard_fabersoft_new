import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:dashboard_fabersoft_new/providers/auth_provider.dart';

/*
 * LoginScreen: La pagina di accesso dell'applicazione.
 * Gestisce l'inserimento delle credenziali e mostra eventuali errori.
*/
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller per leggere il testo inserito nei campi
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Stato per mostrare un caricamento durante la chiamata al server
  bool _isLoading = false;

  /*
   * Funzione attivata dal pulsante "Accedi".
   * Comunica con il Provider per tentare l'autenticazione.
  */
  void _submitLogin() async {
    setState(() => _isLoading = true);

    // Chiamiamo il metodo login del Provider
    final success = await Provider.of<AuthProvider>(
      context,
      listen: false,
    ).login(_emailController.text, _passwordController.text);

    if (mounted) {
      setState(() => _isLoading = false);

      if (!success) {
        // Se il login fallisce, mostriamo un messaggio di errore (NIS2: feedback generico)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Credenziali non valide. Riprova.'),
            backgroundColor: Colors.redAccent,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(40.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /* Integrazione Logo SVG Ufficiale */
              SvgPicture.asset(
                'assets/images/logo_fabersoft.svg',
                height: 120,
                placeholderBuilder: (BuildContext context) =>
                    const CircularProgressIndicator(),
              ),
              const SizedBox(height: 48),

              Text(
                'FaberSoft Dashboard',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
              const SizedBox(height: 8),
              const Text('Accedi per gestire i tuoi account'),
              const SizedBox(height: 48),

              // Campo Email
              TextField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email o Username',
                  prefixIcon: Icon(Icons.person_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),

              // Campo Password
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Password',
                  prefixIcon: Icon(Icons.lock_outline),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 40),

              // Pulsante Accedi
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submitLogin,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF005CAA),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text(
                          'ACCEDI',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
