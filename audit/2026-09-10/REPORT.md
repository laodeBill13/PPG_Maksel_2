# Audit UI dan CRUD — 10 September 2026

**Status: BELUM AMAN untuk dinyatakan siap produksi.** Audit ini tidak mengubah kode aplikasi.

## Metode dan cakupan

- Chrome headless melalui Playwright, server lokal 127.0.0.1:4173, browser context terisolasi tanpa profil pengguna.
- Seluruh **11 halaman HTML**, masing-masing pada viewport 375, 768, dan 1440 px: 33 pemeriksaan render. Koreksi terhadap estimasi awal 12 halaman.
- Tidak ada error JavaScript saat halaman pertama kali dimuat pada 33 pemeriksaan. Ini bukan bukti seluruh interaksi bebas error.
- Pemeriksaan overflow dokumen, nama aksesibel tombol, referensi handler inline, screenshot, drawer Escape, dan modal Escape/reopen.
- CRUD diuji dengan mengisi elemen form lalu memanggil handler halaman, membaca hasil dari gateway, reload, update, dan delete. Ini pengujian integrasi browser; tidak membuktikan semua tombol/form native validation telah diuji end-to-end melalui klik.
- Data uji hanya berada pada localStorage context browser sementara. Tidak ada data Supabase atau browser pengguna yang diubah.
- Live read failure disimulasikan dengan gateway yang melempar error; bukan koneksi Supabase sungguhan.

## Hasil CRUD demo

| Modul | Create | Read setelah reload | Update | Delete | Tetap kosong setelah reload |
| --- | --- | --- | --- | --- | --- |
| Generus | Lolos | Lolos | Lolos | Lolos | Gagal: seed muncul lagi |
| Absensi | Lolos | Lolos | Lolos | Lolos | Gagal: seed muncul lagi |
| Program Kerja | Lolos | Lolos | Lolos | Lolos | Lolos |
| LUPG | Lolos | Lolos | Lolos | Lolos | Lolos |
| Dokumentasi | Lolos | Lolos | Lolos | Lolos | Lolos |
| Arsip | Lolos | Lolos | Lolos | Lolos | Lolos |

Profil organisasi Pengaturan berhasil disimpan dan dibaca kembali. Arsip create menggunakan file PDF dummy di browser terisolasi; dokumentasi menggunakan URL gambar uji. Keutuhan download file dan upload Storage live belum diverifikasi.

## Temuan prioritas

