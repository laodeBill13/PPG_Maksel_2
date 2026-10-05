# Panduan Penggunaan Aplikasi PPG Maksel 2

Aplikasi PPG Maksel 2 adalah sistem informasi berbasis web untuk mengelola pembinaan generus: database generus, absensi, program kerja, laporan LUPG, dokumentasi kegiatan, dan arsip dokumen organisasi. Semua data tersimpan online, sehingga bisa diakses bersama oleh seluruh pengurus dari laptop maupun HP.

---

## 1. Gambaran Alur

```
Login ──► Dashboard (ringkasan) ──► Pilih menu di samping kiri:
            • Database Generus   → data induk generus
            • Absensi            → kehadiran kegiatan
            • Program Kerja      → rencana & jadwal kegiatan
            • Laporan LUPG       → capaian pembinaan per kelompok
            • Dokumentasi        → album foto kegiatan
            • Arsip Dokumen      → penyimpanan berkas organisasi
            • Pengaturan         → profil organisasi & sistem
          ──► Keluar Sistem
```

Semua yang diisi di satu menu otomatis ikut terhitung di **Dashboard**. Contohnya, menambah generus baru langsung mengubah angka Total Generus dan grafik kategori.

---

## 2. Masuk ke Aplikasi

1. Buka alamat aplikasi di browser (Chrome disarankan).
2. Masukkan **email** dan **password** yang diberikan oleh admin.
3. Klik **Masuk ke Sistem**.

**Lupa password?**
1. Klik **Lupa Password** di halaman login, lalu masukkan email Anda.
2. Buka email dari sistem, lalu klik link reset di dalamnya.
3. Buat password baru (minimal 8 karakter) dan ketik ulang untuk konfirmasi.
4. Setelah tersimpan, Anda diarahkan kembali ke halaman login.

**Keluar:** klik tombol merah **Keluar Sistem** di bagian bawah menu.

> Di HP, menu samping disembunyikan. Tekan tombol **☰** di kiri atas untuk membukanya.

---

## 3. Hak Akses Pengguna

Setiap akun memiliki salah satu dari tiga peran:

| Peran | Melihat data | Menambah / mengubah / menghapus data | Mengubah profil organisasi |
|---|:---:|:---:|:---:|
| **Admin**       | ✅ | ✅ | ✅ |
| **Pengurus**  | ✅ | ✅ | ❌ |
| **Viewer** | ✅ | ❌ | ❌ |

Akun baru otomatis berperan **Viewer** (hanya bisa melihat). Untuk mendapatkan akses mengubah data, hubungi admin. Jika Anda mencoba menyimpan data tanpa izin, akan muncul pesan *"Akun Anda tidak memiliki izin"*.

---

## 4. Penjelasan Setiap Menu

### 📊 Dashboard
Halaman pertama setelah login. Berisi ringkasan seluruh sistem:

- **Kartu statistik**: total generus, program kerja (selesai/berjalan), dan jumlah dokumen arsip.
- **Grafik** dengan 3 pilihan tab:
  - *Kategori Generus*: jumlah generus per jenjang.
  - *Tren Kehadiran*: persentase hadir per bulan.
  - *Capaian LUPG*: capaian tiap kelompok pada periode terbaru.
- **Kegiatan Terdekat**: agenda yang akan datang. Klik salah satu untuk melihat detailnya.
- **Dokumen & Arsip Terbaru**: bisa dicari, dilihat, dan diunduh langsung.
- **Aktivitas Terkini**: catatan terbaru dari setiap menu.

**Tombol cepat di Dashboard:**
- **+ Tambah Generus**: mendaftarkan generus baru tanpa pindah halaman.
- **+ Input Absensi Cepat**: langsung membuka formulir absensi.
- **+ Tambah Agenda Kegiatan**: menjadwalkan agenda baru (tersimpan di Program Kerja).

---

### 👥 Database Generus
Data induk seluruh generus.

**Menambah generus:** klik **Tambah Generus**, lalu isi nama, jenis kelamin, tanggal lahir, kategori, kelompok, desa, no. HP, nama wali, alamat, dan status. Klik **Simpan**.

**Yang bisa dilakukan pada setiap data:**
| Tombol | Fungsi |
|---|---|
| Label status (Aktif/Tidak Aktif) | Klik untuk mengganti status secara langsung |
| 👁 Lihat | Menampilkan profil lengkap, termasuk umur yang dihitung otomatis |
| ✏️ Edit | Mengubah data |
| 🗑 Hapus | Menghapus data (ada konfirmasi terlebih dahulu) |

**Mencari & menyaring:**
- Ketik di kolom pencarian (nama, no. HP, atau alamat).
- Pilih filter kategori, kelompok, desa, atau status.
- Klik salah satu **kartu kategori** di atas (PAUD, Caberawit, Pra Remaja, Remaja, Usia Nikah) untuk langsung menyaring.

