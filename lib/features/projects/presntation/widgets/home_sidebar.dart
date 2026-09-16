import 'package:flutter/material.dart';

class HomeSidebar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String currentRoute; // Pour gérer l'onglet actif
  final Function(String) onNavItemSelected; // Callback pour changer de page

  const HomeSidebar({
    super.key,
    required this.userName,
    required this.userEmail,
    this.currentRoute = 'Tableau de bord',
    required this.onNavItemSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          right: BorderSide(color: Colors.grey.shade200, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Logo / En-tête
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'P',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'ProjectLens',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
          ),

          // 2. Liste des menus de navigation
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              children: [
                _buildNavItem(
                  icon: Icons.grid_view_rounded,
                  label: 'Tableau de bord',
                ),
                _buildNavItem(
                  icon: Icons.folder_outlined,
                  label: 'Mes projets',
                ),
                _buildNavItem(
                  icon: Icons.upload_file_outlined,
                  label: 'Importer un projet',
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  label: 'Analyses',
                ),
                _buildNavItem(
                  icon: Icons.description_outlined,
                  label: 'Documentation',
                ),
                _buildNavItem(
                  icon: Icons.account_tree_outlined,
                  label: 'Diagrammes UML',
                ),
                _buildNavItem(
                  icon: Icons.auto_awesome_outlined,
                  label: 'Assistant IA',
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12.0),
                  child: Divider(color: Color(0xFFE2E8F0), height: 1),
                ),
                _buildNavItem(
                  icon: Icons.history_outlined,
                  label: 'Historique',
                ),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  label: 'Paramètres',
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFE2E8F0)),

          // 3. Profil utilisateur en bas (identique à la maquette)
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.grey.shade200,
                  child: Text(
                    userName.isNotEmpty
                        ? userName.substring(0, 2).toUpperCase()
                        : 'JD',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
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
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 18,
                    color: Colors.grey,
                  ),
                  onPressed: () {
                    // Action de déconnexion ici
                  },
                  tooltip: 'Déconnexion',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper pour construire chaque ligne de navigation de manière propre
  Widget _buildNavItem({required IconData icon, required String label}) {
    final bool isSelected = currentRoute == label;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          size: 20,
          color: isSelected ? Colors.black : Colors.grey.shade600,
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            fontSize: 13,
            color: isSelected ? Colors.black : Colors.grey.shade700,
          ),
        ),
        dense: true,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        onTap: () => onNavItemSelected(label),
      ),
    );
  }
}
