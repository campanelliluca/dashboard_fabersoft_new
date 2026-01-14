import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/account_model.dart';
import '../core/api_constants.dart'; // Importiamo le costanti centralizzate

/* * ApiService: Gestisce tutte le chiamate verso il server PHP.
 * Include una modalità Demo per testare l'interfaccia con molti dati.
 */
class ApiService {
  /* * FLAG MODALITÀ DEMO:
   * Se impostato su 'true', l'app aggiungerà 25 account di test a quelli reali.
   * Utile per verificare il layout responsive a 6 colonne.
   */
  static const bool isDemoMode = true;

  /* * Recupera la lista degli account dal server.
   */
  Future<List<Account>> getAccounts(String token) async {
    List<Account> accounts = [];

    try {
      // Usiamo l'endpoint definito centralmente in api_constants.dart
      final response = await http.get(
        Uri.parse(ApiConstants.rpcEndpoint),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Log per il debug in console (utile per vedere se il campo 'method' arriva correttamente)
      print('DEBUG API - Status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);
        if (responseData['status'] == 'success') {
          final List<dynamic> rawList = responseData['data'] ?? [];

          // Trasformiamo i dati JSON in oggetti della classe Account
          accounts = rawList.map((json) => Account.fromJson(json)).toList();
        }
      }
    } catch (e) {
      print('ERRORE API REALE: $e');
      // In caso di errore di rete, procediamo comunque per mostrare almeno i dati demo se attivi
    }

    // --- LOGICA MOCK DATA (1.c) ---
    if (isDemoMode) {
      accounts.addAll(_generateMockAccounts());
    }

    return accounts;
  }

  /* * Generatore di dati di test:
   * Crea account finti con diversi metodi di autenticazione per testare la UI.
   */
  List<Account> _generateMockAccounts() {
    final List<String> methods = ['link', 'form', 'basic', 'plain'];

    return List.generate(24, (index) {
      return Account(
        id: 'mock_$index',
        label: 'Account Test ${index + 1}',
        host: 'https://service-demo-${index + 1}.it',
        user: 'luca.test@fabersoft.it',
        descr: 'Questa è una descrizione di prova per il servizio ${index + 1}',
        note: index % 3 == 0
            ? 'Ricordarsi di resettare la password ogni 30 giorni.'
            : '',
        method: methods[index % methods.length], // Alterna i 4 metodi esistenti
      );
    });
  }

  /* * Effettua il login inviando user e pass al server.
   */
  Future<String?> performLogin(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(ApiConstants.loginEndpoint),
        body: {'user': email, 'pass': password},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          return data['token'] ?? 'SESSION_OK';
        }
      }
      return null;
    } catch (e) {
      print('Errore durante il login: $e');
      return null;
    }
  }
}
