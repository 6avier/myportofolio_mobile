Kemas Xavier Alvaresyah
2506656886
PBP C

---

# myportofolio_mobile

Aplikasi mobile Flutter untuk portofolio pribadi saya. Aplikasi ini adalah pasangan mobile dari website portofolio Django saya ([myportofolio](https://github.com/6avier/myportofolio)) dan dikerjakan bertahap sepanjang paruh kedua semester PBP.

Saat ini aplikasi baru memiliki halaman menu utama dengan tiga kartu identitas dan tiga tombol aksi. Data portofolio dari API Django belum dihubungkan.

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
flutter test      # widget test untuk halaman menu
```

## Struktur kode

- `lib/main.dart`: titik masuk aplikasi. Berisi `MyApp` yang membungkus semuanya dengan `MaterialApp` dan menyetel tema.
- `lib/menu.dart`: halaman menu utama `MyHomePage` (`StatelessWidget`), widget `InfoCard` dan `ItemCard`, serta model `ItemHomepage` (nama, ikon, dan warna tiap tombol).
- `test/widget_test.dart`: memeriksa isi kartu identitas, warna unik tiap tombol, dan `SnackBar` saat tombol ditekan.

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
