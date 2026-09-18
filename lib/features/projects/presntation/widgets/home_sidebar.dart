import 'package:flutter/material.dart';

class HomeSidebar extends StatelessWidget {
  final String userName;
  final String userEmail;
  final String currentRoute;
  final Function(String) onNavItemSelected;

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
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Color(0xFFE2E8F0), width: 1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 1. Logo & Titre
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 26.0,
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Center(
                    child: Text(
                      'PL',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ProjectLens',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF0F172A),
                        letterSpacing: -0.4,
                      ),
                    ),
                    Text(
                      'Workspace',
                      style: TextStyle(
                        fontSize: 11,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 2. Navigation items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 14.0,
                vertical: 14.0,
              ),
              children: [
                _buildNavItem(
                  icon: Icons.dashboard_outlined,
                  activeIcon: Icons.dashboard_rounded,
                  label: 'Tableau de bord',
                ),
                _buildNavItem(
                  icon: Icons.folder_outlined,
                  activeIcon: Icons.folder_rounded,
                  label: 'Mes projets',
                ),
                _buildNavItem(
                  icon: Icons.upload_file_outlined,
                  activeIcon: Icons.upload_file_rounded,
                  label: 'Importer un projet',
                ),
                _buildNavItem(
                  icon: Icons.analytics_outlined,
                  activeIcon: Icons.analytics_rounded,
                  label: 'Analyses',
                ),
                _buildNavItem(
                  icon: Icons.description_outlined,
                  activeIcon: Icons.description_rounded,
                  label: 'Documentation',
                ),
                _buildNavItem(
                  icon: Icons.account_tree_outlined,
                  activeIcon: Icons.account_tree_rounded,
                  label: 'Diagrammes UML',
                ),
                _buildNavItem(
                  icon: Icons.auto_awesome_outlined,
                  activeIcon: Icons.auto_awesome_rounded,
                  label: 'Assistant IA',
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 10.0,
                  ),
                  child: Divider(color: Color(0xFFF1F5F9), height: 1),
                ),

                _buildNavItem(icon: Icons.history_rounded, label: 'Historique'),
                _buildNavItem(
                  icon: Icons.settings_outlined,
                  activeIcon: Icons.settings_rounded,
                  label: 'Paramètres',
                ),
              ],
            ),
          ),

          const Divider(height: 1, color: Color(0xFFF1F5F9)),

          // 3. Profil utilisateur en bas
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              padding: const EdgeInsets.all(10.0),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 17,
                    backgroundColor: const Color(0xFF0F172A),
                    child: Text(
                      userName.isNotEmpty
                          ? userName.substring(0, 1).toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 13,
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
                            fontWeight: FontWeight.w700,
                            fontSize: 12.5,
                            color: Color(0xFF0F172A),
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          userEmail.isNotEmpty ? userEmail : 'Connecté',
                          style: const TextStyle(
                            color: Color(0xFF64748B),
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
                      size: 17,
                      color: Color(0xFF94A3B8),
                    ),
                    tooltip: 'Se déconnecter',
                    onPressed: () {
                      // Déconnexion
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    IconData? activeIcon,
    required String label,
  }) {
    final bool isSelected = currentRoute == label;

    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF1F5F9) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: ListTile(
        leading: Icon(
          isSelected ? (activeIcon ?? icon) : icon,
          size: 19,
          color: isSelected ? const Color(0xFF0F172A) : const Color(0xFF64748B),
        ),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            fontSize: 13,
            color: isSelected
                ? const Color(0xFF0F172A)
                : const Color(0xFF475569),
          ),
        ),
        dense: true,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        onTap: () => onNavItemSelected(label),
      ),
    );
  }
}
