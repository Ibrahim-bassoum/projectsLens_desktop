import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart'; // Adapte le chemin selon ton arborescence

class StatsCardsRow extends ConsumerWidget {
  const StatsCardsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // On écoute le provider des statistiques
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      data: (stats) {
        // Extraction des données reçues du backend Spring Boot
        final totalProjects = stats['totalProjects']?.toString() ?? '0';
        final totalFiles = stats['totalFiles']?.toString() ?? '0';

        return Row(
          children: [
            _buildStatCard(
              'Projets analysés',
              totalProjects,
              'Actifs',
              Icons.code,
            ),
            const SizedBox(width: 15),
            _buildStatCard(
              'Fichiers analysés',
              totalFiles,
              'Enregistrés',
              Icons.folder,
            ),
            const SizedBox(width: 15),
            _buildStatCard('Lignes de code', 'Estimé', 'N/A', Icons.layers),
            const SizedBox(width: 15),
            _buildStatCard(
              'Temps gagné',
              '${(int.tryParse(totalProjects) ?? 0) * 2}h',
              'Total',
              Icons.access_time,
            ),
          ],
        );
      },
      loading: () => const Row(
        children: [
          Expanded(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(20.0),
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
        ],
      ),
      error: (err, stack) => Row(
        children: [
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Text(
                'Erreur de chargement des stats',
                style: TextStyle(color: Colors.red.shade400, fontSize: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String subtext,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
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
                Icon(icon, size: 18, color: Colors.grey),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              subtext,
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
