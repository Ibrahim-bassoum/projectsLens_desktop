import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // Helper pour récupérer le token JWT stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ==================== 1. AUTHENTIFICATION ====================

  Future<bool> register(String name, String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'name': name, 'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception(
        response.body.isNotEmpty ? response.body : 'Erreur d\'inscription',
      );
    }
  }

  Future<String> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('jwt_token', token);

      return token;
    } else {
      throw Exception('Identifiants invalides');
    }
  }

  // ==================== 2. PROJETS & UPLOAD ====================

  Future<List<dynamic>> getUserProjects() async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$baseUrl/projects'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossible de charger les projets');
    }
  }

  Future<dynamic> importGitProject(String name, String repoUrl) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.post(
      Uri.parse(
        '$baseUrl/projects/import-git?name=${Uri.encodeComponent(name)}&repoUrl=${Uri.encodeComponent(repoUrl)}',
      ),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur import Git : ${response.body}');
    }
  }

  Future<void> deleteProject(String projectId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.delete(
      Uri.parse('$baseUrl/projects/$projectId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur suppression : ${response.body}');
    }
  }

  // ==================== 3. ANALYSE TREE-SITTER ====================

  Future<String> analyzeProject(String projectId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.post(
      Uri.parse('$baseUrl/treesitter/projects/$projectId/analyze'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Erreur lors de l\'analyse AST : ${response.body}');
    }
  }

  // ==================== 4. ANALYSE IA (GEMINI) ====================

  Future<String> getArchitectureOverview(String projectId) async {
    final token = await _getToken();
    if (token == null) throw Exception('Non authentifié');

    final response = await http.get(
      Uri.parse('$baseUrl/ai/architecture/$projectId'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception(
        'Erreur lors de la génération de l\'analyse IA : ${response.body}',
      );
    }
  }
}
