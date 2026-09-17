import 'package:flutter_riverpod/flutter_riverpod.dart'; // Ajuste le chemin selon ton arborescence
import '../../data/models/generated_document_model.dart';
import '../../../../core/network/api_provider.dart';

// 1. Provider pour récupérer les documents d'un projet de manière réactive
final projectDocumentsProvider =
    FutureProvider.family<List<GeneratedDocument>, String>((
      ref,
      projectId,
    ) async {
      final apiService = ref.watch(apiServiceProvider);
      final data = await apiService.getProjectDocuments(projectId);
      return data.map((json) => GeneratedDocument.fromJson(json)).toList();
    });
