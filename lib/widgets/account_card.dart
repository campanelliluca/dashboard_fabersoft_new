import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessario per la Clipboard
/* Import assoluto del modello dati */
import 'package:dashboard_fabersoft_new/models/account_model.dart';

/*
 * AccountCard: Un widget personalizzato che rappresenta un account.
 * Utilizza uno stile a Card con ombreggiatura e angoli arrotondati.
 */
class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Ombreggiatura per dare profondità
      margin: const EdgeInsets.only(bottom: 12), // Spazio tra le card
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Angoli arrotondati moderni
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              /* 1. Icona identificativa generata dall'iniziale del servizio */
              CircleAvatar(
                radius: 25,
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                child: Text(
                  account.label.isNotEmpty
                      ? account.label[0].toUpperCase()
                      : '?',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              /* 2. Area Testuale con Titolo e Host */
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      account.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      account.host,
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (account.descr.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        account.descr,
                        style: const TextStyle(
                          fontSize: 12,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              /* 3. Icona laterale per indicare la possibilità di cliccare */
              const VerticalDivider(
                width: 20,
                thickness: 1,
                indent: 5,
                endIndent: 5,
              ),
              Icon(
                Icons.chevron_right,
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
