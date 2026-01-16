import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dashboard_fabersoft_new/models/account_model.dart';

class AccountCard extends StatefulWidget {
  final Account account;
  const AccountCard({super.key, required this.account});

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> {
  bool _isHovered = false;

  /* * * Funzione per aprire l'URL nel browser.
   * Include un controllo per aggiungere lo schema https:// se mancante.
   */
  Future<void> _openLink() async {
    String host = widget.account.host.trim();
    if (host.isEmpty) return;

    // Se l'host non inizia con http o https, lo aggiungiamo noi
    if (!host.startsWith('http://') && !host.startsWith('https://')) {
      host = 'https://$host';
    }

    final Uri url = Uri.parse(host);

    try {
      // launchUrl con externalApplication apre il browser predefinito del sistema
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Impossibile lanciare $url';
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore: Indirizzo non valido ($host)')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Theme.of(context).colorScheme.primary;

    return MouseRegion(
      // Usiamo 'grab' per indicare che la mattonella è spostabile (Drag & Drop)
      // Quando l'utente preme, diventerà automaticamente 'grabbing' (manina chiusa)
      cursor: SystemMouseCursors.grab,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
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
              // --- LIVELLO 1: VISUALIZZAZIONE DATI (Senza click diretto) ---
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
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
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      widget.account.user.isNotEmpty
                          ? widget.account.user
                          : 'Nessun utente',
                      style: TextStyle(color: Colors.grey[600], fontSize: 14),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Divider(height: 24, thickness: 0.5),
                    if (widget.account.descr.isNotEmpty)
                      Text(
                        widget.account.descr,
                        style: const TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: 13,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    const SizedBox(height: 8),
                    if (widget.account.note.isNotEmpty)
                      Flexible(
                        child: Text(
                          "[NOTE] ${widget.account.note}",
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.orange.shade800,
                          ),
                          maxLines: 4,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                  ],
                ),
              ),

              // --- LIVELLO 2: OVERLAY AZIONI RAPIDE ---
              Positioned.fill(
                child: AnimatedOpacity(
                  opacity: _isHovered ? 1.0 : 0.0,
                  duration: const Duration(milliseconds: 300),
                  child: IgnorePointer(
                    ignoring: !_isHovered,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(
                          alpha: 0.95,
                        ), // Leggermente più coprente
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Qui il cursore tornerà automaticamente a 'click'
                          // perché IconButton ha il suo comportamento nativo
                          _quickAction(
                            Icons.person_outline,
                            'User',
                            () =>
                                _copy(widget.account.user, 'Username copiato'),
                          ),
                          _quickAction(
                            Icons.vpn_key_outlined,
                            'Pass',
                            () => _copy('********', 'Password copiata'),
                          ),
                          // RINOMINATO: Da "Lancia" a "Apri" e collegato alla funzione corretta
                          _quickAction(
                            Icons.open_in_new,
                            'Apri',
                            _openLink,
                            color: primaryColor,
                          ),
                        ],
                      ),
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

  // Widget helper per i pulsanti User/Pass/Apri
  // --- HELPER AGGIORNATO PER AZIONI RAPIDE ---
  Widget _quickAction(
    IconData icon,
    String label,
    VoidCallback onTap, {
    Color? color,
  }) {
    return InkWell(
      onTap: onTap, // Il click ora è attivo su tutto il widget (Icona + Testo)
      borderRadius: BorderRadius.circular(
        8,
      ), // Arrotonda l'effetto "ripple" al clic
      // Cambiamo il cursore in 'click' per questa specifica area
      mouseCursor: SystemMouseCursors.click,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey[700],
              size: 24, // Leggermente più grande per facilitare il click
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  // Funzione per copiare negli appunti
  void _copy(String text, String msg) {
    if (text.isEmpty) return;
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(msg), duration: const Duration(seconds: 1)),
    );
  }

  // Badge del metodo di autenticazione
  Widget _buildMethodBadge(String method) {
    return Text(
      method.toUpperCase(),
      style: TextStyle(
        fontSize: 10,
        color: Colors.grey[500],
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
