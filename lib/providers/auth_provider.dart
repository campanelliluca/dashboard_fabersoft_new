import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Usiamo gli import assoluti come richiesto
import 'package:dashboard_fabersoft_new/services/api_service.dart';

/*
 * AuthProvider: Gestisce lo stato di autenticazione dell'utente.
 * Notifica a tutta l'app quando l'utente entra o esce (Login/Logout).
*/
class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isAuthenticated = false;

  // Getter per leggere lo stato dall'esterno
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  /*
  Tenta il login e salva il token in modo persistente.
  */
  Future<bool> login(String email, String password) async {
    try {
      // CREIAMO UN'ISTANZA DEL SERVIZIO
      final api = ApiService();

      // CHIAMIAMO IL METODO REALE (Ora l'import è UTILIZZATO!)
      final responseToken = await api.performLogin(email, password);

      if (responseToken != null) {
        _token = responseToken;
        _isAuthenticated = true;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /*
   Carica il token salvato all'avvio dell'app.
  */
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;

    _token = prefs.getString('jwt_token');
    _isAuthenticated = true;
    notifyListeners();
  }

  /*
   Cancella il token e riporta l'utente alla schermata di login.
  */
  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');
    notifyListeners();
  }
}
