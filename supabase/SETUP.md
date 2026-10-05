# Setup Supabase PPG Maksel 2

## 1. Database

1. Buat project Supabase, lalu buka **SQL Editor**.
2. Jalankan seluruh isi `schema.sql`. Script ini membuat tabel, indeks, profil pengguna, trigger `updated_at`, bucket Storage privat (maks. 50 MB per file), dan RLS.
   Script aman dijalankan ulang untuk migrasi: data contoh Program Kerja hanya diisi saat tabelnya masih kosong.
3. Jalankan `import_lupg_2024.sql` untuk memasukkan data LUPG 2024 (Maret, April, Mei, Juni, September). Aman dijalankan ulang.

## 2. Auth

1. **Authentication → URL Configuration**
   - *Site URL*: alamat aplikasi setelah deploy, misalnya `https://ppg-maksel2.example.com/login.html`.
   - *Redirect URLs*: tambahkan `https://ppg-maksel2.example.com/login.html` **dan** `https://ppg-maksel2.example.com/reset_password.html` (plus versi `http://127.0.0.1:4173/...` untuk uji lokal). Link konfirmasi email pendaftaran mengarah ke `login.html`, link lupa password ke `reset_password.html`; tanpa ini keduanya ditolak.
   - **Authentication → Sign In / Providers → Email**: *Allow new users to sign up* harus **aktif** (dipakai halaman Daftar Akun).
   - **Authentication → Emails → SMTP Settings**: pasang **Custom SMTP** (Resend, Brevo, Gmail SMTP, dll.). SMTP bawaan Supabase hanya untuk uji coba (kuota beberapa email per jam), sehingga email konfirmasi/reset password sering tidak terkirim.
2. **Authentication → Users**: buat akun pengelola pertama.
3. Jadikan akun pertama admin (dan setujui) lewat SQL Editor:

```sql
update public.profiles
set role = 'admin', status = 'approved', jabatan = 'Ketua'
where id = (select id from auth.users where email = 'EMAIL_ADMIN_ANDA');
```

4. Selanjutnya pengguna mendaftar sendiri lewat `register.html` (tombol **Daftar Akun Baru** di halaman login).
   Akun baru berstatus `pending` dan tidak bisa membuka data sampai disetujui admin di menu **Persetujuan User** (`pengguna.html`).
   Jika *Confirm email* aktif di **Authentication → Providers → Email**, pendaftar juga harus mengklik link konfirmasi email dulu;
   tambahkan alamat `login.html` aplikasi ke *Redirect URLs*.

| Role | Untuk | Baca data | Tambah/ubah/hapus | Persetujuan user & Struktur |
| --- | --- | --- | --- | --- |
| admin | Ketua, Wakil Ketua, Sekretaris | Ya | Semua data | Ya |
| pengurus | Pengurus PPG Maksel 2 lainnya | Ya | Semua data | Tidak |
| kelompok | Pengurus kelompok | Ya (LUPG hanya kelompoknya) | LUPG & Dokumentasi kelompoknya | Tidak |
| viewer | Hanya melihat | Ya | Tidak | Tidak |

Status akun: `pending` (menunggu), `approved` (aktif), `rejected` (ditolak/nonaktif). Hanya akun `approved` yang bisa membaca data (dijaga RLS).

## 3. Menghubungkan aplikasi

Isi `assets/config.js` dengan **Project URL** dan **anon/publishable key** dari *Project Settings → API*:

```js
window.SUPABASE_URL = "https://xxxx.supabase.co";
window.SUPABASE_ANON_KEY = "eyJ...";
```

Dengan config.js terisi, semua browser langsung memakai Supabase dan wajib login. Form Supabase di halaman Pengaturan terkunci.
Form itu hanya dipakai untuk mencoba koneksi dari satu browser selama `config.js` masih kosong.

Jangan pernah memasukkan `service_role` key ke browser. Frontend hanya boleh memakai anon/publishable key; hak akses dikendalikan oleh RLS.

## 4. Checklist uji setelah terhubung

- [ ] Login admin berhasil dan halaman mana pun tanpa sesi dialihkan ke `login.html`.
- [ ] CRUD Generus, Absensi, Program Kerja, LUPG, Dokumentasi, Arsip berhasil dan tetap ada setelah reload.
- [ ] Upload foto Dokumentasi dan berkas Arsip, lalu buka/unduh ulang setelah reload (URL ditandatangani ulang setiap data dimuat, berlaku 1 jam).
- [ ] Ganti file Dokumentasi/Arsip lalu hapus data: file lama ikut hilang dari bucket.
- [ ] Login sebagai `viewer`: data terbaca, tetapi simpan/hapus menampilkan pesan "tidak memiliki izin".
- [ ] Daftar akun baru lewat `register.html`: login ditolak dengan pesan "menunggu persetujuan" sampai admin menyetujui di Persetujuan User.
- [ ] Login sebagai user `kelompok`: LUPG hanya menampilkan kelompoknya; bisa menambah LUPG & dokumentasi kelompoknya saja.
- [ ] Program Kerja: upload file RAB Excel, lalu unduh ulang dari detail proker; kalender menampilkan kegiatan bulan berjalan dan muncul di Dashboard.
- [ ] Lupa password: email terkirim, link membuka `reset_password.html`, password baru bisa dipakai login.
- [ ] Dashboard: angka kartu, grafik, kegiatan terdekat, dan dokumen terbaru sesuai data di tabel.

## Kelompok & desa

Daftar 4 desa dan 16 kelompok ada di `assets/wilayah.js`. Untuk menambah atau mengganti kelompok, ubah file itu saja; semua dropdown di aplikasi mengikuti.

## Entitas

- `profiles`
- `generus`
- `absensi`
- `program_kerja`
- `laporan_lupg`: satu baris per kelompok per bulan. Kolom `kehadiran` dan `ketercapaian` berisi persentase per jenjang (`paud`, `k1`–`k6`, `pra_remaja`, `remaja`, `usia_nikah`), plus `hasil_musyawarah` (5 unsur), `kendala`, `keterangan`.
- `dokumentasi`
- `arsip_dokumen`
- `pengaturan_sistem`
- `struktur_pengurus`: struktur kepengurusan pondok; daftar bidangnya menjadi pilihan Bidang & Penanggung Jawab Program Kerja.
- Storage: `ppg-dokumentasi` dan `ppg-arsip` (privat)

Jika schema versi demo pernah dijalankan, script yang sama menghapus policy anonymous lama dan menambahkan kolom integrasi yang belum tersedia.
