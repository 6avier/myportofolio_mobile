import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';

/// Shows every field of one [Project] from the list screen.
///
/// The Django Project model has no image field, so instead of a project image
/// this screen shows the optional GitHub and demo links only when they exist.
class ProjectDetailScreen extends StatelessWidget {
  const ProjectDetailScreen({required this.project, super.key});

  final Project project;

  @override
  Widget build(BuildContext context) {
    final links = <(IconData, String, String)>[
      if ((project.githubUrl ?? '').isNotEmpty)
        (Icons.code, 'GitHub', project.githubUrl!),
      if ((project.demoUrl ?? '').isNotEmpty)
        (Icons.open_in_new, 'Demo', project.demoUrl!),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(project.title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              project.title,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Chip(
                  avatar: const Icon(Icons.badge_outlined, size: 18),
                  label: Text(project.role),
                ),
                Chip(
                  avatar: const Icon(Icons.calendar_today, size: 18),
                  label: Text(project.year),
                ),
                Chip(
                  avatar: const Icon(Icons.star_outline, size: 18),
                  label: Text('${project.starCount} star'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(project.description),
            if (links.isNotEmpty) ...[
              const SizedBox(height: 16),
              for (final (icon, label, url) in links)
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(icon),
                  title: Text(label),
                  subtitle: SelectableText(url),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
