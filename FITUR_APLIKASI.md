# Daftar Fitur Aplikasi PPG Maksel 2

Sistem informasi berbasis web untuk mengelola pembinaan generus: data generus, kehadiran pengurus, program kerja, laporan LUPG, dokumentasi, arsip, dan struktur kepengurusan. Semua data tersimpan online dan dapat diakses bersama oleh seluruh pengurus melalui laptop maupun HP.

---

## 1. Akun & Hak Akses

### Masuk & Keamanan
- Login menggunakan email dan password. Halaman aplikasi tidak dapat dibuka tanpa login.
- **Lupa password**: link reset dikirim ke email, lalu pengguna membuat password baru. Link yang sudah kedaluwarsa menampilkan pesan yang jelas beserta tautan untuk meminta link baru.
- Tombol **Keluar Sistem** untuk mengakhiri sesi.
- Seluruh pesan kesalahan ditampilkan dalam Bahasa Indonesia.

### Pendaftaran Akun Mandiri
- Tombol **Daftar Akun Baru** tersedia di halaman login.
- Pendaftar memilih tipe:
  - **Pengurus Kelompok**: memilih kelompok, desa terisi otomatis.
  - **Pengurus PPG Maksel 2**
- Data yang diisi: nama, email, no. HP/WA, jabatan, dan password.
- Akun baru berstatus **menunggu persetujuan** sampai disetujui admin. Email yang sudah terdaftar tidak dapat didaftarkan ulang.

### Persetujuan User (khusus Admin)
- Daftar pengguna dalam tab **Menunggu**, **Disetujui**, dan **Ditolak**, dengan penanda di menu bila ada pendaftar baru.
- Admin dapat **menyetujui** (sekaligus mengatur peran, jabatan, dan kelompok), **menolak**, **menonaktifkan**, dan **mengubah hak akses** pengguna.
- Menjadikan seseorang Admin selalu memerlukan konfirmasi.
- Admin tidak dapat menurunkan aksesnya sendiri, dan sistem selalu menjaga **minimal satu admin aktif**.

### Empat Tingkat Hak Akses
Hak akses dijaga langsung oleh database, tidak hanya oleh tampilan.

| Peran | Untuk | Hak akses |
|---|---|---|
| **Admin** | Ketua, Wakil Ketua, Sekretaris | Seluruh data, persetujuan pengguna, struktur kepengurusan, pengaturan |
| **Pengurus** | Pengurus PPG lainnya | Menambah, mengubah, dan menghapus seluruh data |
| **User Kelompok** | Pengurus kelompok | Hanya Laporan LUPG dan Dokumentasi milik kelompoknya sendiri |
| **Viewer** | Pemantau | Hanya melihat |

### Tampilan Akun
- Nama, jabatan, dan inisial akun yang sedang login tampil di pojok kanan atas, di sidebar, dan di halaman Pengaturan.
- Dashboard menyapa pengguna dengan nama depannya.

---

## 2. Dashboard
- **Kartu statistik**:
  - total generus beserta jumlah yang aktif dan jumlah kelompok
  - total pengurus (dari Struktur Kepengurusan)
  - program kerja: jumlah selesai dan berjalan, serta persentase terlaksana
  - jumlah dokumen arsip beserta tambahan bulan ini
- **Pintasan modul** dengan angka terkini: jumlah generus, persentase kehadiran, jumlah agenda, persentase LUPG terisi, jumlah album, dan jumlah berkas.
- **Grafik interaktif** dengan tiga tampilan:
  - jumlah generus per jenjang
  - tren kehadiran pengurus per bulan
  - kehadiran LUPG per desa
- **Kegiatan Terdekat** dan **kegiatan bulan ini**, dengan detail setiap kegiatan.
- **Dokumen & Arsip Terbaru**: dapat dicari, dilihat, dan diunduh.
- **Aktivitas Terkini**: catatan terbaru dari setiap modul.
- **Tombol cepat**: Tambah Generus, Input Absensi, Upload LUPG, Tambah Agenda.
- Tanggal dan jam (WITA) yang selalu terkini.

