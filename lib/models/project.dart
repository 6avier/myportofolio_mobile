import 'package:json_annotation/json_annotation.dart';

part 'project.g.dart';

/// Portfolio project synchronized with the Django REST Framework API.
///
/// Mirrors `ProjectSerializer` in the Django `myportofolio` repository:
/// `id`, `title`, `role`, `description`, `year`, `github_url`, `demo_url`,
/// plus the read-only `star_count`.
@JsonSerializable(fieldRename: FieldRename.snake)
class Project {
  const Project({
    required this.title,
    required this.role,
    required this.description,
    required this.year,
    this.githubUrl,
    this.demoUrl,
    this.starCount = 0,
    this.id,
  });

  factory Project.fromJson(Map<String, dynamic> json) =>
      _$ProjectFromJson(json);

  /// Assigned by Django, so it is never sent in a POST body.
  @JsonKey(includeToJson: false)
  final int? id;

  final String title;
  final String role;
  final String description;
  final String year;

  /// Optional on the backend (`URLField(blank=True, null=True)`).
  final String? githubUrl;
  final String? demoUrl;

  /// Computed by the server, so it is read-only.
  @JsonKey(includeToJson: false, defaultValue: 0)
  final int starCount;

  Map<String, dynamic> toJson() => _$ProjectToJson(this);
}
