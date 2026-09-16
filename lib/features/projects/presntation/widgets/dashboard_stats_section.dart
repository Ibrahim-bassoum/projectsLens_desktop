import 'package:flutter/material.dart';

class DashboardStatsSection extends StatelessWidget {
  final String userName;
  final TextEditingController repoUrlController;
  final TextEditingController projectNameController;
  final bool isImporting;
  final VoidCallback onImportPressed;
  final int totalProjects;

  const DashboardStatsSection({
    super.key,
    required this.userName,
    required this.repoUrlController,
    required this.projectNameController,
    required this.isImporting,
    required this.onImportPressed,
    required this.totalProjects,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // En-tête et Assistant IA
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bonjour, $userName 👋',
                  style: const TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Bienvenue sur ProjectLens. Analysez vos projets, générez de la documentation et posez vos questions à l\'IA.',
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.auto_awesome,
                    color: Colors.deepPurple,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Votre assistant IA',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        'Posez vos questions sur le projet',
                        style: TextStyle(color: Colors.grey, fontSize: 10),
                      ),
                    ],
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onPressed: () {},
                    child: const Text(
                      'Ouvrir le chat IA',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Grille des 5 actions rapides (comme sur la maquette : Importer, Analyser, Générer doc, Voir diagrammes, Ouvrir assistant)
        Row(
          children: [
            _buildQuickActionCard(
              Icons.upload_file,
              'Importer un projet',
              'ZIP ou GitHub',
            ),
            const SizedBox(width: 12),
            _buildQuickActionCard(
              Icons.search,
              'Analyser',
              'Lancer une analyse complète',
            ),
            const SizedBox(width: 12),
            _buildQuickActionCard(
              Icons.description_outlined,
              'Générer la documentation',
              'README, API, Architecture...',
            ),
            const SizedBox(width: 12),
            _buildQuickActionCard(
              Icons.account_tree_outlined,
              'Voir les diagrammes',
              'UML, architecture, packages...',
            ),
            const SizedBox(width: 12),
            _buildQuickActionCard(
              Icons.auto_awesome,
              'Ouvrir l\'assistant IA',
              'Poser des questions sur le projet',
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Bloc d'importation d'un nouveau projet
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Analyser un nouveau projet via Git',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    flex: 3,
                    child: TextField(
                      controller: repoUrlController,
                      decoration: InputDecoration(
                        hintText: 'https://github.com/username/repository',
                        prefixIcon: const Icon(Icons.link, size: 18),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: TextField(
                      controller: projectNameController,
                      decoration: InputDecoration(
                        hintText: 'Nom du projet (ex: E-commerce API)',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isImporting ? null : onImportPressed,
                    icon: isImporting
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.arrow_forward, size: 18),
                    label: Text(
                      isImporting ? 'Analyse...' : 'Analyser le projet',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),

        // Statistiques globales
        Row(
          children: [
            _buildStatCard(
              'Projets analysés',
              '$totalProjects',
              '+2 ce mois-ci',
              Icons.folder,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Fichiers analysés',
              '8,452',
              '+1,231 ce mois-ci',
              Icons.insert_drive_file,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Lignes de code',
              '312,104',
              '+45,231 ce mois-ci',
              Icons.code,
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Temps gagné',
              '58h',
              '+12h ce mois-ci',
              Icons.timer,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildQuickActionCard(IconData icon, String title, String subtitle) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Icon(icon, size: 20, color: Colors.black87),
                const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.grey, fontSize: 10),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtitle,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
                Icon(icon, size: 16, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(
                color: Colors.green,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
