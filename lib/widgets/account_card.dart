import 'package:flutter/material.dart';
import 'package:dashboard_fabersoft_new/models/account_model.dart';

/*
 * AccountCard: Widget per la visualizzazione moderna di un account.
 * Organizza le informazioni (Label, Note, Host) in una scheda con ombreggiatura.
 */
class AccountCard extends StatelessWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3, // Profondità della scheda
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15), // Bordi arrotondati
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /* Avatar con l'iniziale del servizio */
            CircleAvatar(
              backgroundColor: const Color(0xFF005CAA), // Blu FaberSoft
              child: Text(
                account.label.isNotEmpty ? account.label[0].toUpperCase() : '?',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(width: 16),

            /* Colonna informativa centrale */
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 1. Titolo dell'account (Label)
                  Text(
                    account.label,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  // 2. Note per l'utente (Richiesta specifica)
                  if (account.note.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        account.note,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.blueGrey[700],
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ),

                  const SizedBox(height: 8),

                  // 3. Informazioni tecniche (Host e User)
                  Row(
                    children: [
                      const Icon(Icons.link, size: 14, color: Colors.grey),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          account.host,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            /* Freccia laterale per indicare interattività */
            const Center(child: Icon(Icons.chevron_right, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
