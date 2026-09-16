import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Importe tes providers
import '../providers/project_provider.dart';
import '../providers/user_provider.dart';

// Importation de tes widgets existants et de ton écran "Mes projets"
import '../widgets/home_sidebar.dart';
import '../widgets/analysis_form_card.dart';
import '../widgets/stats_cards_row.dart';
import '../widgets/recent_analyses_section.dart';
import '../screens/projects_screen.dart'; // <--- Importe ton écran "Mes projets"

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _errorMessage;

  // État pour suivre l'onglet actif dans la sidebar
  String _currentRoute = 'Tableau de bord';

  void _startAnalysis() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final url = _urlController.text.trim();

    if (name.isEmpty || url.isEmpty) {
      setState(() {
        _errorMessage = 'Veuillez remplir tous les champs.';
      });
      return;
    }

    try {
      await ref.read(projectProvider.notifier).importGit(name, url);

      _urlController.clear();
      _nameController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projet analysé et importé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. On écoute le provider utilisateur
    final userAsync = ref.watch(userProvider);
    final userData =
        userAsync.asData?.value ?? {'name': 'Utilisateur', 'email': '...'};

    final String userName = userData['name'] ?? 'Utilisateur';
    final String userEmail = userData['email'] ?? '';
    final String firstName = userName.split(' ').first;

    // 2. On écoute l'AsyncValue global des projets
    final projectAsync = ref.watch(projectProvider);

    final bool isLoading = projectAsync.isLoading;
    final List<dynamic> projects = projectAsync.asData?.value ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. Sidebar de gauche dynamique
          HomeSidebar(
            userName: userName,
            userEmail: userEmail,
            currentRoute: _currentRoute,
            onNavItemSelected: (route) {
              setState(() {
                _currentRoute = route;
              });
            },
          ),

          // 2. Contenu principal dynamique selon la route active
          Expanded(
            child: _currentRoute == 'Mes projets'
                ? const ProjectsScreen() // Affiche l'écran complet "Mes projets"
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(30),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête de bienvenue
                        Text(
                          'Bonjour, $firstName 👋',
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                        const Text(
                          "Analysez et comprenez n'importe quel projet logiciel.",
                          style: TextStyle(color: Colors.grey, fontSize: 14),
                        ),
                        const SizedBox(height: 25),

                        // Formulaire d'analyse / import Git
                        AnalysisFormCard(
                          urlController: _urlController,
                          nameController: _nameController,
                          isLoading: isLoading,
                          errorMessage: _errorMessage,
                          onSubmit: _startAnalysis,
                        ),
                        const SizedBox(height: 25),

                        // Ligne des cartes de statistiques
                        const StatsCardsRow(),
                        const SizedBox(height: 25),

                        // Section des projets récents avec redirection vers "Mes projets"
                        RecentAnalysesSection(
                          projects: projects,
                          onViewAllPressed: () {
                            setState(() {
                              _currentRoute =
                                  'Mes projets'; // Change l'onglet actif
                            });
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
