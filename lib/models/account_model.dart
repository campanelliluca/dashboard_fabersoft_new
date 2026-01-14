class Account {
  final String id;
  final String label;
  final String host;
  final String user;
  final String descr;
  final String note;

  Account({
    required this.id,
    required this.label,
    required this.host,
    required this.user,
    required this.descr,
    required this.note,
  });

  factory Account.fromJson(Map<String, dynamic> json) {
    return Account(
      // Se il valore è null, mettiamo una stringa vuota ''
      id: (json['id'] ?? '').toString(),
      label: (json['label'] ?? 'Senza nome').toString(),
      host: (json['host'] ?? '').toString(),
      user: (json['user'] ?? '').toString(),
      descr: (json['descr'] ?? '').toString(),
      note: (json['note'] ?? '').toString(),
    );
  }
}
