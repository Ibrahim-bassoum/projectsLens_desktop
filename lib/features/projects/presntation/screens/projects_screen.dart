import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';
import '../../../documents/presentation/screens/project_documents_screen.dart';

class ProjectsScreen extends ConsumerStatefulWidget {
  final VoidCallback? onImportClick;
  const ProjectsScreen({super.key, this.onImportClick});

  @override
  ConsumerState<ProjectsScreen> createState() => _ProjectsScreenState();
}

class _ProjectsScreenState extends ConsumerState<ProjectsScreen> {
  String _searchQuery = '';
  bool _isGridView = true; // Bascule entre Grille et Liste

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. En-tête avec Titre et Bouton Importer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Mes projets',
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF0F172A),
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Gérez vos dépôts analysés, explorez leurs architectures et consultez les synthèses.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),
              ElevatedButton.icon(
                onPressed: widget.onImportClick,
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text(
                  'Importer un projet',
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. Barre d'outils (Recherche + Bascule Grille/Liste)
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44,
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Color(0xFF94A3B8),
                        size: 19,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          onChanged: (val) =>
                              setState(() => _searchQuery = val),
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF0F172A),
                          ),
                          decoration: const InputDecoration(
                            hintText:
                                'Rechercher un projet par nom ou dépôt...',
                            hintStyle: TextStyle(
                              color: Color(0xFF94A3B8),
                              fontSize: 13,
                            ),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchQuery.isNotEmpty)
                        GestureDetector(
                          onTap: () => setState(() => _searchQuery = ''),
                          child: const Icon(
                            Icons.close_rounded,
                            size: 16,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 14),

              // Sélecteur de vue (Grille vs Liste)
              Container(
                height: 44,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: Icon(
                        Icons.grid_view_rounded,
                        size: 18,
                        color: _isGridView
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                      ),
                      tooltip: 'Affichage en grille',
                      onPressed: () => setState(() => _isGridView = true),
                    ),
                    Container(
                      width: 1,
                      height: 20,
                      color: const Color(0xFFE2E8F0),
                    ),
                    IconButton(
                      icon: Icon(
                        Icons.view_list_rounded,
                        size: 20,
                        color: !_isGridView
                            ? const Color(0xFF0F172A)
                            : const Color(0xFF94A3B8),
                      ),
                      tooltip: 'Affichage en tableau',
                      onPressed: () => setState(() => _isGridView = false),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. Contenu principal (AsyncValue avec Grille ou Tableau)
          Expanded(
            child: projectsAsync.when(
              data: (projects) {
                final filtered = projects.where((p) {
                  final name = p['name']?.toLowerCase() ?? '';
                  final repo = p['repoUrl']?.toLowerCase() ?? '';
                  return name.contains(_searchQuery.toLowerCase()) ||
                      repo.contains(_searchQuery.toLowerCase());
                }).toList();

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return _isGridView
                    ? _buildProjectsGrid(filtered)
                    : _buildProjectsTable(filtered);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF0F172A),
                  strokeWidth: 2,
                ),
              ),
              error: (err, stack) => Center(
                child: Text(
                  'Erreur : $err',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 1. Mode Grille (Cartes Bento modernes) ---
  Widget _buildProjectsGrid(List<dynamic> projects) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calcul du nombre de colonnes en fonction de la largeur d'écran
        int crossAxisCount = 3;
        if (constraints.maxWidth < 900) {
          crossAxisCount = 1;
        } else if (constraints.maxWidth < 1300) {
          crossAxisCount = 2;
        }

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 18,
            mainAxisSpacing: 18,
            mainAxisExtent: 220, // Hauteur constante et élégante
          ),
          itemCount: projects.length,
          itemBuilder: (context, index) {
            final project = projects[index];
            final projectId = project['id'].toString();
            final projectName = project['name'] ?? 'Projet sans nom';
            final repoUrl = project['repoUrl'] ?? '';

            return _buildProjectCard(projectId, projectName, repoUrl);
          },
        );
      },
    );
  }

  Widget _buildProjectCard(
    String projectId,
    String projectName,
    String repoUrl,
  ) {
    return Container(
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // En-tête de la carte
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    projectName.isNotEmpty ? projectName[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      projectName,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                        color: Color(0xFF0F172A),
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        const Icon(
                          Icons.link_rounded,
                          size: 13,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            repoUrl.isNotEmpty ? repoUrl : 'Dépôt privé',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Color(0xFF64748B),
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Menu d'options
              PopupMenuButton<String>(
                icon: const Icon(
                  Icons.more_vert_rounded,
                  size: 18,
                  color: Color(0xFF94A3B8),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                onSelected: (val) {
                  if (val == 'delete') _confirmDelete(projectId, projectName);
                },
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'delete',
                    child: Row(
                      children: [
                        Icon(
                          Icons.delete_outline_rounded,
                          size: 16,
                          color: Color(0xFFDC2626),
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Supprimer',
                          style: TextStyle(
                            color: Color(0xFFDC2626),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),

          // Puces de caractéristiques du projet
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFECFDF5),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      size: 12,
                      color: Color(0xFF059669),
                    ),
                    SizedBox(width: 4),
                    Text(
                      'Analysé',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  'UML & Doc prêts',
                  style: TextStyle(
                    color: Color(0xFF475569),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // Bouton d'action "Explorer"
          SizedBox(
            width: double.infinity,
            height: 36,
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDocumentsScreen(
                      projectId: projectId,
                      projectName: projectName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF8FAFC),
                foregroundColor: const Color(0xFF0F172A),
                elevation: 0,
                side: const BorderSide(color: Color(0xFFE2E8F0)),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Afficher la documentation',
                    style: TextStyle(
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: 6),
                  Icon(Icons.arrow_forward_rounded, size: 14),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- 2. Mode Tableau épuré ---
  Widget _buildProjectsTable(List<dynamic> projects) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ListView.separated(
          itemCount: projects.length,
          separatorBuilder: (context, index) =>
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
          itemBuilder: (context, index) {
            final p = projects[index];
            final projectId = p['id'].toString();
            final projectName = p['name'] ?? 'Sans nom';
            final repoUrl = p['repoUrl'] ?? '';

            return ListTile(
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 6,
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => ProjectDocumentsScreen(
                      projectId: projectId,
                      projectName: projectName,
                    ),
                  ),
                );
              },
              leading: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF0F172A),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    projectName.isNotEmpty ? projectName[0].toUpperCase() : 'P',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              title: Text(
                projectName,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              subtitle: Text(
                repoUrl.isNotEmpty ? repoUrl : 'Dépôt privé',
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 11.5,
                ),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFECFDF5),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      'Analysé',
                      style: TextStyle(
                        color: Color(0xFF059669),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  IconButton(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                      size: 18,
                      color: Color(0xFF94A3B8),
                    ),
                    onPressed: () => _confirmDelete(projectId, projectName),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 3. État vide accueillant ---
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.folder_open_rounded,
              size: 28,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun projet trouvé',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _searchQuery.isNotEmpty
                ? 'Aucun projet ne correspond à "$_searchQuery".'
                : 'Commencez par analyser votre premier dépôt Git ou ZIP.',
            style: const TextStyle(color: Color(0xFF64748B), fontSize: 13),
          ),
          if (_searchQuery.isEmpty) ...[
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: widget.onImportClick,
              icon: const Icon(Icons.add_rounded, size: 16),
              label: const Text('Importer un projet'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0F172A),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // Dialogue de confirmation de suppression
  void _confirmDelete(String projectId, String projectName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer le projet',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text(
          'Voulez-vous vraiment supprimer définitivement "$projectName" ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              'Annuler',
              style: TextStyle(color: Color(0xFF64748B)),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(projectProvider.notifier).deleteProject(projectId);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Erreur : $e')));
        }
      }
    }
  }
}
