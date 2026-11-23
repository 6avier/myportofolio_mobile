Kemas Xavier Alvaresyah
2506656886
PBP C

---

# myportofolio_mobile

Aplikasi mobile Flutter untuk portofolio pribadi saya. Aplikasi ini adalah pasangan mobile dari website portofolio Django saya ([myportofolio](https://github.com/6avier/myportofolio)) dan dikerjakan bertahap sepanjang paruh kedua semester PBP.

Saat ini aplikasi memiliki halaman menu utama (tiga kartu identitas dan empat tombol aksi), drawer navigasi, formulir Tambah Proyek (Tutorial 09), dan formulir Tambah Experience (Tugas 8). Isian formulir baru ditampilkan dalam dialog ringkasan; data portofolio dari API Django belum dihubungkan.

## Menjalankan proyek

Prasyarat: Flutter SDK (Dart sudah termasuk di dalamnya) dan Google Chrome.

```bash
git clone https://github.com/6avier/myportofolio_mobile.git
cd myportofolio_mobile
flutter pub get
flutter run -d chrome
```

Perintah lain yang dipakai selama pengerjaan:

```bash
flutter analyze   # analisis statis, harus "No issues found!"
flutter test      # widget test untuk menu, drawer, dan formulir
```

## Struktur kode

- `lib/main.dart`: titik masuk aplikasi. Berisi `MyApp` yang membungkus semuanya dengan `MaterialApp` dan menyetel tema.
- `lib/screens/menu.dart`: halaman menu utama `MyHomePage` (`StatelessWidget`), widget `InfoCard`, serta model `ItemHomepage` (nama, ikon, dan warna tiap tombol).
- `lib/screens/project_form.dart`: formulir Tambah Proyek dari Tutorial 09.
- `lib/screens/experience_form.dart`: formulir Tambah Experience (Tugas 8). Field-nya mengikuti model `Experience` di backend Django: judul (maks. 255 karakter), deskripsi, kategori, tanggal mulai/selesai lewat `showDatePicker()` dengan sakelar "Masih berjalan", dan thumbnail URL opsional.
- `lib/widgets/left_drawer.dart`: drawer berisi opsi Home, Add Project, dan Add Experience, dipakai di semua halaman.
- `lib/widgets/project_card.dart`: `ItemCard`, kartu aksi berwarna yang menampilkan `SnackBar` lalu membuka formulir terkait dengan `Navigator.push()`.
- `test/widget_test.dart`: kartu identitas, warna unik tiap tombol, `SnackBar`, formulir proyek, dan drawer.
- `test/experience_form_test.dart`: akses formulir Experience dari kartu dan drawer, input tidak valid, input valid beserta dialog ringkasan, serta kembali ke halaman utama.

---

### Tugas 7

1. **Widget tree** adalah susunan berbentuk pohon dari semua widget yang membentuk tampilan aplikasi Flutter. Setiap widget mendeskripsikan satu bagian UI dan bisa memiliki widget lain sebagai anak (child) atau beberapa anak (children). Di proyek ini pohonnya kira-kira `MyApp` → `MaterialApp` → `MyHomePage` → `Scaffold` → `AppBar` dan `Padding` → `Column` → `IntrinsicHeight` → `Row` → tiga `Expanded` → `InfoCard` → `Card` → `Container` → `Column` → `Text`, lalu `Center` → `Column` → `GridView.count` → tiga `ItemCard` → `Material` → `InkWell` → `Column` → `Icon` dan `Text`. Hubungan parent-child bekerja dua arah. Parent memberi batasan ukuran (constraints) ke child, child menentukan ukurannya sendiri di dalam batasan itu, lalu parent yang memutuskan posisinya. Karena itu `Expanded` di dalam `Row` membuat tiga kartu identitas membagi lebar sama rata. Widget bersifat immutable. Saat ada perubahan, Flutter memanggil `build` lagi untuk membuat deskripsi pohon yang baru, membandingkannya dengan yang lama, lalu hanya memperbarui bagian yang berbeda.

2. Widget yang saya pakai di proyek ini:
   - `MaterialApp`: root aplikasi bergaya Material, menyediakan tema, halaman awal (`home`), dan `ScaffoldMessenger`.
   - `Scaffold`: kerangka halaman Material yang menyediakan tempat untuk `appBar` dan `body`, serta menampilkan `SnackBar`.
   - `AppBar`: bar judul "MyPortfolio" di bagian atas.
   - `Padding`: memberi jarak 16 di sekeliling isi halaman, juga jarak di sekitar teks sambutan dan ikon.
   - `Column`: menyusun anak secara vertikal (isi halaman, isi tiap kartu).
   - `Row`: menyusun tiga `InfoCard` secara horizontal.
   - `IntrinsicHeight`: membuat tinggi `Row` mengikuti anak tertinggi supaya ketiga kartu identitas sama tinggi.
   - `Expanded`: membagi lebar `Row` sama rata ke tiap `InfoCard`.
   - `Center`: menengahkan bagian sambutan dan isi tiap `ItemCard`.
   - `SizedBox`: jarak kosong dengan ukuran tetap antar elemen.
   - `Text`: menampilkan teks (judul, identitas, nama tombol, sambutan).
   - `Icon`: menampilkan ikon pada tiap tombol.
   - `GridView.count`: menampilkan tombol menu dalam kisi 3 kolom (dengan `shrinkWrap` agar tingginya mengikuti isi).
   - `Card`: kartu dengan bayangan untuk `InfoCard`.
   - `Container`: kotak yang mengatur padding isi `InfoCard` dan `ItemCard`.
   - `Material`: permukaan Material berwarna dan bersudut membulat untuk latar `ItemCard`.
   - `InkWell`: membuat kartu bisa disentuh, lengkap dengan efek riak (ripple) dan `onTap`.
   - `SnackBar` (lewat `ScaffoldMessenger`): notifikasi di bawah layar "Kamu telah menekan tombol ...!".
   - Widget buatan sendiri: `MyApp`, `MyHomePage`, `InfoCard`, dan `ItemCard`, supaya kode tidak berulang dan mudah dibaca.

3. **`MaterialApp`** adalah widget yang membungkus aplikasi bergaya Material Design. Ia menyediakan tema (`ThemeData` dan `ColorScheme`), halaman awal (`home`) beserta `Navigator` untuk berpindah halaman, judul aplikasi, pengaturan bahasa dan arah teks, serta `ScaffoldMessenger` yang mengelola `SnackBar`. Widget Material seperti `Scaffold`, `AppBar`, `InkWell`, dan `SnackBar` bergantung pada hal-hal tersebut, sehingga biasanya `MaterialApp` dipasang di paling atas pohon. Di proyek ini `MaterialApp` menetapkan tema indigo di satu tempat, yang kemudian dipakai oleh seluruh widget di bawahnya lewat `Theme.of(context)`.

4. **`StatelessWidget`** tidak menyimpan state yang berubah. Tampilannya hanya ditentukan oleh properti yang diberikan lewat konstruktor, sehingga hasil `build`-nya selalu sama untuk masukan yang sama. **`StatefulWidget`** punya objek `State` terpisah yang bertahan selama widget hidup dan menyimpan data yang bisa berubah. Memanggil `setState` membuat Flutter menjalankan `build` ulang. Pilih `StatelessWidget` untuk tampilan yang tetap, seperti halaman menu ini yang berisi identitas dan tombol statis. Pilih `StatefulWidget` bila tampilan bergantung pada data yang berubah akibat interaksi atau waktu, misalnya counter bawaan Flutter, isi form, checkbox, animasi, atau data yang baru selesai dimuat dari internet. Itu sebabnya di Tutorial 08 `MyHomePage` diubah menjadi stateless setelah `_counter` dihapus.

5. **`BuildContext`** adalah penunjuk ke posisi sebuah widget di dalam widget tree (secara teknis `Element`-nya). Fungsinya untuk menelusuri pohon ke atas dan mencari widget leluhur atau data bersama, misalnya `Theme.of(context)`, `MediaQuery.of(context)`, dan `ScaffoldMessenger.of(context)`. Setiap method `build(BuildContext context)` menerimanya dari Flutter. Di proyek ini `Theme.of(context).colorScheme.primary` memberi warna `AppBar`, dan `ScaffoldMessenger.of(context)` di `ItemCard` dipakai untuk menampilkan `SnackBar`. Pencarian itu hanya berhasil jika `context`-nya berada di bawah widget yang dicari, misalnya di bawah `MaterialApp`. Karena itu `context` dari bagian atas pohon tidak bisa dipakai untuk mencari widget di bawahnya.

6. **Hot reload** memasukkan kode Dart yang baru disimpan ke aplikasi yang sedang berjalan di mode debug lalu membangun ulang widget tree, sehingga hasil perubahan tampil dalam hitungan detik dan state aplikasi tetap terjaga. **Hot restart** memuat ulang seluruh kode dan menjalankan `main()` dari awal, jadi state kembali ke kondisi awal, tetapi masih lebih cepat daripada menjalankan ulang aplikasi dari nol. Hot reload tidak cukup, dan kita harus hot restart atau full restart (stop lalu `flutter run` lagi), saat: mengubah isi `main()` atau inisialisasi variabel global dan field `static`, mengubah kode yang hanya berjalan sekali seperti `initState`, mengubah `enum` menjadi `class` atau sebaliknya, serta mengubah tipe generik. Full restart juga wajib saat menambah dependency di `pubspec.yaml` atau mengubah kode native di folder `android/` atau `ios/`, karena bagian itu harus dikompilasi ulang.

### Penggunaan AI

Saya menggunakan AI dalam pengerjaan tugas ini.

**Tools:** Claude (Claude Code), model Sonnet.

**Strategi prompting:** Saya memberikan requirement tugas dan struktur proyek yang sedang dikerjakan, lalu meminta AI membantu menjelaskan konsep Flutter dan memberikan arahan implementasi langkah demi langkah. Jika menemukan error, saya memberikan pesan error atau bagian kode terkait untuk ditelusuri penyebabnya. Saya juga menggunakan AI untuk membantu mengevaluasi struktur widget dan memastikan implementasi sesuai dengan kebutuhan tugas.

**Bagian yang dibantu:**

- Penyusunan struktur awal aplikasi Flutter dan pembagian widget ke dalam file.
- Implementasi halaman menu utama, termasuk kartu identitas dan tombol aksi.
- Pemahaman penggunaan widget Flutter seperti `MaterialApp`, `Scaffold`, `Column`, `Row`, dan `GridView`.
- Troubleshooting serta pengecekan hasil melalui `flutter analyze` dan `flutter test`.
- Penyusunan penjelasan konsep Flutter dan README ini.

### Tugas 8

1. `Navigator` menyimpan halaman (route) sebagai tumpukan. **`Navigator.push()`** menaruh route baru di atas tumpukan, sehingga halaman sebelumnya tetap ada di bawahnya. **`Navigator.pushReplacement()`** mengganti route paling atas dengan route baru, jadi route lama dibuang dan tidak bisa dikunjungi lagi dengan tombol kembali. **`Navigator.pop()`** membuang route paling atas sehingga pengguna kembali ke route di bawahnya. Kartu aksi "Tambah Experience" di `ItemCard` (`lib/widgets/project_card.dart`) memakai `Navigator.push()` ke `ExperienceFormPage`, jadi menu tetap ada di bawah formulir dan tombol kembali perangkat atau browser membawa pengguna kembali ke menu (diuji lewat `handlePopRoute()` di `test/experience_form_test.dart`). Opsi Home di `LeftDrawer` memakai `Navigator.pushReplacement()` dengan `MyHomePage()`: route formulir yang sedang tampil diganti dengan halaman utama yang baru. Opsi drawer untuk Add Project dan Add Experience juga memakai `pushReplacement()`, sehingga berpindah-pindah lewat drawer tidak menumpuk halaman.

2. Setiap halaman (`MyHomePage`, `ProjectFormPage`, `ExperienceFormPage`) memakai `Scaffold` sebagai kerangka yang sama: `AppBar` di atas, `body` di tengah, dan `drawer: const LeftDrawer()` di samping. Karena drawer dibuat sekali di `lib/widgets/left_drawer.dart` lalu dipasang di ketiga halaman, isi menu navigasinya selalu sama dan cukup diubah di satu tempat. Ikon hamburger di `AppBar` juga otomatis muncul karena `Scaffold` tahu halaman itu punya drawer. Contoh warna tema: `Theme.of(context).colorScheme.primary` (indigo dari `ColorScheme.fromSeed` di `main.dart`) dipakai untuk latar `AppBar` halaman utama, latar `AppBar` formulir Experience, dan latar tombol Simpan formulir Experience, sehingga warnanya ikut berubah bila seed tema diganti.

3. Formulir Experience disusun sebagai satu `Column` vertikal di dalam `SingleChildScrollView`, karena urutan isiannya alami dibaca dari atas ke bawah (judul, deskripsi, kategori, tanggal, thumbnail) dan satu kolom paling nyaman di layar ponsel yang sempit. Setiap input dibungkus `Padding(8)` agar ada jarak yang sama antarkolom dan pesan error tidak menempel ke kolom berikutnya. Sakelar "Masih berjalan" memakai `SwitchListTile` supaya label dan sakelarnya berada di satu baris, dan tombol Simpan dibungkus `Align` agar berada di tengah. `SingleChildScrollView` menjadi penting ketika ruang layar terbatas: tanpa widget ini, `Column` yang lebih tinggi dari layar akan overflow. Saat papan ketik muncul, `Scaffold` mengecilkan area `body`, dan `SingleChildScrollView` membuat semua kolom serta tombol Simpan tetap bisa digulir dan dijangkau. Hal ini saya cek di ukuran 375x812.

4. `GlobalKey<FormState>` (`_formKey`) adalah kunci yang dipasang di widget `Form` sehingga kode di luar build bisa mengakses state formulir. Setiap `TextFormField` punya `validator`, yaitu fungsi yang mengembalikan pesan error (`String`) bila isiannya tidak valid atau `null` bila valid. Saat tombol Simpan ditekan, `_formKey.currentState!.validate()` menjalankan semua validator sekaligus, menampilkan pesan error di bawah kolom yang salah, dan mengembalikan `true` hanya jika semuanya lolos. Hanya pada kondisi itu `showDialog()` dipanggil. Contoh nilai yang ditolak: `bukan-url` pada kolom Thumbnail. Kolom itu memakai `keyboardType: TextInputType.url`, tetapi jenis papan ketik hanya mengubah tombol yang ditampilkan dan tidak membatasi apa yang bisa diketik atau ditempel, sehingga `validateThumbnail` tetap harus memeriksa bahwa isinya URL dengan skema `http`/`https` dan host. Hal yang sama berlaku untuk tanggal: `showDatePicker()` menjamin formatnya tanggal, tetapi tidak menjamin tanggal selesai jatuh setelah tanggal mulai, jadi aturan itu tetap dicek di validator. Judul yang hanya berisi spasi juga ditolak karena validator memakai `trim()`.

### Penggunaan AI

Saya menggunakan AI sebagai alat bantu selama pengerjaan tugas ini.

**Tools:** Claude (Claude Code), model Sonnet.

**Strategi prompting:** Saya memberikan requirement tugas dan konteks struktur proyek yang sedang dikerjakan, kemudian menggunakan AI untuk membantu memahami konsep Flutter, mencari referensi implementasi, serta mendiskusikan solusi ketika menemukan kendala. Saya juga menggunakan AI untuk membantu meninjau hasil implementasi agar sesuai dengan kebutuhan tugas.

**Bagian yang dibantu:**

- Konsultasi terkait implementasi navigasi halaman menggunakan `Navigator`.
- Referensi penggunaan `Scaffold`, `Drawer`, dan konsistensi tema antarhalaman.
- Bantuan dalam memahami struktur formulir Experience dan validasi input.
- Diskusi terkait penggunaan `Form`, `GlobalKey<FormState>`, dan `TextFormField`.
- Bantuan troubleshooting dan evaluasi implementasi melalui `flutter analyze` dan `flutter test`.
