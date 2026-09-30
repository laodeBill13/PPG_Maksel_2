# Setup Supabase PPG Maksel 2

## 1. Database

1. Buat project Supabase, lalu buka **SQL Editor**.
2. Jalankan seluruh isi `schema.sql`. Script ini membuat tabel, indeks, profil pengguna, trigger `updated_at`, bucket Storage privat (maks. 50 MB per file), dan RLS.
   Script aman dijalankan ulang untuk migrasi: data contoh Program Kerja dan LUPG hanya diisi saat tabelnya masih kosong.

## 2. Auth

1. **Authentication → URL Configuration**
   - *Site URL*: alamat aplikasi setelah deploy, misalnya `https://ppg-maksel2.example.com/login.html`.
   - *Redirect URLs*: tambahkan `https://ppg-maksel2.example.com/reset_password.html` (dan `http://127.0.0.1:4173/reset_password.html` untuk uji lokal). Tanpa ini, link reset password dari email ditolak.
2. **Authentication → Users**: buat akun pengelola pertama.
3. Jadikan akun pertama admin lewat SQL Editor:

```sql
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'EMAIL_ADMIN_ANDA');
```

Akun baru otomatis mendapat role `viewer` (hanya baca). Untuk memberi akses tulis:

```sql
update public.profiles set role = 'pengurus'
where id = (select id from auth.users where email = 'EMAIL_PENGURUS');
```

| Role | Baca data | Tambah/ubah/hapus data | Ubah Pengaturan organisasi | Ubah role pengguna |
| --- | --- | --- | --- | --- |
| admin | Ya | Ya | Ya | Ya |
| pengurus | Ya | Ya | Tidak | Tidak |
| viewer | Ya | Tidak | Tidak | Tidak |

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
- [ ] Lupa password: email terkirim, link membuka `reset_password.html`, password baru bisa dipakai login.
- [ ] Dashboard: angka kartu, grafik, kegiatan terdekat, dan dokumen terbaru sesuai data di tabel.

## Entitas

- `profiles`
- `generus`
- `absensi`
- `program_kerja`
- `laporan_lupg`
- `dokumentasi`
- `arsip_dokumen`
- `pengaturan_sistem`
- Storage: `ppg-dokumentasi` dan `ppg-arsip` (privat)

Jika schema versi demo pernah dijalankan, script yang sama menghapus policy anonymous lama dan menambahkan kolom integrasi yang belum tersedia.
