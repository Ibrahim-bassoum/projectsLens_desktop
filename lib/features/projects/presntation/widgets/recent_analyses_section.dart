import 'package:flutter/material.dart';
import '../../../documents/presentation/screens/project_documents_screen.dart';

class RecentAnalysesSection extends StatelessWidget {
  final List<dynamic> projects;
  final VoidCallback? onViewAllPressed;

  const RecentAnalysesSection({
    super.key,
    required this.projects,
    this.onViewAllPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Tableau des Projets récents
        Expanded(
          flex: 6,
          child: Container(
            padding: const EdgeInsets.all(24),
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
                    const Text(
                      'Projets récents',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    TextButton(
                      onPressed: onViewAllPressed,
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Row(
                        children: [
                          Text(
                            'Voir tout',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 14,
                            color: Color(0xFF0F172A),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Table(
                  columnWidths: const {
                    0: FlexColumnWidth(4),
                    1: FlexColumnWidth(3),
                    2: FlexColumnWidth(2),
                  },
                  children: [
                    const TableRow(
                      decoration: BoxDecoration(
                        border: Border(
                          bottom: BorderSide(
                            color: Color(0xFFF1F5F9),
                            width: 1.5,
                          ),
                        ),
                      ),
                      children: [
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'NOM DU PROJET',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'DÉPÔT GIT',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.only(bottom: 12),
                          child: Text(
                            'ACTION',
                            style: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (projects.isEmpty)
                      const TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: Text(
                              'Aucun projet importé pour le moment.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Color(0xFF64748B),
                              ),
                            ),
                          ),
                          SizedBox(),
                          SizedBox(),
                        ],
                      )
                    else
                      ...projects.take(5).map((p) {
                        final projectId = p['id'].toString();
                        final projectName = p['name'] ?? 'Projet sans nom';
                        final repoUrl = p['repoUrl'] ?? '';

                        return TableRow(
                          decoration: const BoxDecoration(
                            border: Border(
                              bottom: BorderSide(color: Color(0xFFF8FAFC)),
                            ),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              child: Row(
                                children: [
                                  Container(
                                    width: 30,
                                    height: 30,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: const Icon(
                                      Icons.code_rounded,
                                      size: 16,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: Text(
                                      projectName,
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w600,
                                        fontSize: 13,
                                        color: Color(0xFF0F172A),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Text(
                                repoUrl,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF64748B),
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: OutlinedButton(
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 12,
                                      vertical: 6,
                                    ),
                                    minimumSize: const Size(0, 32),
                                    side: const BorderSide(
                                      color: Color(0xFFE2E8F0),
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    backgroundColor: Colors.white,
                                  ),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            ProjectDocumentsScreen(
                                              projectId: projectId,
                                              projectName: projectName,
                                            ),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Explorer',
                                    style: TextStyle(
                                      fontSize: 11.5,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        );
                      }),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 20),

        // Carte des documents types générés
        Expanded(
          flex: 4,
          child: Container(
            padding: const EdgeInsets.all(24),
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
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Documentation prête',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                    Icon(
                      Icons.auto_awesome_rounded,
                      size: 18,
                      color: Color(0xFF64748B),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Synthèses générées automatiquement à chaque analyse de code.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
                const SizedBox(height: 18),
                _buildDocItem(
                  'README & Démarrage',
                  'Structure et prérequis',
                  Icons.description_outlined,
                  const Color(0xFF2563EB),
                  const Color(0xFFDBEAFE),
                ),
                _buildDocItem(
                  'Spécification d\'API',
                  'Endpoints REST & DTOs',
                  Icons.api_rounded,
                  const Color(0xFF059669),
                  const Color(0xFFD1FAE5),
                ),
                _buildDocItem(
                  'Diagrammes PlantUML',
                  'Relations et classes',
                  Icons.account_tree_outlined,
                  const Color(0xFF7C3AED),
                  const Color(0xFFEDE9FE),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDocItem(
    String title,
    String subtitle,
    IconData icon,
    Color iconColor,
    Color bgColor,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: iconColor),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 12.5,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 12,
            color: Color(0xFF94A3B8),
          ),
        ],
      ),
    );
  }
}
