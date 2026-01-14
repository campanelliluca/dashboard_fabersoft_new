import 'dart:convert'; // Necessario per decodificare il JSON
import 'package:http/http.dart' as http; // Gestisce le chiamate web
import '../models/account_model.dart'; // Importa il tuo modello dati

/*
  ApiService: Gestisce la comunicazione tra l'app Flutter e il server PHP.
  Include protezioni contro i valori 'null' per evitare crash improvvisi.
*/
class ApiService {
  // L'URL del gateway PHP che abbiamo configurato
  static const String baseUrl =
      'https://dashboard.abiseconsulting.it/api_v1.php';

  /*
    Recupera la lista degli account.
    [token]: Il "passaporto" ricevuto durante il login.
  */
  Future<List<Account>> getAccounts(String token) async {
    try {
      final url = Uri.parse('$baseUrl?action=list_accounts');

      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      // Log di debug fondamentale per vedere cosa arriva dal server nella console
      print('DEBUG Dashboard - Status: ${response.statusCode}');
      print('DEBUG Dashboard - Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = json.decode(response.body);

        if (responseData['status'] == 'success') {
          /* SOLUZIONE AL CRASH:
            Cerchiamo i dati sia sotto la chiave 'data' che sotto 'accounts'.
            Se entrambe sono assenti o 'null', usiamo una lista vuota [] 
            invece di far crashare l'app.
          */
          final List<dynamic> rawList =
              responseData['data'] ?? responseData['accounts'] ?? [];

          return rawList.map((json) => Account.fromJson(json)).toList();
        } else {
          throw Exception(
            responseData['message'] ?? 'Errore sconosciuto dal server',
          );
        }
      } else {
        throw Exception('Errore di connessione: ${response.statusCode}');
      }
    } catch (e) {
      print('ERRORE getAccounts: $e');
      throw Exception('Impossibile caricare gli account: $e');
    }
  }

  /*
    Effettua il login al server FaberSoft.
    Invia le credenziali e restituisce il token di sessione.
  */
  Future<String?> performLogin(String email, String password) async {
    try {
      final url = Uri.parse('$baseUrl?action=check_auth');

      // Inviando 'user' e 'pass' come richiesto dallo script api_v1.php
      final response = await http.post(
        url,
        body: {'user': email, 'pass': password},
      );

      print('DEBUG Login - Status: ${response.statusCode}');
      print('DEBUG Login - Body: ${response.body}');

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        if (data['status'] == 'success') {
          // Restituiamo il token ricevuto (o una stringa di successo)
          return data['token'] ?? 'SESSION_ACTIVE';
        }
      }
      return null; // Login fallito
    } catch (e) {
      print('Errore durante il login: $e');
      return null;
    }
  }
}
