import 'dart:convert'; // Per decodificare il JSON dal server
import 'package:dashboard_fabersoft_new/models/account_model.dart';
import 'package:http/http.dart' as http; // Per fare le chiamate web

/*
 ApiService: Gestisce la comunicazione con il server FaberSoft.
*/
class ApiService {
  // L'URL base del tuo gateway PHP
  static const String baseUrl =
      'https://dashboard.abiseconsulting.it/api_v1.php';

  /*
    Recupera la lista degli account dal server.
    [token]: Il "passaporto" JWT che abbiamo configurato nel PHP.
  */
  Future<List<Account>> getAccounts(String token) async {
    try {
      // Componiamo l'URL con l'azione richiesta
      final url = Uri.parse('$baseUrl?action=list_accounts');

      // Effettuiamo la chiamata GET inviando il token negli Header (Sicurezza NIS2)
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token', // Inseriamo il JWT qui
          'Accept': 'application/json',
        },
      );

      /* AGGIUNGI QUESTA RIGA DI LOG QUI SOTTO */
      print(
        'DEBUG Dashboard - Risposta Server: ${response.statusCode} - ${response.body}',
      );

      // Verifichiamo se il server ha risposto OK (Codice 200)
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          // Trasformiamo la lista JSON in una lista di oggetti Account
          List<dynamic> data = responseData['data'];
          return data.map((json) => Account.fromJson(json)).toList();
        } else {
          throw Exception(responseData['message'] ?? 'Errore dal server');
        }
      } else {
        throw Exception('Errore di connessione: ${response.statusCode}');
      }
    } catch (e) {
      // In caso di problemi di rete o errori nel codice
      throw Exception('Impossibile caricare gli account: $e');
    }
  }

  /*
   * Effettua il login al server FaberSoft.
   * Invia email e password e restituisce il token JWT se corretto.
   */

  /*
  Future<String?> performLogin(String email, String password) async {
    try {
      // Usiamo l'azione 'check_auth' o una specifica per il login se prevista.
      // In molti sistemi FaberSoft, il login avviene tramite i parametri
      // passati al file di sicurezza.
      final url = Uri.parse('$baseUrl?action=check_auth');

      final response = await http.post(
        url,
        body: {'user': email, 'pass': password},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Qui il server dovrebbe restituire il token.
          // Se il sistema lo mette in un campo specifico, lo leggiamo.
          return data['token'] ?? 'TOKEN_GENERICO_SUCCESSO';
        }
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  */
  /*
   * Effettua il login al server FaberSoft con set di credenziali esteso.
   */
  Future<String?> performLogin(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl?action=check_auth');

      final response = await http.post(
        url,
        body: {
          /* Proviamo a inviare entrambi i set per compatibilità */
          'user': email,
          'pass': password,
          'email': email,
          'password': password,
        },
      );

      /* Debug: stampiamo in console cosa dice il server */
      print('Risposta Server: ${response.statusCode} - ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          /* Restituiamo il token o un valore di successo */
          return data['token'] ?? 'SESSION_ACTIVE';
        }
      }
      return null;
    } catch (e) {
      print('Errore durante il login: $e');
      return null;
    }
  }
}
