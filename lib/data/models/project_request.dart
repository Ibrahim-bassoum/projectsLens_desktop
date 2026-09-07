class ProjectRequest {
  final String repoUrl;
  final String projectName;

  ProjectRequest({required this.repoUrl, required this.projectName});

  Map<String, dynamic> toJson() {
    return {'repoUrl': repoUrl, 'projectName': projectName};
  }
}
