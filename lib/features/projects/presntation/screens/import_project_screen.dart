import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/project_provider.dart';

class ImportProjectScreen extends ConsumerStatefulWidget {
  final VoidCallback? onImportSuccess;

  const ImportProjectScreen({super.key, this.onImportSuccess});

  @override
  ConsumerState<ImportProjectScreen> createState() =>
      _ImportProjectScreenState();
}

class _ImportProjectScreenState extends ConsumerState<ImportProjectScreen> {
  // Onglet actif : 0 = Git, 1 = ZIP
  int _selectedTab = 0;

  // Contrôleurs Git
  final TextEditingController _gitUrlController = TextEditingController();
  final TextEditingController _gitNameController = TextEditingController();

  // Contrôleurs ZIP
  final TextEditingController _zipNameController = TextEditingController();
  String? _selectedZipFileName;

  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _gitUrlController.dispose();
    _gitNameController.dispose();
    _zipNameController.dispose();
    super.dispose();
  }

  // Auto-remplissage du nom à partir de l'URL Git si le nom est vide
  void _onGitUrlChanged(String url) {
    if (_gitNameController.text.isEmpty && url.isNotEmpty) {
      try {
        final uri = Uri.parse(url.trim());
        final segments = uri.pathSegments;
        if (segments.isNotEmpty) {
          String last = segments.last;
          if (last.endsWith('.git')) {
            last = last.substring(0, last.length - 4);
          }
          if (last.isNotEmpty) {
            _gitNameController.text = last;
          }
        }
      } catch (_) {}
    }
  }

  Future<void> _handleGitImport() async {
    setState(() {
      _errorMessage = null;
    });

    final url = _gitUrlController.text.trim();
    final name = _gitNameController.text.trim();

    if (url.isEmpty || name.isEmpty) {
      setState(() {
        _errorMessage =
            'Veuillez renseigner l\'URL du dépôt et le nom du projet.';
      });
      return;
    }

    setState(() => _isLoading = true);

    try {
      await ref.read(projectProvider.notifier).importGit(name, url);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Row(
            children: [
              Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
              SizedBox(width: 10),
              Text('Projet Git importé et analysé avec succès !'),
            ],
          ),
          backgroundColor: const Color(0xFF0F172A),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      );

      widget.onImportSuccess?.call();
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
      });
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleZipImport() async {
    final name = _zipNameController.text.trim();

    if (_selectedZipFileName == null || name.isEmpty) {
      setState(() {
        _errorMessage =
            'Veuillez sélectionner une archive ZIP et renseigner un nom.';
      });
      return;
    }

    setState(() => _isLoading = true);
    // Simulation ou endpoint upload zip
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      setState(() => _isLoading = false);
      widget.onImportSuccess?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 36.0, vertical: 32.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // En-tête de la page
          const Text(
            'Importer un projet',
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w800,
              color: Color(0xFF0F172A),
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Connectez un dépôt Git distant ou chargez une archive locale pour lancer l\'analyse logicielle.',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
          ),
          const SizedBox(height: 28),

          // Sélecteur d'onglets (Dépôt Git vs Archive ZIP)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTabButton(0, Icons.code_rounded, 'Dépôt Git'),
                _buildTabButton(1, Icons.folder_zip_outlined, 'Archive ZIP'),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Contenu principal : Formulaire à gauche + Guide/Aide à droite
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Formulaire principal
              Expanded(
                flex: 7,
                child: Container(
                  padding: const EdgeInsets.all(28),
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
                  child: _selectedTab == 0 ? _buildGitForm() : _buildZipForm(),
                ),
              ),
              const SizedBox(width: 24),

              // Panneau latéral d'aide et bonnes pratiques
              Expanded(flex: 4, child: _buildSideGuidePanel()),
            ],
          ),
        ],
      ),
    );
  }

  // --- 1. Formulaire Git épuré ---
  Widget _buildGitForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.link_rounded,
                size: 18,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cloner un dépôt Git public',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Compatible avec GitHub, GitLab, Bitbucket ou tout serveur Git standard.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Message d'erreur
        if (_errorMessage != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFEF2F2),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFFECACA)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.error_outline_rounded,
                  size: 16,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(
                      color: Color(0xFFDC2626),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
        ],

        // Champ URL du dépôt
        const Text(
          'URL du dépôt Git *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _gitUrlController,
          onChanged: _onGitUrlChanged,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'https://github.com/organisation/projet.git',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(
              Icons.link_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),

        // Champ Nom du projet
        const Text(
          'Nom du projet *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _gitNameController,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'ex. ProjectLens Core Backend',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(
              Icons.drive_file_rename_outline_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        // Bouton de lancement
        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isLoading ? null : _handleGitImport,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Lancer l\'import et l\'analyse',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // --- 2. Formulaire ZIP ---
  Widget _buildZipForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.folder_zip_outlined,
                size: 18,
                color: Color(0xFF0F172A),
              ),
            ),
            const SizedBox(width: 12),
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Téléverser une archive de code',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                    color: Color(0xFF0F172A),
                  ),
                ),
                Text(
                  'Compressez la racine de votre projet au format standard .zip.',
                  style: TextStyle(fontSize: 12, color: Color(0xFF64748B)),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Zone de drag and drop / upload
        InkWell(
          onTap: () {
            setState(() {
              _selectedZipFileName = 'project_source_archive.zip';
              if (_zipNameController.text.isEmpty) {
                _zipNameController.text = 'MonProjetZip';
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: const Color(0xFFF8FAFC),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFFCBD5E1),
                style: BorderStyle.solid,
              ),
            ),
            child: Column(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: const Color(0xFFE2E8F0)),
                  ),
                  child: const Icon(
                    Icons.cloud_upload_outlined,
                    size: 22,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _selectedZipFileName ??
                      'Cliquez pour sélectionner votre fichier .ZIP',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Taille maximale recommandée : 100 Mo',
                  style: TextStyle(fontSize: 11, color: Color(0xFF94A3B8)),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 20),

        // Nom du projet pour le zip
        const Text(
          'Nom du projet *',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1E293B),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _zipNameController,
          style: const TextStyle(fontSize: 13, color: Color(0xFF0F172A)),
          decoration: InputDecoration(
            hintText: 'ex. Mon Projet Local',
            hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 13),
            prefixIcon: const Icon(
              Icons.drive_file_rename_outline_rounded,
              size: 18,
              color: Color(0xFF94A3B8),
            ),
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding: const EdgeInsets.symmetric(
              vertical: 14,
              horizontal: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFF0F172A),
                width: 1.5,
              ),
            ),
          ),
        ),
        const SizedBox(height: 28),

        SizedBox(
          width: double.infinity,
          height: 46,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: _isLoading ? null : _handleZipImport,
            child: _isLoading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Téléverser et analyser l\'archive',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      SizedBox(width: 8),
                      Icon(
                        Icons.arrow_forward_rounded,
                        size: 16,
                        color: Colors.white,
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  // --- 3. Panneau latéral d'aide ---
  Widget _buildSideGuidePanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 17,
                color: Color(0xFF0F172A),
              ),
              SizedBox(width: 8),
              Text(
                'Ce qui sera extrait',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                  color: Color(0xFF0F172A),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _buildGuideItem(
            Icons.schema_outlined,
            'Architecture & Arborescence',
            'Détection des dossiers src, modules et dépendances.',
          ),
          const SizedBox(height: 12),
          _buildGuideItem(
            Icons.data_object_rounded,
            'Analyse AST Tree-Sitter',
            'Extraction des classes, méthodes, interfaces et DTOs.',
          ),
          const SizedBox(height: 12),
          _buildGuideItem(
            Icons.description_outlined,
            'Synthèse IA',
            'Création d\'un README standardisé et spécification d\'API.',
          ),
          const Divider(height: 32, color: Color(0xFFF1F5F9)),
          const Row(
            children: [
              Icon(Icons.shield_outlined, size: 15, color: Color(0xFF059669)),
              SizedBox(width: 6),
              Text(
                'Confidentialité du code garantie',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF059669),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Vos sources restent stockées en local et ne sont partagées avec aucun tiers non autorisé.',
            style: TextStyle(
              fontSize: 11,
              color: Color(0xFF64748B),
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGuideItem(IconData icon, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Icon(icon, size: 14, color: const Color(0xFF0F172A)),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 12.5,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(
                  fontSize: 11,
                  color: Color(0xFF64748B),
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTabButton(int index, IconData icon, String label) {
    final isSelected = _selectedTab == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTab = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 16,
              color: isSelected
                  ? const Color(0xFF0F172A)
                  : const Color(0xFF64748B),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
