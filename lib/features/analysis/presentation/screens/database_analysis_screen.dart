import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../projects/presntation/providers/project_provider.dart';
import '../providers/database_analysis_provider.dart';
import '../widgets/entity_card.dart';
import '../widgets/mermaid_code_view.dart';
import '../widgets/mermaid_graph_view.dart';

class DatabaseAnalysisScreen extends ConsumerStatefulWidget {
  final String? initialProjectId;
  final String? initialProjectName;

  const DatabaseAnalysisScreen({
    super.key,
    this.initialProjectId,
    this.initialProjectName,
  });

  @override
  ConsumerState<DatabaseAnalysisScreen> createState() =>
      _DatabaseAnalysisScreenState();
}

class _DatabaseAnalysisScreenState extends ConsumerState<DatabaseAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String? _selectedProjectId;
  String? _selectedProjectName;
  String _searchTableQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _selectedProjectId = widget.initialProjectId;
    _selectedProjectName = widget.initialProjectName;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _triggerRefresh(String projectId) {
    ref
        .read(databaseAnalysisNotifierProvider(projectId).notifier)
        .loadSchema(refresh: true);
  }

  @override
  Widget build(BuildContext context) {
    final projectsAsync = ref.watch(projectProvider);
    final projects = projectsAsync.asData?.value ?? [];

    // Si aucun projet n'est explicitement sélectionné, prendre le premier disponible
    if (_selectedProjectId == null && projects.isNotEmpty) {
      _selectedProjectId = projects.first['id'].toString();
      _selectedProjectName = projects.first['name'] ?? 'Projet';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 28.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. En-tête avec Titre, Sélecteur de projet et Actions
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: const Color(0xFF0F172A),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.account_tree_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Schéma de Base de Données',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF0F172A),
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Rétro-ingénierie automatique des entités, relations et diagrammes UML.',
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
                  ),
                ],
              ),

              // Sélecteur de Projet + Bouton Rafraîchir
              Row(
                children: [
                  if (projects.isNotEmpty) ...[
                    Container(
                      height: 40,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedProjectId,
                          icon: const Icon(
                            Icons.keyboard_arrow_down_rounded,
                            size: 18,
                            color: Color(0xFF64748B),
                          ),
                          items: projects.map<DropdownMenuItem<String>>((p) {
                            final id = p['id'].toString();
                            final name = p['name'] ?? 'Projet';
                            return DropdownMenuItem<String>(
                              value: id,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.folder_outlined,
                                    size: 14,
                                    color: Color(0xFF64748B),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                          onChanged: (newId) {
                            if (newId != null) {
                              final proj = projects.firstWhere(
                                (p) => p['id'].toString() == newId,
                                orElse: () => null,
                              );
                              setState(() {
                                _selectedProjectId = newId;
                                _selectedProjectName = proj?['name'];
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                  ],

                  if (_selectedProjectId != null)
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0F172A),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => _triggerRefresh(_selectedProjectId!),
                      icon: const Icon(Icons.auto_awesome_rounded, size: 15),
                      label: const Text(
                        'Régénérer avec l\'IA',
                        style: TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),

          // 2. Si aucun projet n'existe dans l'espace de travail
          if (_selectedProjectId == null)
            Expanded(child: _buildNoProjectView())
          else
            Expanded(child: _buildProjectSchemaView(_selectedProjectId!)),
        ],
      ),
    );
  }

  Widget _buildNoProjectView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.account_tree_outlined,
              size: 40,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun projet disponible',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Veuillez importer un projet Git ou ZIP pour visualiser son schéma de données.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildProjectSchemaView(String projectId) {
    final analysisState = ref.watch(
      databaseAnalysisNotifierProvider(projectId),
    );

    return analysisState.when(
      data: (schema) {
        final filteredEntities = schema.entities.where((e) {
          final query = _searchTableQuery.toLowerCase();
          final matchesTable = e.name.toLowerCase().contains(query);
          final matchesAttribute = e.attributes.any(
            (a) => a.name.toLowerCase().contains(query),
          );
          return matchesTable || matchesAttribute;
        }).toList();

        return Column(
          children: [
            // Barre de statistiques & Onglets
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  // Onglets
                  Container(
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(3),
                    child: TabBar(
                      controller: _tabController,
                      isScrollable: true,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: Colors.transparent,
                      labelColor: const Color(0xFF0F172A),
                      unselectedLabelColor: const Color(0xFF64748B),
                      indicator: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 4,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      labelStyle: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                      tabs: const [
                        Tab(text: 'Schéma Relationnel'),
                        Tab(text: 'Diagramme Graphique'),
                        Tab(text: 'Code Mermaid'),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Statistiques
                  _buildStatBadge(
                    '${schema.totalTables}',
                    'Tables',
                    Icons.table_chart_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    '${schema.totalAttributes}',
                    'Colonnes',
                    Icons.view_column_rounded,
                  ),
                  const SizedBox(width: 8),
                  _buildStatBadge(
                    '${schema.totalRelationships}',
                    'Relations',
                    Icons.timeline_rounded,
                  ),
                  const SizedBox(width: 16),

                  // Barre de recherche de table
                  Container(
                    width: 200,
                    height: 36,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.search_rounded,
                          size: 15,
                          color: Color(0xFF94A3B8),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: TextField(
                            onChanged: (val) =>
                                setState(() => _searchTableQuery = val),
                            style: const TextStyle(fontSize: 12),
                            decoration: const InputDecoration(
                              hintText: 'Filtrer table / colonne...',
                              hintStyle: TextStyle(
                                fontSize: 12,
                                color: Color(0xFF94A3B8),
                              ),
                              border: InputBorder.none,
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // Contenu de l'onglet
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Onglet 1 : Grille des Entités
                  filteredEntities.isEmpty
                      ? _buildEmptyEntitiesView(schema.entities.isNotEmpty)
                      : LayoutBuilder(
                          builder: (context, constraints) {
                            int crossAxisCount = 3;
                            if (constraints.maxWidth < 950) {
                              crossAxisCount = 1;
                            } else if (constraints.maxWidth < 1350) {
                              crossAxisCount = 2;
                            }

                            return GridView.builder(
                              padding: const EdgeInsets.only(bottom: 24),
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: crossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    mainAxisExtent: 320,
                                  ),
                              itemCount: filteredEntities.length,
                              itemBuilder: (context, index) {
                                return EntityCard(
                                  entity: filteredEntities[index],
                                  searchQuery: _searchTableQuery,
                                );
                              },
                            );
                          },
                        ),

                  // Onglet 2 : Rendu Graphique
                  MermaidGraphView(mermaidCode: schema.rawMermaid),

                  // Onglet 3 : Code Mermaid brut
                  MermaidCodeView(mermaidCode: schema.rawMermaid),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            CircularProgressIndicator(
              color: Color(0xFF0F172A),
              strokeWidth: 2.5,
            ),
            SizedBox(height: 16),
            Text(
              'Analyse des modèles de base de données par l\'IA...',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 15,
                color: Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Extraction des entités JPA, schémas SQL, Prisma et déduction des cardinalités.',
              style: TextStyle(fontSize: 12.5, color: Color(0xFF64748B)),
            ),
          ],
        ),
      ),
      error: (err, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: Color(0xFFDC2626),
              ),
              const SizedBox(height: 14),
              const Text(
                'Échec de l\'analyse de la base de données',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 6),
              Text(
                '$err',
                style: const TextStyle(fontSize: 13, color: Color(0xFF64748B)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 18),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0F172A),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () => _triggerRefresh(projectId),
                icon: const Icon(Icons.refresh_rounded, size: 16),
                label: const Text('Réessayer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatBadge(String count, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: const Color(0xFF0F172A)),
          const SizedBox(width: 6),
          Text(
            count,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyEntitiesView(bool hadEntitiesInitially) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.search_off_rounded,
            size: 36,
            color: Color(0xFF94A3B8),
          ),
          const SizedBox(height: 12),
          Text(
            hadEntitiesInitially
                ? 'Aucune table ne correspond au filtre "$_searchTableQuery".'
                : 'Aucune table explicite n\'a été isolée dans le code.',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Consultez l\'onglet "Code Mermaid" pour voir la synthèse générée.',
            style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
          ),
        ],
      ),
    );
  }
}
