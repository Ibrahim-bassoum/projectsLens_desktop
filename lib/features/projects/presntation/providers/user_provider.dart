import 'package:flutter_riverpod/flutter_riverpod.dart';
// Importe ton ApiService (adapte le chemin selon ton arborescence)
import '../../../../core/network/api_service.dart';

final apiServiceProvider = Provider<ApiService>((ref) => ApiService());

class UserNotifier extends AsyncNotifier<Map<String, dynamic>> {
  @override
  Future<Map<String, dynamic>> build() async {
    final apiService = ref.read(apiServiceProvider);
    return await apiService.getUserProfile();
  }
}

final userProvider = AsyncNotifierProvider<UserNotifier, Map<String, dynamic>>(
  () => UserNotifier(),
);
