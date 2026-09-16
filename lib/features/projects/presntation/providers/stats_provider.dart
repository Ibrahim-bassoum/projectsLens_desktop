import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart'; // Adapte le chemin selon ton arborescence

// Provider pour l'instance d'ApiService (si ce n'est pas déjà fait)
final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

final statsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final apiService = ref.watch(apiServiceProvider);
  return await apiService.getDashboardStats();
});