---

## 3. Database Generus
- **Tambah, ubah, hapus, dan lihat detail** generus. Data yang dicatat:
  - nama, jenis kelamin
  - tanggal lahir (umur dihitung otomatis)
  - jenjang
  - kelompok (desa terisi otomatis)
  - no. HP, nama wali, alamat, status
- Status **Aktif / Tidak Aktif** dapat diganti dengan satu klik.
- **Lima kartu jenjang** (PAUD, Caberawit, Pra Remaja, Remaja, Usia Nikah) yang dapat diklik untuk menyaring data.
- **Pencarian** (nama, no. HP, alamat) dan **filter** jenjang, kelompok, desa, dan status. Pilihan desa dan kelompok saling menyesuaikan.
- **Rekap Jumlah per Tingkatan**:
  - per desa, lalu per kelompok saat nama desa diklik
  - dilengkapi total dan jumlah laki-laki/perempuan
- **Export Excel (.xlsx)** berisi dua lembar, sesuai filter yang dipilih:
  1. **Rekap Tingkatan**: jumlah per tingkatan untuk setiap kelompok, subtotal per desa, dan total keseluruhan.
  2. **Data Generus**: daftar lengkap generus.
- **Cetak PDF**.

---

## 4. Absensi (Kehadiran Pengurus)
- Mencatat kehadiran pengurus pada tiga kegiatan:
  - **Musyawarah Pengurus**
  - **Penyampaian PPG Pusat**
  - **Penyampaian PPG Daerah**
- Data yang dicatat:
  - nama pengurus, jabatan/unsur, asal kelompok
  - tanggal (otomatis hari ini), jam
  - status (Hadir / Izin / Sakit / Alpha), keterangan
- Status dapat diganti dengan satu klik secara berurutan.
- Kartu ringkasan jumlah dan persentase kehadiran yang dapat diklik untuk menyaring.
- Filter kegiatan, kelompok, status, dan tanggal.
- **Export Excel** dan **Cetak PDF**.

---

## 5. Program Kerja
- **Tambah, ubah, hapus, dan lihat detail** program. Data yang dicatat:
  - nama, bidang, status (Aktif / Pending / Selesai / Ditunda)
  - tanggal mulai–selesai, prioritas, lokasi, deskripsi
  - progress 0–100%
- **Penanggung jawab** dipilih dari daftar yang menyesuaikan bidang (diambil dari Struktur Kepengurusan), atau diketik manual.
- **RAB**: nominal rupiah dengan format otomatis, ditambah **unggah file Excel RAB** yang dapat dibuka dari halaman detail program.
- Tiga tampilan: **Kotak**, **Daftar**, dan **Kalender** bulanan. Di kalender, pengguna dapat berpindah bulan, kembali ke hari ini, dan mengklik tanggal untuk melihat kegiatannya.
- Filter status, bidang, prioritas, dan pencarian, beserta ringkasan jumlah program.

---

## 6. Laporan LUPG
Format laporan mengikuti lembar Excel LUPG.

- **Tabel seluruh kelompok × 10 jenjang** (PAUD, kelas 1–6, Pra Remaja, Remaja, Usia Nikah) dengan dua tab:
  - **Kehadiran (%)**
  - **Ketercapaian Materi (%)**
- Penanda warna nilai: hijau (≥ 80%), kuning (60–79%), merah (< 60%).
- **Input laporan per kelompok per bulan**:
  - nilai kehadiran dan ketercapaian untuk setiap jenjang
  - **Hasil Musyawarah 5 Unsur**, **Kendala**, **Keterangan**, dan catatan
