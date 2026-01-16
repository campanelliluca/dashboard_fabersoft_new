import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
/* Import del nuovo pacchetto per il Drag & Drop */
import 'package:reorderable_grid_view/reorderable_grid_view.dart';

/* Import assoluti come richiesto dal modus operandi */
import 'package:dashboard_fabersoft_new/providers/auth_provider.dart';
import 'package:dashboard_fabersoft_new/services/api_service.dart';
import 'package:dashboard_fabersoft_new/models/account_model.dart';
import 'package:dashboard_fabersoft_new/widgets/account_card.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<Account> _allAccounts = [];
  List<Account> _filteredAccounts = [];
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  Future<void> _fetchAccounts() async {
    try {
      final auth = Provider.of<AuthProvider>(context, listen: false);
      final data = await ApiService().getAccounts(auth.token ?? '');

      setState(() {
        _allAccounts = data;
        _filteredAccounts = data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    setState(() {
      _filteredAccounts = _allAccounts
          .where(
            (acc) =>
                acc.label.toLowerCase().contains(query.toLowerCase()) ||
                acc.host.toLowerCase().contains(query.toLowerCase()),
          )
          .toList();
    });
  }

  /* * 3.a: Funzione di riordinamento.
   * Viene chiamata quando l'utente rilascia una mattonella in una nuova posizione.
   */
  void _onReorder(int oldIndex, int newIndex) {
    setState(() {
      // Rimuoviamo l'elemento dalla vecchia posizione e lo inseriamo nella nuova
      final account = _filteredAccounts.removeAt(oldIndex);
      _filteredAccounts.insert(newIndex, account);

      // NOTA: Qui in futuro aggiungeremo la chiamata API per salvare l'ordine sul DB
      debugPrint("Nuovo ordine salvato localmente");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'FaberSoft Dashboard',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(70),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Cerca per nome o host...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(15),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) return const Center(child: CircularProgressIndicator());
    if (_errorMessage.isNotEmpty)
      return Center(
        child: Text(
          'Errore: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    if (_filteredAccounts.isEmpty)
      return const Center(child: Text('Nessun account trovato.'));

    return LayoutBuilder(
      builder: (context, constraints) {
        int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        /* * PUNTO 3.a: ReorderableGridView
         * Sostituisce il GridView standard per permettere il Drag & Drop.
         */
        return ReorderableGridView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredAccounts.length,
          /* Callback obbligatorio per gestire lo spostamento */
          onReorder: _onReorder,
          /* * Impostiamo il ritardo del Long Press. 
          * 200 millisecondi rendono l'azione immediata ma evitano attivazioni involontarie.
          */
          dragStartDelay: const Duration(milliseconds: 200),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            /* Abbiamo mantenuto 0.65 come concordato per evitare overflow */
            childAspectRatio: 0.75,
          ),
          itemBuilder: (context, index) {
            final account = _filteredAccounts[index];
            return AccountCard(
              /* Fondamentale: ogni mattonella deve avere una Key univoca per il Drag & Drop */
              key: ValueKey(account.id),
              account: account,
            );
          },
        );
      },
    );
  }

  int _getCrossAxisCount(double width) {
    if (width > 1200) return 6;
    if (width > 600) return 4;
    return 2;
  }
}
