import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
/* Import assoluti come da modus operandi */
import 'package:dashboard_fabersoft_new/providers/auth_provider.dart';
import 'package:dashboard_fabersoft_new/services/api_service.dart';
import 'package:dashboard_fabersoft_new/models/account_model.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  /* Future che conterrà la lista degli account caricati dal server */
  late Future<List<Account>> _accountsFuture;

  @override
  void initState() {
    super.initState();
    /* All'avvio della pagina, iniziamo subito a scaricare i dati */
    _loadAccounts();
  }

  void _loadAccounts() {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    /* Usiamo il token salvato nel provider per autenticare la richiesta */
    _accountsFuture = ApiService().getAccounts(auth.token ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'I Miei Account',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF005CAA),
        /* Blu FaberSoft */
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () =>
                Provider.of<AuthProvider>(context, listen: false).logout(),
          ),
        ],
      ),
      body: FutureBuilder<List<Account>>(
        future: _accountsFuture,
        builder: (context, snapshot) {
          /* 1. Stato di caricamento */
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          /* 2. Gestione errori (es. sessione scaduta o server offline) */
          if (snapshot.hasError) {
            return Center(child: Text('Errore: ${snapshot.error}'));
          }

          /* 3. Nessun dato trovato */
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('Nessun account trovato nel database.'),
            );
          }

          /* 4. Visualizzazione della lista reale */
          final accounts = snapshot.data!;
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: accounts.length,
            separatorBuilder: (context, index) => const Divider(),
            itemBuilder: (context, index) {
              final acc = accounts[index];
              return ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFF005CAA),
                  child: Icon(Icons.vpn_key_outlined, color: Colors.white),
                ),
                title: Text(
                  acc.label,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text('User: ${acc.user}'),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  /* Qui in futuro apriremo il dettaglio con la password */
                },
              );
            },
          );
        },
      ),
    );
  }
}
