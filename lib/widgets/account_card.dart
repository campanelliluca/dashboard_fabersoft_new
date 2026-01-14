import 'package:flutter/material.dart';
import 'package:dashboard_fabersoft_new/models/account_model.dart';

/* * AccountCard: La "mattonella" quadrata interattiva.
 * Ridisegnata per il layout responsive 6-4-2.
 */
class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    // Recuperiamo il colore primario (Blu FaberSoft) dal tema
    final primaryColor = Theme.of(context).colorScheme.primary;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        // InkWell serve per dare l'effetto al clic
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          // Qui andrà la logica del Punto 3.b (Lancio sito)
          print('Lancio sito: ${account.host}');
        },
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- PARTE SUPERIORE: ICONA E METODO ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    radius: 18,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    child: Text(
                      account.label[0].toUpperCase(),
                      style: TextStyle(
                        color: primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  // Icona e dicitura Metodo (Punto 1.a)
                  _buildMethodBadge(account.method),
                ],
              ),
              const SizedBox(height: 12),

              // --- CENTRO: TITOLO E USER ---
              Text(
                account.label,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                account.user.isNotEmpty ? account.user : 'Nessun utente',
                style: TextStyle(color: Colors.grey[600], fontSize: 13),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),

              const Spacer(), // Spinge il contenuto successivo verso il basso
              // --- BASSO: DESCR E NOTE (Soluzione Overflow) ---
              // Descrizione in corsivo
              if (account.descr.isNotEmpty)
                Text(
                  account.descr,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                    fontSize: 11,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),

              // Tag Note con evidenza (Punto 1.a)
              if (account.note.isNotEmpty)
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.amber.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    "[NOTE] ${account.note}",
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  /* * Helper per creare il badge del metodo di autenticazione.
   */
  Widget _buildMethodBadge(String method) {
    IconData icon;
    String label;

    switch (method.toLowerCase()) {
      case 'form':
        icon = Icons.input;
        label = "Form";
        break;
      case 'basic':
        icon = Icons.lock_person;
        label = "Basic";
        break;
      case 'link':
        icon = Icons.link;
        label = "Link";
        break;
      default:
        icon = Icons.text_fields;
        label = "Plain";
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: Colors.grey[400]),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey[500])),
      ],
    );
  }
}