- Setiap kelompok memiliki **satu laporan per bulan**. Bila laporannya sudah ada, formulir otomatis menampilkan data tersebut untuk diperbarui.
- **Ringkasan otomatis** per periode:
  - jumlah kelompok yang sudah dan belum melapor
  - rata-rata kehadiran dan ketercapaian, serta perbandingannya dengan bulan sebelumnya
- **Grafik per bulan** dan **rekap per desa**.
- Kelompok yang belum melapor memiliki tombol **+ Input** langsung di barisnya.
- **Export Excel** dengan susunan kolom seperti lembar LUPG.
- **User Kelompok** hanya dapat melihat dan mengisi laporan kelompoknya sendiri.

---

## 7. Dokumentasi
- **Album kegiatan**. Data yang dicatat:
  - judul, tanggal, kategori (Ngaji, Bakti Sosial, Pelatihan, Musyawaroh, Outing)
  - kelompok, tingkatan pengajian
  - lokasi, jumlah foto, deskripsi
- Foto diunggah langsung di aplikasi. Untuk album berisi banyak foto, tersedia **tautan Google Drive**.
- **Rekap target dokumentasi**: minimal satu dokumentasi per tingkatan di setiap kelompok setiap bulan. Sel rekap dapat diklik untuk melihat dokumentasinya. Tersedia pilihan **"Hanya kelompok saya"**.
- Galeri, tampilan detail, ubah, dan hapus.
- Filter kategori, tingkatan, bulan, dan pencarian.

---

## 8. Arsip Dokumen
- **Unggah berkas** PDF, Excel, Word, dan gambar (maks. 50 MB per berkas). Nama, ukuran, dan tipe terisi otomatis dari file.
- Kategori: **Laporan LUPG, SK & Surat, Dokumentasi, Data Generus, Lainnya**.
- **Unduh**, **ubah** (termasuk mengganti file), dan **hapus** berkas.
- Folder per kategori dan statistik jumlah berkas.
- Filter kategori, tipe, dan pencarian.

---

## 9. Struktur Kepengurusan
- Bagan kepengurusan **empat tingkat**:
  1. Ketua
  2. Pengurus Harian (Wakil, Sekretaris, Bendahara)
  3. Koordinator Bidang
  4. Anggota Bidang
- Tambah, ubah, dan hapus pengurus (jabatan, bidang, nama, no. HP, urutan). Perubahan hanya dapat dilakukan oleh Admin.
- Data struktur ini juga dipakai untuk pilihan penanggung jawab di Program Kerja dan untuk jumlah pengurus di Dashboard.

---

## 10. Pengaturan
- Profil akun yang sedang login.
- **Profil Organisasi**: nama, deskripsi, dan tahun kepengurusan (khusus Admin).
- Akses ke halaman **Persetujuan & Hak Akses User**.
- Pengaturan notifikasi.

---

## 11. Keunggulan Umum
- **Dapat digunakan di HP, tablet, dan laptop**, dengan menu dan tabel yang menyesuaikan layar.
- **Data online dan bersama**: seluruh pengurus melihat data terbaru yang sama.
- **Aman**: hak akses dijaga oleh database, file disimpan secara privat, dan data pribadi pengguna hanya dapat dilihat oleh Admin.
- **Mudah diekspor**: hampir setiap modul dapat diunduh ke Excel atau dicetak.
- Dilengkapi **Panduan Penggunaan** untuk pengurus.

---

## 12. Rencana Pengembangan
Fitur berikut belum tersedia dan dapat dikembangkan pada tahap berikutnya:
- Notifikasi otomatis melalui WhatsApp atau email.
- Unggah laporan LUPG sekaligus dari file Excel.
- Album dokumentasi berisi banyak foto dan video langsung di aplikasi.
- Pemilihan nama pengurus di Absensi langsung dari Struktur Kepengurusan.
- Status **Pemilik** untuk akun Ketua, sehingga tidak dapat diubah oleh admin lain.

---

*Dikembangkan oleh **NadheStudio** — [nadhestudio.id](https://nadhestudio.id)*
