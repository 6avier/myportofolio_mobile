import 'package:material_ui/material_ui.dart';
import 'package:myportofolio_mobile/widgets/left_drawer.dart';

/// Formulir untuk menambah pengalaman (Experience) ke portofolio.
///
/// Field-nya mengikuti model `Experience` di backend Django: judul, deskripsi,
/// kategori, thumbnail (URL), serta tanggal mulai dan selesai.
class ExperienceFormPage extends StatefulWidget {
  const ExperienceFormPage({super.key});

  @override
  State<ExperienceFormPage> createState() => _ExperienceFormPageState();
}

class _ExperienceFormPageState extends State<ExperienceFormPage> {
  final _formKey = GlobalKey<FormState>();

  /// Batas panjang judul, sama dengan `max_length=255` pada model Django.
  static const int titleMaxLength = 255;

  /// Pilihan kategori, sama dengan `EXPERIENCE_CHOICES` pada model Django.
  static const List<String> categories = [
    'Internship',
    'Research',
    'Volunteer',
    'Part-Time',
    'Full-Time',
    'Freelance',
  ];
  static const String defaultCategory = 'Full-Time';

  String _title = "";
  String _description = "";
  String _category = defaultCategory;
  String _thumbnail = "";
  DateTime? _startDate;
  DateTime? _endDate;
  bool _isOngoing = false;

  // Field tanggal hanya menampilkan teks, jadi isinya diatur lewat controller.
  final _startDateController = TextEditingController();
  final _endDateController = TextEditingController();

  @override
  void dispose() {
    _startDateController.dispose();
    _endDateController.dispose();
    super.dispose();
  }

