import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/models/project.dart';
import 'package:myportofolio_mobile/services/api_client.dart';
import 'package:myportofolio_mobile/services/auth_state.dart';
import 'package:myportofolio_mobile/widgets/auth_guard.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';
import 'package:provider/provider.dart';

/// Formulir tambah proyek yang mengirim `POST /api/v1/projects/` dengan token.
///
/// Field-nya mengikuti `ProjectSerializer` di backend Django: title, role,
/// description, year, github_url, dan demo_url.
class ProjectFormPage extends StatefulWidget {
  const ProjectFormPage({super.key});

  @override
  State<ProjectFormPage> createState() => _ProjectFormPageState();
}

class _ProjectFormPageState extends State<ProjectFormPage> {
  // Kunci untuk mengakses FormState: validasi dan reset form.
  final _formKey = GlobalKey<FormState>();
  String _title = "";
  String _role = "";
  String _description = "";
  String _year = "";
  String _githubUrl = "";
  String _demoUrl = "";
  bool _isSubmitting = false;

  /// Batas panjang sesuai model Django (`max_length`).
  static const int titleMaxLength = 255;
  static const int roleMaxLength = 255;
  static const int yearMaxLength = 20;

  static String? _required(String? value, String message) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  /// URL boleh kosong, tetapi jika diisi harus http/https lengkap dengan host.
  static String? validateOptionalUrl(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isWebUrl =
        uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    return isWebUrl ? null : "URL harus diawali http:// atau https://";
  }

  static String? _orNull(String value) =>
      value.trim().isEmpty ? null : value.trim();

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    // Pastikan sudah login; kalau belum, LoginScreen dibuka dulu.
    if (!await ensureLoggedIn(context)) return;
    if (!mounted) return;

    final token = context.read<AuthState>().token!;
    final newProject = Project(
      title: _title.trim(),
      role: _role.trim(),
      description: _description.trim(),
      year: _year.trim(),
      githubUrl: _orNull(_githubUrl),
      demoUrl: _orNull(_demoUrl),
    );

    setState(() => _isSubmitting = true);
    try {
      final created = await context.read<ApiClient>().createProject(
        newProject,
        token: token,
      );
      if (!mounted) return;
      _showCreatedDialog(created);
    } on ApiException catch (error) {
      if (!mounted) return;
      if (error.statusCode == 401) {
        // Token sudah tidak berlaku: buang token lalu minta login ulang.
        await context.read<AuthState>().logout();
        if (!mounted) return;
        _showSnackBar('Sesi login berakhir, silakan login lagi lalu simpan.');
        await ensureLoggedIn(context);
      } else {
        _showSnackBar('Gagal menyimpan proyek: ${error.userMessage}');
      }
    } catch (_) {
      if (mounted) {
        _showSnackBar(
          'Gagal menyimpan proyek: tidak bisa terhubung ke server.',
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _showCreatedDialog(Project project) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Proyek berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('ID: ${project.id}'),
                Text('Judul: ${project.title}'),
                Text('Peran: ${project.role}'),
                Text('Deskripsi: ${project.description}'),
                Text('Tahun: ${project.year}'),
                Text('GitHub: ${project.githubUrl ?? '-'}'),
                Text('Demo: ${project.demoUrl ?? '-'}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                Navigator.pop(context);
                _resetForm();
              },
            ),
          ],
        );
      },
    );
  }

  void _resetForm() {
    _formKey.currentState!.reset();
    setState(() {
      _title = "";
      _role = "";
      _description = "";
      _year = "";
      _githubUrl = "";
      _demoUrl = "";
    });
  }

  InputDecoration _decoration(String label, {String? hint}) {
    return InputDecoration(
      hintText: hint ?? label,
      labelText: label,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(5.0)),
    );
  }

  Widget _field({required Widget child}) =>
      Padding(padding: const EdgeInsets.all(8.0), child: child);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Center(child: Text('Add Project Form')),
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Title ===
              _field(
                child: TextFormField(
                  decoration: _decoration("Title"),
                  maxLength: titleMaxLength,
                  onChanged: (value) => setState(() => _title = value),
                  validator: (value) =>
                      _required(value, "Title tidak boleh kosong!"),
                ),
              ),
              // === Role ===
              _field(
                child: TextFormField(
                  decoration: _decoration(
                    "Role",
                    hint: "Contoh: Full-stack developer",
                  ),
                  maxLength: roleMaxLength,
                  onChanged: (value) => setState(() => _role = value),
                  validator: (value) =>
                      _required(value, "Role tidak boleh kosong!"),
                ),
              ),
              // === Description ===
              _field(
                child: TextFormField(
                  maxLines: 5,
                  decoration: _decoration("Description"),
                  onChanged: (value) => setState(() => _description = value),
                  validator: (value) =>
                      _required(value, "Description tidak boleh kosong!"),
                ),
              ),
              // === Year ===
              _field(
                child: TextFormField(
                  decoration: _decoration("Year", hint: "Contoh: 2026"),
                  maxLength: yearMaxLength,
                  onChanged: (value) => setState(() => _year = value),
                  validator: (value) =>
                      _required(value, "Year tidak boleh kosong!"),
                ),
              ),
              // === GitHub URL ===
              _field(
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "GitHub URL (opsional)",
                    hint: "https://github.com/...",
                  ),
                  onChanged: (value) => setState(() => _githubUrl = value),
                  validator: validateOptionalUrl,
                ),
              ),
              // === Demo URL ===
              _field(
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Demo URL (opsional)",
                    hint: "https://...",
                  ),
                  onChanged: (value) => setState(() => _demoUrl = value),
                  validator: validateOptionalUrl,
                ),
              ),
              // === Tombol Simpan ===
              Align(
                alignment: Alignment.bottomCenter,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colorScheme.primary,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: _isSubmitting ? null : _submit,
                    child: _isSubmitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Save"),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
