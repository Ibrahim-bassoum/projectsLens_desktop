import 'package:flutter/material.dart';

class AppSidebar extends StatelessWidget {
  final List<dynamic> projects;
  final bool isLoadingProjects;
  final String? errorMessage;
  final String userName;
  final String userEmail;
  final VoidCallback onLogout;
  final Function(dynamic) onProjectTap;

  const AppSidebar({
    super.key,
    required this.projects,
    required this.isLoadingProjects,
    required this.errorMessage,
    required this.userName,
    required this.userEmail,
    required this.onLogout,
    required this.onProjectTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'ProjectLens',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),
          const Divider(height: 1),

          // Menu Items principaux
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
              children: [
                _buildSidebarItem(
                  Icons.dashboard,
                  'Tableau de bord',
                  true,
                  () {},
                ),
                _buildSidebarItem(
                  Icons.folder_outlined,
                  'Mes projets',
                  false,
                  () {},
                ),
                _buildSidebarItem(
                  Icons.upload_file_outlined,
                  'Importer un projet',
                  false,
                  () {},
                ),
                _buildSidebarItem(
                  Icons.analytics_outlined,
                  'Analyses',
                  false,
                  () {},
                ),
                _buildSidebarItem(
                  Icons.description_outlined,
                  'Documentation',
                  false,
                  () {},
                ),
                _buildSidebarItem(
                  Icons.account_tree_outlined,
                  'Diagrammes UML',
                  false,
                  () {},
                ),
                _buildSidebarItem(
                  Icons.auto_awesome_outlined,
                  'Assistant IA',
                  false,
                  () {},
                ),
                _buildSidebarItem(Icons.history, 'Historique', false, () {}),
                _buildSidebarItem(
                  Icons.settings_outlined,
                  'Paramètres',
                  false,
                  () {},
                ),

                const SizedBox(height: 24),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Text(
                    'PROJETS RÉCENTS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),

                // Gestion dynamique des projets récents
                if (isLoadingProjects)
                  const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  )
                else if (errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        color: Colors.red.shade400,
                        fontSize: 12,
                      ),
                    ),
                  )
                else if (projects.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Text(
                      'Aucun projet récent',
                      style: TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  )
                else
                  ...projects.map(
                    (project) => ListTile(
                      dense: true,
                      title: Text(
                        project['name'] ?? 'Projet sans nom',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 13),
                      ),
                      subtitle: Text(
                        project['repoUrl'] ?? '',
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 10,
                          color: Colors.grey,
                        ),
                      ),
                      leading: const Icon(
                        Icons.code,
                        size: 16,
                        color: Colors.black54,
                      ),
                      onTap: () => onProjectTap(project),
                    ),
                  ),
              ],
            ),
          ),

          const Divider(height: 1),
          // Profil utilisateur en bas
          Container(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.black12,
                  child: Text(
                    userName.isNotEmpty ? userName[0].toUpperCase() : 'U',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      Text(
                        userEmail,
                        style: const TextStyle(
                          color: Colors.grey,
                          fontSize: 11,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, size: 18, color: Colors.grey),
                  onPressed: onLogout,
                  tooltip: 'Se déconnecter',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(
    IconData icon,
    String title,
    bool isSelected,
    VoidCallback onTap,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? Colors.black : Colors.grey.shade600,
          size: 20,
        ),
        title: Text(
          title,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.grey.shade700,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
        dense: true,
        onTap: onTap,
      ),
    );
  }
}
