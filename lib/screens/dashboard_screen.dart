import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  List<Account> _allAccounts = []; // Tutti i dati dal server
  List<Account> _filteredAccounts = []; // Dati filtrati per la UI
  bool _isLoading = true; // Stato del caricamento
  String _errorMessage = ''; // Gestione errori

  @override
  void initState() {
    super.initState();
    _fetchAccounts();
  }

  /* Caricamento dati iniziale tramite ApiService */
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

  /* Logica di filtraggio locale */
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
        /* Barra di ricerca integrata nell'AppBar */
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

  /* Widget dinamico per il corpo della pagina */
  /* * Punto 2.a: Widget per il corpo della pagina con Griglia Responsive.
   * LayoutBuilder ci permette di conoscere le dimensioni dello schermo.
   */
  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Text(
          'Errore: $_errorMessage',
          style: const TextStyle(color: Colors.red),
        ),
      );
    }

    if (_filteredAccounts.isEmpty) {
      return const Center(child: Text('Nessun account trovato.'));
    }

    // Usiamo LayoutBuilder per rendere la griglia adattiva
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcoliamo il numero di colonne in base alla larghezza disponibile
        int crossAxisCount = _getCrossAxisCount(constraints.maxWidth);

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          // Definiamo la struttura della griglia
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount, // 6, 4 o 2 colonne
            crossAxisSpacing: 16, // Spazio orizzontale tra mattonelle
            mainAxisSpacing: 16, // Spazio verticale tra mattonelle
            childAspectRatio: 1.0, // Le rende quadrate (mattonelle)
          ),
          itemCount: _filteredAccounts.length,
          itemBuilder: (context, index) {
            final account = _filteredAccounts[index];
            // Per ora usiamo ancora la vecchia AccountCard, la cambieremo nel punto 2.b
            return AccountCard(account: account);
          },
        );
      },
    );
  }

  /* * Helper per decidere il numero di colonne (Breakpoint).
   * Segue le tue specifiche: Desktop 6, Tablet 4, Smartphone 2.
   */
  int _getCrossAxisCount(double width) {
    if (width > 1200) {
      return 6; // Desktop
    } else if (width > 600) {
      return 4; // Tablet
    } else {
      return 2; // Smartphone
    }
  }
}
