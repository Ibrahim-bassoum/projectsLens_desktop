import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/document_provider.dart';
import '../../../../core/network/api_provider.dart';

class ProjectDocumentsScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectDocumentsScreen({
    super.key,
    required this.projectId,
    required this.projectName,
  });

  @override
  ConsumerState<ProjectDocumentsScreen> createState() =>
      _ProjectDocumentsScreenState();
}

class _ProjectDocumentsScreenState
    extends ConsumerState<ProjectDocumentsScreen> {
  bool isEditing = false;
  bool isGenerating = false;
  late TextEditingController _contentController;
  String? selectedDocId;
  String _docSearchQuery = '';

  @override
  void initState() {
    super.initState();
    _contentController = TextEditingController();
  }

  @override
  void dispose() {
    _contentController.dispose();
    super.dispose();
  }

  // Lancement de la génération via votre API Spring Boot
  Future<void> _generateAnalysis() async {
    setState(() {
      isGenerating = true;
    });

    try {
      await ref
          .read(apiServiceProvider)
          .getArchitectureOverview(widget.projectId);

      ref.invalidate(projectDocumentsProvider(widget.projectId));

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle_rounded, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text('Documentation et analyses générées avec succès !'),
              ],
            ),
            backgroundColor: const Color(0xFF0F172A),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la génération : $e'),
            backgroundColor: const Color(0xFFDC2626),
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Réessayer',
              textColor: Colors.white,
              onPressed: _generateAnalysis,
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isGenerating = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final documentsAsync = ref.watch(
      projectDocumentsProvider(widget.projectId),
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            border: Border(
              bottom: BorderSide(color: Color(0xFFE2E8F0), width: 1),
            ),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Fil d'Ariane / Breadcrumbs
              Row(
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      size: 18,
                      color: Color(0xFF0F172A),
                    ),
                    onPressed: () => Navigator.pop(context),
                    tooltip: 'Retour',
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: const Color(0xFF0F172A),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Center(
                      child: Text(
                        widget.projectName.isNotEmpty
                            ? widget.projectName[0].toUpperCase()
                            : 'P',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Mes projets',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 6),
                    child: Text(
                      '/',
                      style: TextStyle(color: Color(0xFFCBD5E1), fontSize: 13),
                    ),
                  ),
                  Text(
                    widget.projectName,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF0F172A),
                    ),
                  ),
                ],
              ),

              // Actions Header (Régénérer & Rafraîchir)
              Row(
                children: [
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 8,
                      ),
                    ),
                    onPressed: isGenerating ? null : _generateAnalysis,
                    icon: isGenerating
                        ? const SizedBox(
                            width: 14,
                            height: 14,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Color(0xFF0F172A),
                            ),
                          )
                        : const Icon(
                            Icons.auto_awesome_rounded,
                            size: 16,
                            color: Color(0xFF0F172A),
                          ),
                    label: Text(
                      isGenerating ? 'Génération...' : "Générer avec l'IA",
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh_rounded,
                      size: 19,
                      color: Color(0xFF64748B),
                    ),
                    onPressed: () =>
                        ref.refresh(projectDocumentsProvider(widget.projectId)),
                    tooltip: 'Actualiser la documentation',
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      body: documentsAsync.when(
        data: (documents) {
          if (documents.isEmpty) {
            return _buildEmptyState();
          }

          selectedDocId ??= documents.first.id;
          final currentDoc = documents.firstWhere(
            (doc) => doc.id == selectedDocId,
            orElse: () => documents.first,
          );

          if (!isEditing) {
            _contentController.text = currentDoc.content;
          }

          final filteredDocs = documents.where((d) {
            return d.title.toLowerCase().contains(
              _docSearchQuery.toLowerCase(),
            );
          }).toList();

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sidebar des documents
              Container(
                width: 300,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Color(0xFFE2E8F0), width: 1),
                  ),
                ),
                child: Column(
                  children: [
                    // Barre de recherche de document
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Container(
                        height: 38,
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
                              size: 16,
                              color: Color(0xFF94A3B8),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: TextField(
                                onChanged: (val) =>
                                    setState(() => _docSearchQuery = val),
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF0F172A),
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'Filtrer les documents...',
                                  hintStyle: TextStyle(
                                    color: Color(0xFF94A3B8),
                                    fontSize: 12,
                                  ),
                                  border: InputBorder.none,
                                  isDense: true,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const Divider(height: 1, color: Color(0xFFF1F5F9)),

                    // Liste des documents
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 10,
                        ),
                        itemCount: filteredDocs.length,
                        itemBuilder: (context, index) {
                          final doc = filteredDocs[index];
                          final isSelected = doc.id == selectedDocId;
                          final iconData = _getIconForDoc(doc.title);

                          return Container(
                            margin: const EdgeInsets.only(bottom: 4),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? const Color(0xFFF1F5F9)
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: ListTile(
                              dense: true,
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 2,
                              ),
                              leading: Container(
                                padding: const EdgeInsets.all(6),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white
                                      : const Color(0xFFF8FAFC),
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(
                                    color: const Color(0xFFE2E8F0),
                                  ),
                                ),
                                child: Icon(
                                  iconData,
                                  size: 15,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF64748B),
                                ),
                              ),
                              title: Text(
                                doc.title,
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: isSelected
                                      ? const Color(0xFF0F172A)
                                      : const Color(0xFF475569),
                                ),
                              ),
                              trailing: isSelected
                                  ? Container(
                                      width: 6,
                                      height: 6,
                                      decoration: const BoxDecoration(
                                        color: Color(0xFF0F172A),
                                        shape: BoxShape.circle,
                                      ),
                                    )
                                  : null,
                              onTap: () {
                                setState(() {
                                  selectedDocId = doc.id;
                                  isEditing = false;
                                  _contentController.text = doc.content;
                                });
                              },
                            ),
                          );
                        },
                      ),
                    ),

                    // Compteur bas de sidebar
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: const BoxDecoration(
                        border: Border(
                          top: BorderSide(color: Color(0xFFF1F5F9)),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.library_books_outlined,
                            size: 14,
                            color: Color(0xFF94A3B8),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${documents.length} document${documents.length > 1 ? 's' : ''} indexé${documents.length > 1 ? 's' : ''}',
                            style: const TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // 2. Zone de lecture et d'édition principale
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: const Color(0xFFE2E8F0)),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF0F172A,
                          ).withValues(alpha: 0.02),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // En-tête du document
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF1F5F9),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: const Text(
                                        'Markdown • Auto-généré',
                                        style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF475569),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Text(
                                      '~${(currentDoc.content.split(' ').length / 150).ceil()} min de lecture',
                                      style: TextStyle(
                                        fontSize: 11,
                                        color: Colors.grey.shade400,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  currentDoc.title,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.w800,
                                    color: Color(0xFF0F172A),
                                    letterSpacing: -0.4,
                                  ),
                                ),
                              ],
                            ),

                            // Actions sur le document actif
                            Row(
                              children: [
                                if (isEditing) ...[
                                  TextButton(
                                    onPressed: () {
                                      setState(() {
                                        isEditing = false;
                                        _contentController.text =
                                            currentDoc.content;
                                      });
                                    },
                                    child: const Text(
                                      'Annuler',
                                      style: TextStyle(
                                        color: Color(0xFF64748B),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: () async {
                                      try {
                                        await ref
                                            .read(apiServiceProvider)
                                            .updateDocument(
                                              currentDoc.id,
                                              _contentController.text,
                                            );
                                        setState(() => isEditing = false);
                                        ref.invalidate(
                                          projectDocumentsProvider(
                                            widget.projectId,
                                          ),
                                        );
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            const SnackBar(
                                              content: Text(
                                                'Modifications enregistrées !',
                                              ),
                                            ),
                                          );
                                        }
                                      } catch (e) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text('Erreur : $e'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                      }
                                    },
                                    child: const Text(
                                      'Enregistrer',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ] else ...[
                                  // Bouton Copier
                                  IconButton(
                                    icon: const Icon(
                                      Icons.copy_rounded,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                    tooltip: 'Copier le Markdown',
                                    onPressed: () {
                                      Clipboard.setData(
                                        ClipboardData(text: currentDoc.content),
                                      );
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                            'Markdown copié dans le presse-papier !',
                                          ),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    },
                                  ),
                                  // Bouton Modifier
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 18,
                                      color: Color(0xFF64748B),
                                    ),
                                    tooltip: 'Modifier',
                                    onPressed: () =>
                                        setState(() => isEditing = true),
                                  ),
                                  // Bouton Supprimer
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline_rounded,
                                      size: 18,
                                      color: Color(0xFFDC2626),
                                    ),
                                    tooltip: 'Supprimer ce document',
                                    onPressed: () => _confirmDeleteDoc(
                                      currentDoc.id,
                                      currentDoc.title,
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),

                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 20),
                          child: Divider(color: Color(0xFFF1F5F9), height: 1),
                        ),

                        // Zone d'affichage Markdown ou Champ d'édition
                        Expanded(
                          child: isEditing
                              ? Container(
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8FAFC),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: const Color(0xFFE2E8F0),
                                    ),
                                  ),
                                  padding: const EdgeInsets.all(16),
                                  child: TextField(
                                    controller: _contentController,
                                    maxLines: null,
                                    expands: true,
                                    decoration: const InputDecoration(
                                      border: InputBorder.none,
                                      hintText:
                                          'Rédigez ou éditez le contenu en Markdown...',
                                    ),
                                    style: const TextStyle(
                                      fontFamily: 'monospace',
                                      fontSize: 13.5,
                                      height: 1.6,
                                      color: Color(0xFF0F172A),
                                    ),
                                  ),
                                )
                              : SelectionArea(
                                  child: SingleChildScrollView(
                                    child: MarkdownBody(
                                      data: currentDoc.content,
                                      selectable: true,
                                      styleSheet: MarkdownStyleSheet(
                                        h1: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w800,
                                          color: Color(0xFF0F172A),
                                          letterSpacing: -0.4,
                                        ),
                                        h2: const TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.w700,
                                          color: Color(0xFF0F172A),
                                        ),
                                        h3: const TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: Color(0xFF1E293B),
                                        ),
                                        p: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF334155),
                                          height: 1.7,
                                        ),
                                        code: const TextStyle(
                                          backgroundColor: Color(0xFFF1F5F9),
                                          fontFamily: 'monospace',
                                          fontSize: 12.5,
                                          color: Color(0xFF0F172A),
                                        ),
                                        codeblockDecoration: BoxDecoration(
                                          color: const Color(0xFF0F172A),
                                          borderRadius: BorderRadius.circular(
                                            10,
                                          ),
                                        ),
                                        blockquoteDecoration:
                                            const BoxDecoration(
                                              border: Border(
                                                left: BorderSide(
                                                  color: Color(0xFF0F172A),
                                                  width: 3,
                                                ),
                                              ),
                                            ),
                                      ),
                                    ),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF0F172A),
            strokeWidth: 2,
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
                  size: 42,
                  color: Color(0xFFDC2626),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Erreur lors du chargement des documents',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Color(0xFF0F172A),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '$err',
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    fontSize: 13,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 18),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.refresh(projectDocumentsProvider(widget.projectId)),
                  icon: const Icon(Icons.refresh_rounded, size: 16),
                  label: const Text('Réessayer'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0F172A),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // État vide
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.description_outlined,
              size: 30,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 18),
          const Text(
            'Aucun document généré',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Lancez l\'analyse pour générer automatiquement le README, les spécifications et diagrammes.',
            style: TextStyle(fontSize: 13, color: Color(0xFF64748B)),
          ),
          const SizedBox(height: 22),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0F172A),
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: isGenerating ? null : _generateAnalysis,
            icon: isGenerating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.auto_awesome_rounded, size: 16),
            label: Text(
              isGenerating
                  ? 'Génération en cours...'
                  : "Générer la documentation",
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  // Dialogue de confirmation de suppression
  void _confirmDeleteDoc(String docId, String title) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Supprimer le document',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
        ),
        content: Text('Voulez-vous vraiment supprimer "$title" ?'),
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
        await ref.read(apiServiceProvider).deleteDocument(docId);
        setState(() => selectedDocId = null);
        ref.invalidate(projectDocumentsProvider(widget.projectId));
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
          );
        }
      }
    }
  }

  // Attribution d'icônes selon le type de doc
  IconData _getIconForDoc(String title) {
    final t = title.toLowerCase();
    if (t.contains('readme')) return Icons.menu_book_rounded;
    if (t.contains('api') || t.contains('endpoint')) return Icons.api_rounded;
    if (t.contains('diagram') || t.contains('uml') || t.contains('classe'))
      return Icons.account_tree_outlined;
    if (t.contains('archi')) return Icons.hub_outlined;
    return Icons.article_outlined;
  }
}
