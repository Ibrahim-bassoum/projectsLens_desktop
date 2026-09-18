import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/stats_provider.dart';

class StatsCardsRow extends ConsumerWidget {
  const StatsCardsRow({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statsAsync = ref.watch(statsProvider);

    return statsAsync.when(
      data: (stats) {
        final totalProjects = stats['totalProjects']?.toString() ?? '0';
        final totalFiles = stats['totalFiles']?.toString() ?? '0';

        return Row(
          children: [
            _buildStatCard(
              'Projets analysés',
              totalProjects,
              'Enregistrés',
              Icons.folder_outlined,
              const Color(0xFF2563EB),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Fichiers indexés',
              totalFiles,
              'Code source',
              Icons.insert_drive_file_outlined,
              const Color(0xFF059669),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Composants & AST',
              'Actifs',
              'Tree-Sitter',
              Icons.account_tree_outlined,
              const Color(0xFF7C3AED),
            ),
            const SizedBox(width: 16),
            _buildStatCard(
              'Temps de synthèse',
              '${(int.tryParse(totalProjects) ?? 0) * 2}h',
              'Gagnées',
              Icons.access_time_rounded,
              const Color(0xFFD97706),
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
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.black,
                ),
              ),
            ),
          ),
        ],
      ),
      error: (err, stack) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFFECDD3)),
        ),
        child: Text(
          'Impossible de charger les statistiques : $err',
          style: const TextStyle(color: Color(0xFFBE123C), fontSize: 12),
        ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    String badgeText,
    IconData icon,
    Color accentColor,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Icon(icon, size: 18, color: accentColor),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w800,
                color: Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                badgeText,
                style: const TextStyle(
                  color: Color(0xFF475569),
                  fontSize: 10.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