  /// Format tanggal sederhana dd/mm/yyyy tanpa paket tambahan.
  static String formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day/$month/${date.year}';
  }

  /// Thumbnail boleh kosong, tetapi jika diisi harus URL http/https yang lengkap.
  static String? validateThumbnail(String? value) {
    final text = value?.trim() ?? "";
    if (text.isEmpty) return null;
    final uri = Uri.tryParse(text);
    final isWebUrl = uri != null &&
        (uri.scheme == 'http' || uri.scheme == 'https') &&
        uri.host.isNotEmpty;
    if (!isWebUrl) {
      return "Thumbnail harus berupa URL yang diawali http:// atau https://";
    }
    return null;
  }

  Future<void> _pickDate({required bool isStart}) async {
    final initial = (isStart ? _startDate : _endDate) ??
        (isStart ? DateTime.now() : (_startDate ?? DateTime.now()));
    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1990),
      lastDate: DateTime(2100),
      helpText: isStart ? 'Pilih tanggal mulai' : 'Pilih tanggal selesai',
    );
    if (picked == null) return;
    setState(() {
      if (isStart) {
        _startDate = picked;
        _startDateController.text = formatDate(picked);
      } else {
        _endDate = picked;
        _endDateController.text = formatDate(picked);
      }
    });
  }

  /// Mengembalikan form dan seluruh state ke kondisi awal setelah disimpan.
  void _resetForm() {
    _formKey.currentState!.reset();
    _startDateController.clear();
    _endDateController.clear();
    setState(() {
      _title = "";
      _description = "";
      _category = defaultCategory;
      _thumbnail = "";
      _startDate = null;
      _endDate = null;
      _isOngoing = false;
    });
  }

  void _showSummaryDialog() {
    final period = _isOngoing
        ? '${formatDate(_startDate!)} - sekarang'
        : '${formatDate(_startDate!)} - ${formatDate(_endDate!)}';
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Experience berhasil ditambahkan!'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Judul: ${_title.trim()}'),
                Text('Deskripsi: ${_description.trim()}'),
                Text('Kategori: $_category'),
                Text('Periode: $period'),
                Text(
                  'Thumbnail: ${_thumbnail.trim().isEmpty ? '-' : _thumbnail.trim()}',
                ),
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

  InputDecoration _decoration(String label, {String? hint, Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(5.0),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Add Experience Form',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        // Warna AppBar sama dengan halaman utama (primary dari tema indigo).
        backgroundColor: colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      drawer: const LeftDrawer(),
      body: Form(
        key: _formKey,
        // SingleChildScrollView menjaga semua field dan tombol Simpan tetap
        // bisa dijangkau di layar sempit atau saat papan ketik tampil.
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // === Judul ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  decoration: _decoration(
                    "Judul Experience",
                    hint: "Contoh: Asisten Dosen PBP",
                  ),
                  // maxLength sekaligus menampilkan penghitung sisa karakter.
                  maxLength: titleMaxLength,
                  textInputAction: TextInputAction.next,
                  onChanged: (String value) => setState(() => _title = value),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Judul tidak boleh kosong!";
                    }
                    if (value.trim().length > titleMaxLength) {
                      return "Judul maksimal $titleMaxLength karakter!";
                    }
                    return null;
                  },
                ),
              ),
              // === Deskripsi ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  maxLines: 5,
                  keyboardType: TextInputType.multiline,
                  decoration: _decoration(
                    "Deskripsi",
                    hint: "Apa yang kamu kerjakan dan pelajari?",
                  ),
                  onChanged: (String value) =>
                      setState(() => _description = value),
                  validator: (String? value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Deskripsi tidak boleh kosong!";
                    }
                    return null;
                  },
                ),
              ),
              // === Kategori ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: DropdownButtonFormField<String>(
                  decoration: _decoration("Kategori"),
                  initialValue: _category,
                  items: categories
                      .map((category) => DropdownMenuItem(
                            value: category,
                            child: Text(category),
                          ))
                      .toList(),
                  onChanged: (String? newValue) {
                    setState(() => _category = newValue!);
                  },
                ),
              ),
              // === Tanggal mulai ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _startDateController,
                  readOnly: true,
                  decoration: _decoration(
                    "Tanggal Mulai",
                    hint: "Ketuk untuk memilih tanggal",
                    suffix: const Icon(Icons.calendar_today),
                  ),
                  onTap: () => _pickDate(isStart: true),
                  validator: (_) {
                    if (_startDate == null) {
                      return "Tanggal mulai wajib dipilih!";
                    }
                    return null;
                  },
                ),
              ),
              // === Masih berjalan ===
              SwitchListTile(
                title: const Text('Masih berjalan'),
                subtitle: const Text('Aktifkan jika belum ada tanggal selesai'),
                value: _isOngoing,
                onChanged: (bool value) {
                  setState(() {
                    _isOngoing = value;
                    if (value) {
                      _endDate = null;
                      _endDateController.clear();
                    }
                  });
                },
              ),
              // === Tanggal selesai ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  controller: _endDateController,
                  readOnly: true,
                  enabled: !_isOngoing,
                  decoration: _decoration(
                    "Tanggal Selesai",
                    hint: _isOngoing
                        ? "Masih berjalan"
                        : "Ketuk untuk memilih tanggal",
                    suffix: const Icon(Icons.event),
                  ),
                  onTap: () => _pickDate(isStart: false),
                  validator: (_) {
                    if (_isOngoing) return null;
                    if (_endDate == null) {
                      return "Pilih tanggal selesai atau aktifkan \"Masih berjalan\"!";
                    }
                    if (_startDate != null && _endDate!.isBefore(_startDate!)) {
                      return "Tanggal selesai tidak boleh sebelum tanggal mulai!";
                    }
                    return null;
                  },
                ),
              ),
              // === Thumbnail ===
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextFormField(
                  keyboardType: TextInputType.url,
                  decoration: _decoration(
                    "Thumbnail (opsional)",
                    hint: "https://contoh.com/gambar.png",
                  ),
                  onChanged: (String value) =>
                      setState(() => _thumbnail = value),
                  validator: validateThumbnail,
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
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _showSummaryDialog();
                      }
                    },
                    child: const Text("Simpan"),
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
