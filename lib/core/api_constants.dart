/* * Costanti API per FaberSoft Dashboard.
 * Centralizza gli URL per la comunicazione sicura con il server.
 */

class ApiConstants {
  // Dominio base del server Abise
  static const String baseUrl = "https://dashboard.abiseconsulting.it";

  // Endpoint per l'autenticazione (POST)
  static const String loginEndpoint = "$baseUrl/api_v1.php?action=check_auth";

  // Endpoint per il recupero dati (Azioni future)
  static const String rpcEndpoint = "$baseUrl/api_v1.php?action=list_accounts";
}
