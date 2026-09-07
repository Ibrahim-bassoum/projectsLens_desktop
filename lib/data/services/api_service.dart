import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080/api';

  // Connexion
  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final userData = jsonDecode(response.body);
      // Sauvegarder l'ID utilisateur localement en tant que String
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userId', userData['id'].toString());
      await prefs.setString('userName', userData['name'] ?? '');
      return userData;
    } else {
      throw Exception('Email ou mot de passe incorrect');
    }
  }

  // Récupérer les projets de l'utilisateur connecté
  static Future<List<dynamic>> getUserProjects() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) throw Exception('Utilisateur non connecté');

    final response = await http.get(
      Uri.parse('$baseUrl/projects/user/$userId'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Impossible de charger vos projets');
    }
  }

  // Analyser un dépôt lié à l'utilisateur
  static Future<String> analyzeRepository(
    String repoUrl,
    String projectName,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('userId');

    if (userId == null) throw Exception('Utilisateur non connecté');

    final response = await http.post(
      Uri.parse(
        '$baseUrl/projects/analyze-github?repoUrl=$repoUrl&projectName=$projectName&userId=$userId',
      ),
    );

    if (response.statusCode == 200) {
      return response.body;
    } else {
      throw Exception('Erreur lors de l\'analyse : ${response.body}');
    }
  }
}
