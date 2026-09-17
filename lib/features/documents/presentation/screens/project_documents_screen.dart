import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import '../providers/document_provider.dart';
import '../../../../core/network/api_provider.dart';

class ProjectDocumentsScreen extends ConsumerStatefulWidget {
  final String projectId;
  final String projectName;

  const ProjectDocumentsScreen({
    Key? key,
    required this.projectId,
    required this.projectName,
  }) : super(key: key);

  @override
  ConsumerState<ProjectDocumentsScreen> createState() =>
      _ProjectDocumentsScreenState();
}

class _ProjectDocumentsScreenState
    extends ConsumerState<ProjectDocumentsScreen> {
  bool isEditing = false;
  bool isGenerating = false; // <--- Indicateur de chargement pour la génération
  late TextEditingController _contentController;
  String? selectedDocId;

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

  // Méthode mutualisée pour lancer la génération avec gestion du loader et des erreurs
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
          const SnackBar(
            content: Text('Analyse générée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        // Affichage d'une erreur détaillée avec une SnackBar interactive ou rouge
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Échec de la génération : $e'),
            backgroundColor: Colors.red.shade700,
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
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: AppBar(
        title: Text(
          'Documentation - ${widget.projectName}',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                ref.refresh(projectDocumentsProvider(widget.projectId)),
            tooltip: 'Rafraîchir',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: documentsAsync.when(
        data: (documents) {
          if (documents.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.description_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Aucun document généré pour le moment.',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: isGenerating ? null : _generateAnalysis,
                    icon: isGenerating
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.auto_awesome, size: 18),
                    label: Text(
                      isGenerating
                          ? 'Génération en cours...'
                          : "Générer l'analyse",
                    ),
                  ),
                ],
              ),
            );
          }

          selectedDocId ??= documents.first.id;
          final currentDoc = documents.firstWhere(
            (doc) => doc.id == selectedDocId,
            orElse: () => documents.first,
          );

          if (!isEditing) {
            _contentController.text = currentDoc.content;
          }

          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Sidebar des documents
              Container(
                width: 280,
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border(
                    right: BorderSide(color: Colors.grey.withOpacity(0.2)),
                  ),
                ),
                child: ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: documents.length,
                  itemBuilder: (context, index) {
                    final doc = documents[index];
                    final isSelected = doc.id == selectedDocId;
                    return Container(
                      margin: const EdgeInsets.only(bottom: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.grey.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ListTile(
                        leading: Icon(
                          Icons.article_outlined,
                          size: 20,
                          color: isSelected ? Colors.black : Colors.grey,
                        ),
                        title: Text(
                          doc.title,
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.w500,
                            color: isSelected ? Colors.black : Colors.black87,
                          ),
                        ),
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

              // 2. Zone de contenu principale
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.withOpacity(0.2)),
                    ),
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              currentDoc.title,
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
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
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Modifications enregistrées !',
                                            ),
                                          ),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text('Erreur : $e'),
                                            backgroundColor: Colors.red,
                                          ),
                                        );
                                      }
                                    },
                                    child: const Text('Enregistrer'),
                                  ),
                                ] else ...[
                                  IconButton(
                                    icon: const Icon(
                                      Icons.edit_outlined,
                                      size: 20,
                                    ),
                                    tooltip: 'Modifier',
                                    onPressed: () =>
                                        setState(() => isEditing = true),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.delete_outline,
                                      size: 20,
                                      color: Colors.redAccent,
                                    ),
                                    tooltip: 'Supprimer',
                                    onPressed: () async {
                                      final confirm = await showDialog<bool>(
                                        context: context,
                                        builder: (context) => AlertDialog(
                                          title: const Text(
                                            'Confirmer la suppression',
                                          ),
                                          content: Text(
                                            'Voulez-vous supprimer "${currentDoc.title}" ?',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, false),
                                              child: const Text('Annuler'),
                                            ),
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context, true),
                                              child: const Text(
                                                'Supprimer',
                                                style: TextStyle(
                                                  color: Colors.red,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      );

                                      if (confirm == true) {
                                        try {
                                          await ref
                                              .read(apiServiceProvider)
                                              .deleteDocument(currentDoc.id);
                                          setState(() => selectedDocId = null);
                                          ref.invalidate(
                                            projectDocumentsProvider(
                                              widget.projectId,
                                            ),
                                          );
                                        } catch (e) {
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
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Affichage du Markdown ou du champ de texte
                        Expanded(
                          child: isEditing
                              ? TextField(
                                  controller: _contentController,
                                  maxLines: null,
                                  expands: true,
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                    hintText: 'Modifier le contenu Markdown...',
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'monospace',
                                    fontSize: 13,
                                  ),
                                )
                              : SingleChildScrollView(
                                  child: MarkdownBody(
                                    data: currentDoc.content,
                                    selectable: true,
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
        loading: () =>
            const Center(child: CircularProgressIndicator(color: Colors.black)),
        error: (err, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(
                  'Une erreur est survenue lors du chargement des documents.',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  '$err',
                  style: const TextStyle(color: Colors.grey, fontSize: 13),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () =>
                      ref.refresh(projectDocumentsProvider(widget.projectId)),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Réessayer'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
