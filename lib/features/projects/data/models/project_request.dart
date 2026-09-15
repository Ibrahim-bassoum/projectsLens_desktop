class ProjectRequest {
  final String name;
  final String repoUrl;
  final String userId; // Ajouté pour correspondre au DTO Java

  ProjectRequest({
    required this.name,
    required this.repoUrl,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {'name': name, 'repoUrl': repoUrl, 'userId': userId};
  }
}
