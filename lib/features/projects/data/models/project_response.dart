class ProjectResponse {
  final String id;
  final String name;
  final String repoUrl;
  final String userId;

  ProjectResponse({
    required this.id,
    required this.name,
    required this.repoUrl,
    required this.userId,
  });

  factory ProjectResponse.fromJson(Map<String, dynamic> json) {
    return ProjectResponse(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      repoUrl: json['repoUrl'] ?? '',
      userId: json['userId'].toString(),
    );
  }
}
