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

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredAccounts.length,
      itemBuilder: (context, index) {
        return AccountCard(account: _filteredAccounts[index]);
      },
    );
  }
}
