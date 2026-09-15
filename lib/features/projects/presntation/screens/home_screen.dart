import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importe ton fichier de providers (adapte le chemin si nécessaire)
import '../providers/project_provider.dart';
import '../widgets/home_sidebar.dart';
import '../widgets/analysis_form_card.dart';
import '../widgets/stats_cards_row.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();

  String? _errorMessage;
  String _documentationResult = '';

  void _startAnalysis() async {
    setState(() {
      _errorMessage = null;
      _documentationResult = '';
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
      // Appel du Notifier Riverpod pour importer et rafraîchir la liste en arrière-plan
      await ref.read(projectProvider.notifier).importGit(name, url);

      // Réinitialisation des champs après le succès
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
    // On écoute l'état global du provider pour récupérer l'état de chargement
    final projectState = ref.watch(projectProvider);
    final bool isLoading = projectState.isLoading;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: Row(
        children: [
          // 1. SIDEBAR DE GAUCHE
          const HomeSidebar(
            userName: 'John Doe',
            userEmail: 'john.doe@email.com',
          ),

          // 2. CONTENU PRINCIPAL
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // En-tête de bienvenue
                  const Text(
                    'Bonjour, John 👋',
                    style: TextStyle(
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

                  // Bannière d'analyse principale (Formulaire lié au Provider)
                  AnalysisFormCard(
                    urlController: _urlController,
                    nameController: _nameController,
                    isLoading: isLoading,
                    errorMessage: _errorMessage,
                    onSubmit: _startAnalysis,
                  ),
                  const SizedBox(height: 25),

                  // Cartes de statistiques
                  const StatsCardsRow(),

                  // Affichage optionnel du résultat textuel s'il y en a un
                  if (_documentationResult.isNotEmpty) ...[
                    const SizedBox(height: 25),
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Résultat de l\'analyse',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 10),
                          SelectableText(_documentationResult),
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
