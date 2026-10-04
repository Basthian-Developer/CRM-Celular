class Project {
  const Project({
    required this.id,
    required this.createdAt,
    this.name,
    this.description,
    this.tags,
    required this.githubUrl,
    this.demoUrl,
    this.featured,
    this.isActive,
  });

  factory Project.fromJson(Map<String, dynamic> json) {
    return Project(
      id: _asInt(json['id']),
      createdAt: json['created_at']?.toString() ?? '',
      name: json['nombre']?.toString(),
      description: json['descripcion']?.toString(),
      tags: (json['tags'] as List<dynamic>?)?.map((tag) => tag.toString()).toList(),
      githubUrl: json['github_url']?.toString() ?? '',
      demoUrl: json['demo_url']?.toString(),
      featured: _asBool(json['destacado'] ?? json['featured'] ?? json['is_featured']),
      isActive: _asBool(json['estado'] ?? json['active'] ?? json['is_active']),
    );
  }

  final int id;
  final String createdAt;
  final String? name;
  final String? description;
  final List<String>? tags;
  final String githubUrl;
  final String? demoUrl;
  final bool? featured;
  final bool? isActive;

  static int _asInt(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;

  static bool? _asBool(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is num) return value != 0;
    final normalized = value.toString().trim().toLowerCase();
    if (normalized == 'true' || normalized == '1' || normalized == 't') return true;
    if (normalized == 'false' || normalized == '0' || normalized == 'f') return false;
    return null;
  }
}