**Rekap jumlah per tingkatan:** di bawah filter terdapat tabel jumlah generus per tingkatan (PAUD, Caberawit, Pra Remaja, Remaja, Usia Nikah), beserta total dan jumlah laki-laki/perempuan.
- Tanpa filter: rekap **per desa** dan total seluruh Maksel 2.
- Klik nama desa (atau pilih **Desa** di filter): rekap **per kelompok** di desa tersebut.
- Pilih **Kelompok**: rekap kelompok tersebut saja. Desa terisi otomatis.
- Filter **Status** (Aktif/Tidak Aktif) ikut memengaruhi hitungan.

**Export Excel** menghasilkan file `.xlsx` berisi dua sheet, mengikuti filter yang sedang dipilih:
1. **Rekap Tingkatan**: jumlah per tingkatan untuk setiap kelompok, subtotal per desa, dan total keseluruhan.
2. **Data Generus**: daftar lengkap generus (nama, jenis kelamin, tanggal lahir, umur, tingkatan, kelompok, desa, kontak, status).

**Cetak PDF** membuka jendela cetak.

---

### ✅ Absensi (Kehadiran Pengurus)
Mencatat kehadiran **pengurus** pada tiga jenis kegiatan:
- **Musyawarah Pengurus**
- **Penyampaian PPG Pusat**
- **Penyampaian PPG Daerah**

> Absensi ini khusus pengurus. Generus tidak memiliki presensi di aplikasi; data generus dikelola di menu Database Generus.

**Mencatat kehadiran:** klik **Input Presensi**, lalu isi nama pengurus, jabatan/unsur (misalnya Ketua, Sekretaris), asal kelompok (desa terisi otomatis), kegiatan, tanggal (otomatis hari ini), jam, dan status (Hadir / Izin / Sakit / Alpha). Tambahkan keterangan bila perlu, lalu klik **Simpan**.

**Tips cepat:** klik label status pada tabel untuk menggantinya secara berurutan: Hadir → Izin → Sakit → Alpha.

Kartu di bagian atas menampilkan jumlah dan persentase kehadiran. Klik salah satu kartu untuk menyaring. Data juga bisa disaring per kegiatan, kelompok, status, atau tanggal, lalu diunduh (Excel) atau dicetak (PDF).

---

### 📋 Program Kerja
Merencanakan dan memantau kegiatan organisasi.

**Menambah program:** klik **Tambah Program**, lalu isi:
- nama program, bidang (Pendidikan / Keagamaan / Sosial / Organisasi)
- status (Aktif / Pending / Selesai / Ditunda)
- tanggal mulai & selesai, penanggung jawab, prioritas
- **progress** (geser 0–100%) dan deskripsi

Setiap program tampil sebagai kartu dengan bar progress. Gunakan tombol **Detail**, **Edit**, atau 🗑 **Hapus** pada kartu. Tampilan bisa diganti antara **kotak (grid)** dan **daftar (list)**.

> Program yang tanggal mulainya akan datang otomatis muncul di **Kegiatan Terdekat** pada Dashboard.

---

### 📑 Laporan LUPG
Rekap pembinaan setiap kelompok per bulan, dengan format yang sama seperti lembar Excel LUPG: **Kehadiran (%)** dan **Ketercapaian Materi (%)** untuk 10 jenjang (PAUD, kelas 1–6, Pra Remaja, Remaja, Usia Nikah).

**Melihat laporan:**
1. Pilih **Bulan** dan **Tahun** di bagian atas. Saat dibuka, halaman otomatis menampilkan periode terbaru.
2. Pilih tab **Kehadiran (%)** atau **Ketercapaian Materi (%)**.
3. Tabel menampilkan ke-16 kelompok dari 4 desa (Gowata, Bataraya, Babuta, Selayar). Kelompok yang belum mengirim laporan ditandai **"Belum lapor"**.

Warna angka: **hijau** ≥ 80%, **kuning** 60–79%, **merah** < 60%. Tanda “–” berarti jenjang tersebut tidak dilaporkan.

**Ringkasan otomatis untuk periode terpilih:**
- Jumlah kelompok yang sudah dan belum melapor.
- Rata-rata kehadiran dan ketercapaian materi, dibandingkan dengan bulan sebelumnya.
- **Grafik per bulan** dalam satu tahun. Klik batang bulan untuk berpindah periode.
- **Rekap per desa**.

**Menginput laporan:**
1. Klik **+ Input** pada baris kelompok yang belum lapor, atau tombol **Input Laporan** di atas (di HP: tombol **+** hijau).
2. Pastikan kelompok, bulan, dan tahun sudah benar.
3. Isi persentase kehadiran dan ketercapaian untuk setiap jenjang (0–100). **Kosongkan** jenjang yang tidak dilaporkan.
4. Tambahkan catatan bila perlu, lalu klik **Simpan Laporan**.

