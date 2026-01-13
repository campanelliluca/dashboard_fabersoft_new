import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/* Usiamo gli import assoluti per garantire la manutenibilità del progetto */
import 'package:dashboard_fabersoft_new/services/api_service.dart';

/*
 * AuthProvider: Gestisce lo stato globale di autenticazione dell'utente.
 * Questa classe funge da "motore di sicurezza" dell'app, notificando i cambiamenti
 * di stato (Login/Logout) a tutti i widget della UI in tempo reale.
 */
class AuthProvider with ChangeNotifier {
  String? _token;
  bool _isAuthenticated = false;

  /* Getter pubblici per accedere allo stato di sicurezza dall'esterno */
  String? get token => _token;
  bool get isAuthenticated => _isAuthenticated;

  /*
   * Tenta il login reale contattando il backend FaberSoft.
   * Utilizza il sistema htpasswd.db e la firma JWT ufficiale.
   */
  Future<bool> login(String email, String password) async {
    try {
      /* Istanza del servizio API per la comunicazione di rete */
      final api = ApiService();

      /* Esecuzione della richiesta di autenticazione sul server */
      final responseToken = await api.performLogin(email, password);

      if (responseToken != null) {
        _token = responseToken;
        _isAuthenticated = true;

        /* Persistenza del token nel dispositivo tramite SharedPreferences */
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('jwt_token', _token!);

        /* Notifica i widget per il passaggio automatico alla Dashboard */
        notifyListeners();
        return true;
      }

      /* Login fallito: impostiamo lo stato a non autenticato */
      _isAuthenticated = false;
      notifyListeners();
      return false;
    } catch (e) {
      /* Gestione sicura di eventuali crash o errori di connessione */
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }
  }

  /*
   * Tenta di ripristinare una sessione esistente all'avvio dell'app.
   * Verifica se è presente un token salvato in precedenza.
   */
  Future<void> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey('jwt_token')) return;

    _token = prefs.getString('jwt_token');
    _isAuthenticated = true;
    notifyListeners();
  }

  /*
   * Esegue la disconnessione sicura dell'utente.
   * Rimuove il token dalla memoria volatile e dal database locale del dispositivo.
   */
  Future<void> logout() async {
    _token = null;
    _isAuthenticated = false;

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('jwt_token');

    /* Notifica l'app per riportare l'utente alla schermata di Login */
    notifyListeners();
  }
}
