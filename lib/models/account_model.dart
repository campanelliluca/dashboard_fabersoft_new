/* * Modello Account: Rappresenta la struttura dati di un singolo account/login.
 * Questo file è il "progetto" che spiega a Flutter come leggere i dati inviati dal server PHP.
 */
class Account {
  final String id;
  final String label;
  final String host;
  final String user;
  final String descr;
  final String note;

  /* * AGGIORNAMENTO 1.b: Campo 'method'
   * Indica la modalità di autenticazione (es. 'link', 'form', 'basic', 'plain').
   * Sarà fondamentale per decidere quale icona mostrare e come deve comportarsi la mattonella.
   */
  final String method;

  Account({
    required this.id,
    required this.label,
    required this.host,
    required this.user,
    required this.descr,
    required this.note,
    required this.method,
  });

  /* * factory Account.fromJson:
   * Questo metodo trasforma la risposta JSON del server in un oggetto Account utilizzabile da Flutter.
   */
  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      // Se il valore dal database è null (??), assegniamo una stringa vuota per evitare crash (null-safety)
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? 'Senza nome').toString(),
      host: (json['host'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      descr: (json['descr'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),

      /* * Mappatura del campo 'method':
       * Leggiamo il valore inviato dal PHP (punto 1.a). 
       * Se non presente, impostiamo 'link' come valore predefinito.
       */
      method: (json['method'] ?? 'link').toString(),
    );
  }
}
