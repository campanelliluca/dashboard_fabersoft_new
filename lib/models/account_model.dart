/**
 * Modello Dati: Account
 * Rappresenta la struttura esatta della tabella 'accounts' del database FaberSoft.
 */
class Account {
  final String id; // ID univoco (bigint nel DB)
  final String host; // URL del sito remoto
  final String user; // Username di accesso al servizio
  final String pass; // Password di accesso al servizio
  final String label; // Nome visualizzato (es. Aruba, Register)
  final String? note; // Eventuali note dell'utente
  final String? descr; // Descrizione estesa del servizio
  final String method; // Metodo di login (plain, link, form)

  // Costruttore dell'oggetto Account
  Account({
    required this.id,
    required this.host,
    required this.user,
    required this.pass,
    required this.label,
    this.note,
    this.descr,
    required this.method,
  });

  /*
   Factory Method: fromJson
   Converte una mappa JSON proveniente dall'API Bridge (PHP) in un oggetto Account.
  */
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      // Trasformiamo tutto in String per sicurezza di tipo
      id: json['id']?.toString() ?? '',
      host: json['host']?.toString() ?? '',
      user: json['user']?.toString() ?? '',
      pass: json['pass']?.toString() ?? '',
      label: json['label']?.toString() ?? 'Senza Nome',
      note: json['note']?.toString(),
      descr: json['descr']?.toString(),
      method: json['method']?.toString() ?? 'plain',
    );
  }
}
