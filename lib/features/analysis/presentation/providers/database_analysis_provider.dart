import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_provider.dart';
import '../../domain/models/database_schema_model.dart';

/// Notifier pour charger et régénérer le schéma de base de données
class DatabaseAnalysisNotifier
    extends StateNotifier<AsyncValue<DatabaseSchema>> {
  final Ref _ref;
  final String projectId;

  DatabaseAnalysisNotifier({required Ref ref, required this.projectId})
    : _ref = ref,
      super(const AsyncValue.loading()) {
    loadSchema(refresh: false);
  }

  /// Charge ou régénère le schéma UML/Mermaid via l'API
  Future<void> loadSchema({bool refresh = false}) async {
    state = const AsyncValue.loading();
    try {
      final apiService = _ref.read(apiServiceProvider);
      final rawMermaid = await apiService.getDatabaseUmlDiagram(
        projectId,
        refresh: refresh,
      );
      final schema = DatabaseSchema.fromMermaid(rawMermaid);
      state = AsyncValue.data(schema);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider unique pour l'analyse de la base de données
final databaseAnalysisNotifierProvider =
    StateNotifierProvider.family<
      DatabaseAnalysisNotifier,
      AsyncValue<DatabaseSchema>,
      String
    >((ref, projectId) {
      return DatabaseAnalysisNotifier(ref: ref, projectId: projectId);
    });