1. **Tinggi — Stored XSS pada Generus, terkonfirmasi runtime.** Nama berupa elemen HTML dengan handler onerror tersimpan dan dieksekusi ketika tabel dirender. Uji hanya memasang boolean window.auditInjected, tanpa membaca atau mengirim data. Lokasi: database_generus.html, renderTable sekitar baris 1140; pola interpolasi innerHTML juga perlu diaudit pada modul lain. Rendering harus memakai textContent atau escaping sesuai konteks, termasuk atribut dan inline handler.
2. **Tinggi — Data demo tampil saat baca live gagal.** Simulasi PPG_DB.isLive() true dan service.list() melempar error masih menyisakan 6 arsip, 6 dokumentasi, 12 LUPG, dan 12 program contoh. Lokasi: loadArsipData (arsip.html:505), loadDokData (dokumentasi.html:411), loadLupgData (laporan.html:625), loadPrograms (program_kerja.html:841). Perlu error state eksplisit, tanpa fallback demo pada mode live.
3. **Sedang — Data kosong tidak persisten.** database_generus.html:1048 dan absensi.html:1001 menganggap array kosong sebagai alasan mengisi seed. Menghapus seluruh data lalu reload mengembalikan data contoh. Bedakan storage belum pernah diinisialisasi dengan array kosong yang sah.
4. **Sedang — Reset Pengaturan rusak.** pengaturan.html memanggil openModal/closeModal, tetapi kedua fungsi tidak tersedia pada halaman tersebut. Klik reset gagal membuka dialog; doReset juga memanggil closeModal yang tidak tersedia.
5. **Sedang — Modal berubah layout setelah Escape.** assets/sidebar.js menghapus class flex saat Escape. Program Kerja, LUPG, Dokumentasi, Arsip hanya menghapus hidden saat membuka lagi, sehingga computed display menjadi block. Escape menutup semua modal yang diuji, tetapi pembukaan ulang kehilangan flex centering.
6. **Sedang — Overflow halaman publik.** index.html melebar pada 375 px. login.html dan lupa_password.html melebar pada ketiga viewport; screenshot menunjukkan dekorasi melewati tepi viewport. Delapan halaman aplikasi lainnya tidak mengalami overflow dokumen pada pengujian.
7. **Sedang — Header tabel Absensi tidak sejajar pada mobile.** th kelompok/kegiatan/tanggal disembunyikan berdasarkan breakpoint, sedangkan td terkait tetap tampil (absensi.html:529–535 vs 1146–1162). Header Status terlihat di atas isi kelompok. Scroll tabel tidak memperbaiki ketidakcocokan kolom ini.
8. **Sedang — Angka ringkasan masih bercampur data statis.** Screenshot dashboard menunjukkan total Generus 0 tetapi ringkasan/diagram 528; arsip menampilkan 185 berkas sementara tabel berisi 6. loadDashboardSummary hanya memperbarui tiga penghitung. Kartu/diagram LUPG juga memakai angka contoh dan tidak semuanya mengikuti CRUD.
9. **Sedang — Reset password belum lengkap berdasarkan kode.** Email recovery diarahkan ke login.html; tidak ditemukan form password baru, penanganan PASSWORD_RECOVERY, atau pemanggilan updateUser password pada repository. Pengiriman email live dan penyelesaian recovery belum diuji.
10. **Sedang — Urutan operasi file berisiko berdasarkan kode.** Arsip menghapus file lama sebelum update metadata selesai; Arsip/Dokumentasi menghapus file sebelum delete row. Jika operasi DB berikutnya gagal, metadata dapat tertinggal menunjuk file yang hilang. Penggantian gambar Dokumentasi juga belum membersihkan file lama. Belum diuji terhadap Storage sungguhan.
11. **Aksesibilitas — Banyak tombol ikon tidak memiliki nama aksesibel.** Terdeteksi pada navigasi mobile, dashboard, program kerja, login, dan pengaturan. Banyak kontrol berukuran 32–40 px belum memenuhi target skill 44 px. Ini pemeriksaan terbatas, bukan audit WCAG penuh.
12. **Kelengkapan produk — index.html masih halaman demo agregat.** Kalender di index berupa contoh, belum ada screen kalender mandiri. Daftar fitur dalam fitur.md mencakup upload Excel LUPG, video/album, logo, dan manajemen hak akses yang belum seluruhnya diwujudkan. Pengaturan pengguna mengarah ke dashboard Supabase, sementara daftar akun UI masih statis.

## Per halaman

| Halaman | Hasil utama |
| --- | --- |
| index | Demo agregat; overflow mobile |
| login | Render tanpa error awal; overflow; recovery belum lengkap |
| lupa_password | Render tanpa error awal; overflow; kirim email live belum diuji |
| dashboard | Drawer/modal Escape lolos; statistik dan konten masih campur contoh |
| database_generus | CRUD dasar lolos; XSS dan reseed data kosong gagal |
| absensi | CRUD dasar lolos; reseed data kosong dan kolom mobile bermasalah |
| program_kerja | CRUD dasar lolos; error live menampilkan demo; modal reopen block |
| laporan | CRUD dasar lolos; error live menampilkan demo; KPI statis; modal reopen block |
| dokumentasi | CRUD dasar lolos; error live menampilkan demo; modal reopen block |
| arsip | CRUD dasar lolos; error live menampilkan demo; modal reopen block |
| pengaturan | Simpan organisasi lolos; fungsi modal reset hilang |

## Batas verifikasi

Belum ada konfigurasi atau akun Supabase staging yang disediakan untuk pengujian ini. RLS admin/pengurus/viewer, CRUD database live, Storage, sesi auth nyata, pengiriman email, dan migrasi SQL belum bisa dinyatakan lolos. Peninjauan schema tidak menggantikan uji role secara nyata. Semua filter, ekspor, download, keyboard focus, kontras, loading state, dan klik setiap kontrol belum diuji secara menyeluruh.

## Bukti dan reproduksi

- results.json: 33 hasil viewport.
- crud-results.json: hasil integrasi handler CRUD dan persistensi.
- edge-results.json: simulasi read error, XSS, drawer, dan modal.
- audit.cjs, crud.cjs, edge.cjs: skrip audit yang dipakai; membutuhkan Playwright dan Google Chrome. Jalankan dari root project dengan server lokal di port 4173. Skrip saat ini menulis output ke /tmp/ppg-ui-audit; sesuaikan lokasi bila diperlukan.
- Screenshot asli tersedia selama sesi di /tmp/ppg-ui-audit/screens/.

Prioritas perbaikan: XSS dan pemisahan demo/live; persistensi data kosong; modal/reset; UI tabel dan overflow; konsistensi ringkasan; lalu pengujian Supabase staging dan fitur yang belum lengkap.
