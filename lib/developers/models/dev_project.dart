
class DevProject {
  final String id;
  final String slug;
  final String name;
  final String? description;

  DevProject({
    required this.id,
    required this.slug,
    required this.name,
    this.description,
  });

  factory DevProject.fromJson(Map<String, dynamic> json) {
    return DevProject(
      id: json['id'],
      slug: json['slug'],
      name: json['name'],
      description: json['description'],
    );
  }
}
