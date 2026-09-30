// Data contoh untuk MODE DEMO saja. Hanya dipakai saat localStorage belum pernah diinisialisasi
// dan tidak pernah dipakai saat Supabase aktif.
window.PPG_DEMO_SEED = {
    ppg_maksel2_generus_data: [
        {"id":1,"name":"Ahmad Fauzi","gender":"L","birthDate":"2009-04-12","category":"Remaja","group":"Kelompok A","village":"Barabaraya","phone":"0812-4455-6677","parent":"H. Abdullah","address":"Jl. Mesjid Barabaraya No. 12","status":"Aktif"},
        {"id":2,"name":"Muhammad Ridwan","gender":"L","birthDate":"2006-08-20","category":"Pra Nikah","group":"Kelompok B","village":"Manggala","phone":"0852-9988-1122","parent":"Drs. Usman","address":"Kompleks Manggala Pratama Blok B3","status":"Aktif"},
        {"id":3,"name":"Abdullah Fatih","gender":"L","birthDate":"2016-02-15","category":"Caberawit","group":"Kelompok C","village":"Panakkukang","phone":"0821-3344-5566","parent":"Ibrahim Malik","address":"Jl. Racing Centre No. 44","status":"Tidak Aktif"},
        {"id":4,"name":"Siti Aisyah","gender":"P","birthDate":"2013-11-05","category":"Pra Remaja","group":"Kelompok A","village":"Tamalanrea","phone":"0813-7788-9900","parent":"Drs. Mansyur","address":"Perum Dosen Unhas Tamalanrea","status":"Aktif"},
        {"id":5,"name":"Fathur Rahman","gender":"L","birthDate":"2021-06-18","category":"PAUD","group":"Kelompok D","village":"Biringkanaya","phone":"0853-1122-3344","parent":"M. Yusuf","address":"Jl. Perintis Kemerdekaan KM 18","status":"Aktif"},
        {"id":6,"name":"Nurul Hidayah","gender":"P","birthDate":"2008-01-30","category":"Remaja","group":"Kelompok B","village":"Barabaraya","phone":"0812-9900-1122","parent":"H. Harun","address":"Jl. Kerung-Kerung Lorong 5","status":"Aktif"},
        {"id":7,"name":"Zainal Abidin","gender":"L","birthDate":"2005-09-14","category":"Pra Nikah","group":"Kelompok C","village":"Manggala","phone":"0823-4455-6677","parent":"H. Bakri","address":"Jl. Antang Raya No. 89","status":"Aktif"},
        {"id":8,"name":"Bilal Al-Ghifari","gender":"L","birthDate":"2018-12-10","category":"Caberawit","group":"Kelompok A","village":"Panakkukang","phone":"0812-1133-5577","parent":"Lukman Hakim","address":"Jl. Pengayoman No. 20","status":"Aktif"},
        {"id":9,"name":"Zahra Ramadhani","gender":"P","birthDate":"2022-03-25","category":"PAUD","group":"Kelompok B","village":"Tamalanrea","phone":"0852-6677-8899","parent":"Syamsuddin","address":"BTP Blok AA No. 15","status":"Aktif"},
        {"id":10,"name":"Hasanuddin","gender":"L","birthDate":"2012-07-08","category":"Pra Remaja","group":"Kelompok D","village":"Biringkanaya","phone":"0813-2244-6688","parent":"Amiruddin","address":"Sudiang Raya No. 102","status":"Aktif"},
        {"id":11,"name":"Khadijah Zahra","gender":"P","birthDate":"2009-10-17","category":"Remaja","group":"Kelompok C","village":"Barabaraya","phone":"0821-7788-9911","parent":"H. Ridwan","address":"Jl. Veteran Utara No. 70","status":"Aktif"},
        {"id":12,"name":"Umar Al-Faruq","gender":"L","birthDate":"2015-05-04","category":"Caberawit","group":"Kelompok D","village":"Manggala","phone":"0853-4455-6611","parent":"Zulkifli","address":"Jl. Borong Raya No. 34","status":"Aktif"}
    ],
    ppg_maksel2_absensi_data: [
        {"id":1,"name":"Ahmad Fauzi","category":"Remaja","group":"Kelompok A","village":"Barabaraya","event":"Pengajian Rutin Generus","date":"2026-06-15","time":"08:00","status":"Hadir","notes":"Membawa Al-Quran & Himpunan"},
        {"id":2,"name":"Muhammad Ridwan","category":"Pra Nikah","group":"Kelompok B","village":"Manggala","event":"Musyawaroh Bulanan","date":"2026-06-15","time":"-","status":"Izin","notes":"Sedang dinas luar kota"},
        {"id":3,"name":"Abdullah Fatih","category":"Caberawit","group":"Kelompok C","village":"Panakkukang","event":"Pengajian Rutin Generus","date":"2026-06-15","time":"08:15","status":"Hadir","notes":"Hadir tepat waktu"},
        {"id":4,"name":"Siti Aisyah","category":"Pra Remaja","group":"Kelompok A","village":"Tamalanrea","event":"Evaluasi & Kemandirian","date":"2026-06-14","time":"09:00","status":"Hadir","notes":"Lulus tes hafalan surat"},
        {"id":5,"name":"Fathur Rahman","category":"PAUD","group":"Kelompok D","village":"Biringkanaya","event":"Pengajian Rutin Generus","date":"2026-06-14","time":"-","status":"Sakit","notes":"Demam, izin dari orang tua"},
        {"id":6,"name":"Nurul Hidayah","category":"Remaja","group":"Kelompok B","village":"Barabaraya","event":"Festival Generus Maksel 2","date":"2026-06-12","time":"08:30","status":"Hadir","notes":"Panitia bazar"},
        {"id":7,"name":"Zainal Abidin","category":"Pra Nikah","group":"Kelompok C","village":"Manggala","event":"Musyawaroh Bulanan","date":"2026-06-10","time":"19:45","status":"Hadir","notes":"Notulis rapat"},
        {"id":8,"name":"Bilal Al-Ghifari","category":"Caberawit","group":"Kelompok A","village":"Panakkukang","event":"Pengajian Rutin Generus","date":"2026-06-10","time":"-","status":"Alpha","notes":"Tanpa pemberitahuan"},
        {"id":9,"name":"Zahra Ramadhani","category":"PAUD","group":"Kelompok B","village":"Tamalanrea","event":"Pengajian Rutin Generus","date":"2026-06-08","time":"08:05","status":"Hadir","notes":"Didampingi orang tua"},
        {"id":10,"name":"Hasanuddin","category":"Pra Remaja","group":"Kelompok D","village":"Biringkanaya","event":"Asrama Al-Quran Liburan","date":"2026-06-05","time":"07:30","status":"Hadir","notes":"Target 2 juz tercapai"},
        {"id":11,"name":"Khadijah Zahra","category":"Remaja","group":"Kelompok C","village":"Barabaraya","event":"Pengajian Rutin Generus","date":"2026-06-05","time":"08:00","status":"Hadir","notes":"Petugas pembawa acara"},
        {"id":12,"name":"Umar Al-Faruq","category":"Caberawit","group":"Kelompok D","village":"Manggala","event":"Evaluasi & Kemandirian","date":"2026-06-01","time":"-","status":"Izin","notes":"Acara keluarga di Maros"}
    ],
    proker_data: [
        {"id":1,"nama":"Pembinaan Tahsin Al-Qur'an","kategori":"Pendidikan","status":"Aktif","tanggalMulai":"2026-01-05","tanggalSelesai":"2026-12-31","pj":"Ustadz Fadlillah","prioritas":"Tinggi","progress":75,"deskripsi":"Program peningkatan kualitas bacaan Al-Qur'an dengan metode tahsin rutin setiap minggu untuk seluruh generus.","icon":"fas fa-quran","color":"blue"},
        {"id":2,"nama":"Kajian Rutin Generus","kategori":"Keagamaan","status":"Aktif","tanggalMulai":"2026-01-10","tanggalSelesai":"2026-12-31","pj":"Ahmad Fauzi","prioritas":"Tinggi","progress":65,"deskripsi":"Kegiatan kajian keislaman setiap Ahad pagi untuk membangun karakter dan wawasan generasi muda.","icon":"fas fa-users","color":"emerald"},
        {"id":3,"nama":"Halaqah Ilmu","kategori":"Pendidikan","status":"Aktif","tanggalMulai":"2026-02-01","tanggalSelesai":"2026-11-30","pj":"Budi Santoso","prioritas":"Sedang","progress":45,"deskripsi":"Diskusi dan pembelajaran kitab dasar secara terstruktur dan berkesinambungan.","icon":"fas fa-book-open","color":"amber"},
        {"id":4,"nama":"Gerakan Masjid Aktif","kategori":"Keagamaan","status":"Aktif","tanggalMulai":"2026-01-15","tanggalSelesai":"2026-12-31","pj":"Ridwan Akbar","prioritas":"Tinggi","progress":55,"deskripsi":"Menghidupkan kegiatan masjid dengan berbagai program pemuda, remaja, dan masyarakat sekitar.","icon":"fas fa-mosque","color":"purple"},
        {"id":5,"nama":"Evaluasi Bulanan","kategori":"Organisasi","status":"Aktif","tanggalMulai":"2026-01-28","tanggalSelesai":"2026-12-28","pj":"Ketua Umum","prioritas":"Tinggi","progress":80,"deskripsi":"Monitoring dan evaluasi seluruh program kerja setiap akhir bulan bersama pengurus inti.","icon":"fas fa-calendar-check","color":"red"},
        {"id":6,"nama":"Aksi Sosial Ramadhan","kategori":"Sosial","status":"Selesai","tanggalMulai":"2026-03-01","tanggalSelesai":"2026-04-10","pj":"Divisi Sosial","prioritas":"Sedang","progress":100,"deskripsi":"Aksi sosial pembagian takjil, buka puasa bersama, dan paket sembako untuk warga kurang mampu.","icon":"fas fa-hand-holding-heart","color":"rose"},
        {"id":7,"nama":"Festival Generus 2026","kategori":"Sosial","status":"Aktif","tanggalMulai":"2026-08-17","tanggalSelesai":"2026-08-20","pj":"Divisi Event","prioritas":"Tinggi","progress":30,"deskripsi":"Festival tahunan generus yang menampilkan bakat seni, ilmiah, dan olahraga antar kelompok.","icon":"fas fa-star","color":"indigo"},
        {"id":8,"nama":"Pelatihan Pengurus","kategori":"Organisasi","status":"Selesai","tanggalMulai":"2026-01-20","tanggalSelesai":"2026-02-05","pj":"Ketua Umum","prioritas":"Tinggi","progress":100,"deskripsi":"Pelatihan kepemimpinan dan manajemen organisasi untuk seluruh pengurus baru periode 2026.","icon":"fas fa-graduation-cap","color":"violet"},
        {"id":9,"nama":"Musyawaroh Rutin","kategori":"Organisasi","status":"Aktif","tanggalMulai":"2026-01-05","tanggalSelesai":"2026-12-05","pj":"Sekretaris","prioritas":"Sedang","progress":50,"deskripsi":"Musyawaroh bulanan pengurus untuk membahas perkembangan organisasi dan rencana ke depan.","icon":"fas fa-comments","color":"cyan"},
        {"id":10,"nama":"Kunjungan Sosial","kategori":"Sosial","status":"Selesai","tanggalMulai":"2026-02-14","tanggalSelesai":"2026-02-14","pj":"Divisi Sosial","prioritas":"Rendah","progress":100,"deskripsi":"Kunjungan ke panti asuhan dan orang tua pengurus sebagai wujud kepedulian sosial organisasi.","icon":"fas fa-hands-helping","color":"teal"},
        {"id":11,"nama":"Bakti Sosial Lingkungan","kategori":"Sosial","status":"Pending","tanggalMulai":"2026-09-15","tanggalSelesai":"2026-09-15","pj":"Divisi Sosial","prioritas":"Sedang","progress":0,"deskripsi":"Kegiatan bersih-bersih lingkungan dan penanaman pohon di sekitar masjid dan fasilitas umum.","icon":"fas fa-leaf","color":"green"},
        {"id":12,"nama":"Lomba Tahfidz","kategori":"Pendidikan","status":"Pending","tanggalMulai":"2026-10-10","tanggalSelesai":"2026-10-12","pj":"Divisi Pendidikan","prioritas":"Sedang","progress":0,"deskripsi":"Lomba hafalan Al-Qur'an antar kelompok generus untuk memotivasi dan mengukur perkembangan hafalan.","icon":"fas fa-trophy","color":"orange"}
    ],
    ppg_laporan_data: [
        {"id":1,"tahun":2026,"kelompok":"Kelompok A","bulan":"Januari","target":100,"tercapai":90,"status":"Baik","catatan":"Kehadiran awal tahun sangat antusias."},
        {"id":2,"tahun":2026,"kelompok":"Kelompok B","bulan":"Januari","target":100,"tercapai":78,"status":"Perlu Evaluasi","catatan":"Banyak generus bentrok jadwal les sekolah."},
        {"id":3,"tahun":2026,"kelompok":"Kelompok C","bulan":"Januari","target":100,"tercapai":85,"status":"Baik","catatan":"Penyampaian materi berjalan sesuai target kurikulum."},
        {"id":4,"tahun":2026,"kelompok":"Kelompok D","bulan":"Januari","target":100,"tercapai":62,"status":"Kritis","catatan":"Perlu kunjungan silaturahim ke rumah orang tua santri."},
        {"id":5,"tahun":2026,"kelompok":"Kelompok A","bulan":"Februari","target":100,"tercapai":93,"status":"Baik","catatan":"Tingkat kehadiran stabil meningkat."},
        {"id":6,"tahun":2026,"kelompok":"Kelompok B","bulan":"Februari","target":100,"tercapai":80,"status":"Perlu Evaluasi","catatan":"Evaluasi guru mengajar pra remaja."},
        {"id":7,"tahun":2026,"kelompok":"Kelompok C","bulan":"Februari","target":100,"tercapai":88,"status":"Baik","catatan":"Kegiatan kajian mandiri berjalan lancar."},
        {"id":8,"tahun":2026,"kelompok":"Kelompok D","bulan":"Februari","target":100,"tercapai":65,"status":"Kritis","catatan":"Beberapa santri izin berhalangan sakit."},
        {"id":9,"tahun":2026,"kelompok":"Kelompok A","bulan":"Agustus","target":100,"tercapai":95,"status":"Baik","catatan":"Program asrama liburan tuntas dengan baik."},
        {"id":10,"tahun":2026,"kelompok":"Kelompok B","bulan":"Agustus","target":100,"tercapai":82,"status":"Perlu Evaluasi","catatan":"Peningkatan target hafalan dalil Al-Qur'an."},
        {"id":11,"tahun":2026,"kelompok":"Kelompok C","bulan":"Agustus","target":100,"tercapai":91,"status":"Baik","catatan":"Seluruh pengurus kelompok aktif membimbing."},
        {"id":12,"tahun":2026,"kelompok":"Kelompok D","bulan":"Agustus","target":100,"tercapai":67,"status":"Kritis","catatan":"Diadakan musyawarah khusus pengurus dan orang tua."}
    ],
    ppg_dokumentasi_data: [
        {"id":1,"judul":"Kajian Bulanan Generus","kategori":"Kajian","tanggal":"2026-06-10","lokasi":"Makassar","fotoCount":12,"deskripsi":"Kajian rutin bulanan bersama generasi muda di masjid kawasan Maksel 2.","imageUrl":"https://picsum.photos/600/400?random=10"},
        {"id":2,"judul":"Bakti Sosial Ramadhan","kategori":"Bakti Sosial","tanggal":"2026-05-15","lokasi":"Gowa","fotoCount":18,"deskripsi":"Kegiatan berbagi kepada masyarakat sekitar dan warga binaan.","imageUrl":"https://picsum.photos/600/400?random=11"},
        {"id":3,"judul":"Pelatihan Kepemimpinan Generus","kategori":"Pelatihan","tanggal":"2026-04-22","lokasi":"Maros","fotoCount":24,"deskripsi":"Pelatihan peningkatan kapasitas anggota dan kader kepemimpinan muda.","imageUrl":"https://picsum.photos/600/400?random=12"},
        {"id":4,"judul":"Musyawaroh Triwulan Pengurus","kategori":"Musyawaroh","tanggal":"2026-03-05","lokasi":"Makassar","fotoCount":8,"deskripsi":"Evaluasi program kerja triwulan pertama dan perencanaan kurikulum semester.","imageUrl":"https://picsum.photos/600/400?random=13"},
        {"id":5,"judul":"Outing Generus Akhir Tahun","kategori":"Outing","tanggal":"2026-02-20","lokasi":"Bantimurung","fotoCount":32,"deskripsi":"Wisata edukasi sekaligus refreshing untuk para santri dan generus.","imageUrl":"https://picsum.photos/600/400?random=14"},
        {"id":6,"judul":"Pengajian Akbar Awal Tahun","kategori":"Kajian","tanggal":"2026-01-10","lokasi":"Makassar","fotoCount":45,"deskripsi":"Pengajian akbar awal tahun diikuti 200+ generus dari seluruh wilayah.","imageUrl":"https://picsum.photos/600/400?random=15"}
    ],
    ppg_arsip_data: [
        {"id":1,"nama":"LUPG_Agustus_2026.pdf","kategori":"Laporan LUPG","tipe":"PDF","ukuran":"2.4 MB","tanggal":"2026-08-25","catatan":"Laporan bulanan pembinaan generus Agustus."},
        {"id":2,"nama":"Rekap_Absensi_Q2.xlsx","kategori":"Data Generus","tipe":"Excel","ukuran":"1.8 MB","tanggal":"2026-08-20","catatan":"Data presensi kuartal kedua seluruh kelompok."},
        {"id":3,"nama":"SK_Pengurus_2026.docx","kategori":"SK & Surat","tipe":"Word","ukuran":"420 KB","tanggal":"2026-08-18","catatan":"Surat Keputusan struktur kepengurusan PPG Maksel 2."},
        {"id":4,"nama":"Laporan_Proker_Semester1.pdf","kategori":"Dokumentasi","tipe":"PDF","ukuran":"5.1 MB","tanggal":"2026-08-15","catatan":"Evaluasi capaian proker semester ganjil."},
        {"id":5,"nama":"Data_Santri_Baru_2026.xlsx","kategori":"Data Generus","tipe":"Excel","ukuran":"950 KB","tanggal":"2026-08-12","catatan":"Pendaftaran santri baru tingkat PAUD dan Caberawit."},
        {"id":6,"nama":"Surat_Edaran_Asrama_Liburan.pdf","kategori":"SK & Surat","tipe":"PDF","ukuran":"310 KB","tanggal":"2026-08-05","catatan":"Pemberitahuan asrama liburan Al-Qur'an dan Hadits."}
    ]
};
