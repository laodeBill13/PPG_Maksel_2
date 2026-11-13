// Konfigurasi Supabase untuk deploy. Isi dua nilai di bawah dari Supabase Dashboard → Project Settings → API.
// Jika terisi, semua browser otomatis memakai Supabase (mode live) dan isian di halaman Pengaturan diabaikan.
// Jika dibiarkan kosong, aplikasi berjalan dalam mode demo (localStorage) atau memakai isian dari halaman Pengaturan.
// Gunakan HANYA anon/publishable key. Jangan pernah menaruh service_role key di sini.
window.SUPABASE_URL = "https://zpjkpawfpjmtokntfnfl.supabase.co";
window.SUPABASE_ANON_KEY = "sb_publishable_e4X603CJCDsIzXfur8do4w_sfiGPSZ2";

// Domain production (mis. "https://ppg-maksel2.vercel.app"). Link di email daftar akun & lupa password
// selalu diarahkan ke sini. Kosongkan untuk memakai alamat halaman yang sedang dibuka.
window.APP_URL = "";
