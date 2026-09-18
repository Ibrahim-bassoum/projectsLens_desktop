import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/project_provider.dart';
import '../providers/user_provider.dart';

import '../widgets/home_sidebar.dart';
import '../widgets/analysis_form_card.dart';
import '../widgets/stats_cards_row.dart';
import '../widgets/recent_analyses_section.dart';
import '../screens/projects_screen.dart';
import '../screens/import_project_screen.dart'; // <--- Import du nouvel écran

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _errorMessage;
  String _currentRoute = 'Tableau de bord';

  @override
  void dispose() {
    _urlController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _startAnalysis() async {
    setState(() {
      _errorMessage = null;
    });

    final name = _nameController.text.trim();
    final url = _urlController.text.trim();

    if (name.isEmpty || url.isEmpty) {
      setState(() {
        _errorMessage =
            'Veuillez renseigner le nom du projet et l\'URL du dépôt.';
      });
      return;
    }

    try {
      await ref.read(projectProvider.notifier).importGit(name, url);

      _urlController.clear();
      _nameController.clear();

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Dépôt importé et analysé avec succès !'),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    }
  }

  // Helper pour retourner la vue active
  Widget _buildCurrentView(
    List<dynamic> projects,
    bool isLoading,
    String firstName,
  ) {
    switch (_currentRoute) {
      case 'Mes projets':
        return ProjectsScreen(
          onImportClick: () {
            setState(() => _currentRoute = 'Importer un projet');
          },
        );

      case 'Importer un projet':
        return ImportProjectScreen(
          onImportSuccess: () {
            setState(() => _currentRoute = 'Mes projets');
          },
        );

      case 'Tableau de bord':
      default:
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête de bienvenue
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bonjour, $firstName 👋',
                        style: const TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      const Text(
                        "Analysez, documentez et explorez l'architecture de vos projets.",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Color(0xFF10B981),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${projects.length} projet${projects.length > 1 ? 's' : ''} actif${projects.length > 1 ? 's' : ''}',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF334155),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

              // Carte d'analyse / Import Git
              AnalysisFormCard(
                urlController: _urlController,
                nameController: _nameController,
                isLoading: isLoading,
                errorMessage: _errorMessage,
                onSubmit: _startAnalysis,
              ),
              const SizedBox(height: 24),

              // Statistiques globales
              const StatsCardsRow(),
              const SizedBox(height: 24),

              // Section des projets récents
              RecentAnalysesSection(
                projects: projects,
                onViewAllPressed: () {
                  setState(() {
                    _currentRoute = 'Mes projets';
                  });
                },
              ),
            ],
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(userProvider);
    final userData =
        userAsync.asData?.value ?? {'name': 'Développeur', 'email': ''};

    final String userName = userData['name'] ?? 'Développeur';
    final String userEmail = userData['email'] ?? '';
    final String firstName = userName.split(' ').first;

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

          // 2. Contenu principal selon la route sélectionnée
          Expanded(child: _buildCurrentView(projects, isLoading, firstName)),
        ],
      ),
    );
  }
}