> Setiap kelompok hanya memiliki **satu laporan per bulan**. Jika Anda memilih kelompok dan bulan yang sudah ada laporannya, form otomatis menampilkan data tersebut dan menyimpannya sebagai pembaruan.

**Mengubah/menghapus laporan:** klik **Detail** pada baris kelompok, lalu pilih **Edit** atau **Hapus**.

**Export Excel** menghasilkan file dengan susunan kolom seperti lembar LUPG (16 kelompok, kehadiran dan ketercapaian per jenjang) untuk periode yang sedang ditampilkan.

---

### 📸 Dokumentasi
Galeri album foto kegiatan.

**Menambah album:** klik **Tambah Dokumentasi**, lalu isi judul, tanggal, kategori (Ngaji, Bakti Sosial, Pelatihan, Musyawaroh, Outing), lokasi, jumlah foto, dan deskripsi. Pilih gambar dari perangkat (atau tempel link gambar). Pratinjau muncul sebelum disimpan.

Klik **Lihat Detail** pada album untuk melihat gambar ukuran besar, serta tombol **Edit** dan **Hapus**. Album bisa dicari berdasarkan judul/lokasi dan disaring per kategori atau bulan.

---

### 🗂 Arsip Dokumen
Penyimpanan berkas resmi organisasi (PDF, Excel, Word, gambar).

**Mengunggah berkas:** klik **Unggah Dokumen**, lalu pilih file. Nama, ukuran, dan tipe terisi otomatis. Pilih kategori (Laporan LUPG, SK & Surat, Dokumentasi, Data Generus, Lainnya), isi tanggal dan catatan, lalu klik **Simpan**.

**Pada setiap berkas:**
| Tombol | Fungsi |
|---|---|
| ⬇️ Unduh | Mengunduh berkas asli |
| ✏️ Edit | Mengubah keterangan; file boleh diganti atau dibiarkan |
| 🗑 Hapus | Menghapus data beserta berkasnya |

Klik salah satu **kartu folder** untuk melihat berkas per kategori. Berkas juga bisa dicari dan disaring per tipe. Batas ukuran per berkas adalah **50 MB**.

---

### ⚙️ Pengaturan
- **Profil Organisasi**: nama organisasi, deskripsi, dan tahun kepengurusan (khusus Admin).
- **Akun Pengguna**: pengelolaan akun dan peran dilakukan oleh admin teknis.
- **Konfigurasi Database**: khusus admin teknis, tidak perlu diubah.

---

## 5. Contoh Penggunaan Sehari-hari

| Situasi | Langkah |
|---|---|
| Ada generus baru | Database Generus → **Tambah Generus** |
| Selesai musyawarah / penyampaian PPG | Absensi → **Input Presensi** untuk setiap pengurus yang hadir |
| Akhir bulan | Laporan LUPG → **+ Input** pada setiap kelompok yang belum lapor |
| Merencanakan kegiatan | Program Kerja → **Tambah Program**, perbarui progress secara berkala |
| Setelah kegiatan | Dokumentasi → **Tambah Dokumentasi** dengan foto kegiatan |
| Ada SK / surat / laporan resmi | Arsip Dokumen → **Unggah Dokumen** |
| Rapat pengurus | Buka **Dashboard** untuk melihat ringkasan dan grafik |
| Butuh jumlah generus per desa/kelompok | Database Generus → pilih desa/kelompok → lihat **Rekap** atau **Export Excel** |
| Butuh data untuk laporan | Gunakan **Export Excel** atau **Cetak PDF** di menu terkait |

---

## 6. Pertanyaan Umum

**Apakah data yang saya isi langsung terlihat oleh pengurus lain?**
Ya. Data tersimpan online. Pengurus lain cukup memuat ulang halaman untuk melihat data terbaru.

**Kenapa saya tidak bisa menyimpan data?**
Kemungkinan akun Anda berperan *Viewer*. Hubungi admin untuk mengubah peran.

**Kenapa saya diarahkan kembali ke halaman login?**
Sesi Anda sudah berakhir atau Anda belum login. Silakan masuk kembali.

**Apakah data yang dihapus bisa dikembalikan?**
Tidak. Karena itu, setiap penghapusan selalu meminta konfirmasi terlebih dahulu.

**Apakah bisa dipakai di HP?**
Bisa. Semua menu menyesuaikan layar HP. Gunakan tombol **☰** untuk membuka menu.

---

## 7. Fitur yang Sedang Dikembangkan

Beberapa fitur berikut belum tersedia dan direncanakan untuk tahap berikutnya:

- Unggah laporan LUPG sekaligus dari file Excel (saat ini diinput per kelompok).
- Album dokumentasi dengan banyak foto dan video.
- Kalender kegiatan bulanan.
- Notifikasi (WhatsApp/email) dan pengelolaan akun langsung dari halaman Pengaturan.
