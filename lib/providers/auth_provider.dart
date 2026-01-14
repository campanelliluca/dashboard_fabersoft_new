import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/* Import assoluti come richiesto dal modus operandi */
import 'package:dashboard_fabersoft_new/core/api_constants.dart';

/* * Provider per la gestione dell'autenticazione.
 * Si interfaccia con api_v1.php per validare le credenziali tramite htpasswd.db.
 */
class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isAuthenticated = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;

  /* * Metodo per effettuare il login.
   * Invia 'user' e 'pass' all'endpoint api_v1.php.
   * Gestisce la risposta JSON verificando lo stato di successo e il token JWT.
   */
  Future<bool> login(String username, String password) async {
    try {
      /* Chiamata POST verso l'API Gateway FaberSoft */
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        body: {
          'user': username, // Parametro user richiesto da api_v1.php
          'pass': password, // Parametro pass richiesto da api_v1.php
        },
      );

      /* * Analisi della risposta del server:
       * api_v1.php restituisce 200 OK anche in caso di errore, 
       * quindi controlliamo il contenuto del JSON.
       */
      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        /* Verifica dello stato 'success' e presenza del token JWT */
        if (responseData['status'] == 'success' &&
            responseData['token'] != null) {
          _token = responseData['token'];
          _isAuthenticated = true;

          /* Salvataggio persistente del token per sessioni future */
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString('jwt_token', _token!);

          /* Notifica i widget in ascolto del cambio di stato */
          notifyListeners();
          return true;
        } else {
          debugPrint(
            "Login fallito: ${responseData['message'] ?? 'Credenziali non valide'}",
          );
        }
      }
      return false;
    } catch (error) {
      /* Gestione errori di rete o parsing */
      debugPrint("Errore critico durante il login: $error");
      return false;
    }
  }

  /* * Tenta il login automatico all'avvio.
   * Recupera il token JWT salvato localmente se presente.
   */
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;

    _token = prefs.getString('jwt_token');
    _isAuthenticated = true;
    notifyListeners();
  }

  /* * Esegue il logout dell'utente.
   * Pulisce lo stato interno e rimuove il token dalle preferenze.
   */
  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }
}
