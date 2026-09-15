import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_service.dart';

// Provider pour accéder à l'ApiService via les features
final _apiProvider = Provider<ApiService>((ref) => ApiService());

// StateNotifier pour gérer les projets de l'utilisateur
class ProjectNotifier extends AsyncNotifier<List<dynamic>> {
  @override
  Future<List<dynamic>> build() async {
    return _fetchProjects();
  }

  Future<List<dynamic>> _fetchProjects() async {
    final apiService = ref.read(_apiProvider);
    return await apiService.getUserProjects();
  }

  // Importer un projet Git et rafraîchir la liste automatiquement
  Future<void> importGit(String name, String repoUrl) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final apiService = ref.read(_apiProvider);
      await apiService.importGitProject(name, repoUrl);
      return await apiService.getUserProjects();
    });
  }

  // Supprimer un projet et rafraîchir la liste
  Future<void> deleteProject(String projectId) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final apiService = ref.read(_apiProvider);
      await apiService.deleteProject(projectId);
      return await apiService.getUserProjects();
    });
  }
}

// Le provider global pour écouter la liste des projets dans l'UI
final projectProvider = AsyncNotifierProvider<ProjectNotifier, List<dynamic>>(
  () {
    return ProjectNotifier();
  },
);
