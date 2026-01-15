import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Import per la gestione degli appunti (Clipboard)
// Import assoluto come richiesto
import 'package:dashboard_fabersoft_new/models/account_model.dart';

/* * AccountCard: Versione 2.c interattiva.
 * Gestisce l'effetto hover su desktop e le azioni rapide.
 */
class AccountCard extends StatefulWidget {
  final Account account;

  const AccountCard({super.key, required this.account});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  // Variabile di stato per sapere se il mouse è sopra la mattonella
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      // Cambiamo lo stato quando il mouse entra o esce
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          // Aggiungiamo un'ombra più marcata se il mouse è sopra
          boxShadow: _isHovered
              ? [
                  BoxShadow(
                    color: primaryColor.withValues(alpha: 0.2),
                    blurRadius: 10,
                    spreadRadius: 2,
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 4,
                    spreadRadius: 1,
                  ),
                ],
        ),
        child: Card(
          margin: EdgeInsets.zero,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            children: [
              // --- LIVELLO 1: INFORMAZIONI DELL'ACCOUNT ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        CircleAvatar(
                          radius: 18,
                          backgroundColor: primaryColor.withValues(alpha: 0.1),
                          child: Text(
                            widget.account.label.isNotEmpty
                                ? widget.account.label[0].toUpperCase()
                                : '?',
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _buildMethodBadge(widget.account.method),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      widget.account.label,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.account.user.isNotEmpty
                          ? widget.account.user
                          : 'Nessun utente',
                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    if (widget.account.descr.isNotEmpty)
                      Text(
                        widget.account.descr,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 11,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (widget.account.note.isNotEmpty)
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
                          "[NOTE] ${widget.account.note}",
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

              // --- LIVELLO 2: AZIONI RAPIDE (VISIBILI SOLO IN HOVER) ---
              if (_isHovered)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(
                        alpha: 0.9,
                      ), // Sfondo semitrasparente
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _quickAction(
                            icon: Icons.person_outline,
                            label: 'User',
                            onTap: () =>
                                _copy(widget.account.user, 'Username copiato'),
                          ),
                          _quickAction(
                            icon: Icons.vpn_key_outlined,
                            label: 'Pass',
                            onTap: () => _copy(
                              '********',
                              'Password copiata',
                            ), // Simulata per ora
                          ),
                          _quickAction(
                            icon: Icons.launch,
                            label: 'Lancia',
                            onTap: () =>
                                debugPrint('Lancio: ${widget.account.host}'),
                            color: primaryColor,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget helper per i pulsanti User/Pass/Lancia
  Widget _quickAction({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        IconButton(
          icon: Icon(icon, color: color ?? Colors.grey[700]),
          onPressed: onTap,
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Funzione per copiare negli appunti
  void _copy(String text, String msg) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  // Badge del metodo (già visto nel 2.b)
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
