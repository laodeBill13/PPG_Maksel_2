-- ==============================================================================
-- DATABASE SCHEMA: PPG MAKSEL 2 (Sistem Informasi & Pembinaan Generus)
-- Compatible with Supabase PostgreSQL (SQL Editor / Migrations)
-- ==============================================================================

-- Enable UUID extension if not already enabled
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Profil pengguna mengikuti akun Supabase Auth.
CREATE TABLE IF NOT EXISTS public.profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    nama VARCHAR(150),
    role VARCHAR(30) NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin', 'pengurus', 'kelompok', 'viewer')),
    -- Akun hasil registrasi menunggu persetujuan admin (Ketua/Wakil/Sekretaris) sebelum bisa membuka data.
    status VARCHAR(20) NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
    email VARCHAR(150),
    no_hp VARCHAR(30),
    jabatan VARCHAR(100),
    kelompok VARCHAR(50),
    desa VARCHAR(50),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Migrasi profil lama: akun yang sudah ada dianggap disetujui agar admin lama tidak terkunci.
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS status VARCHAR(20) NOT NULL DEFAULT 'approved';
ALTER TABLE public.profiles ALTER COLUMN status SET DEFAULT 'pending';
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_status_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_status_check CHECK (status IN ('pending', 'approved', 'rejected'));
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS email VARCHAR(150);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS no_hp VARCHAR(30);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS jabatan VARCHAR(100);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS kelompok VARCHAR(50);
ALTER TABLE public.profiles ADD COLUMN IF NOT EXISTS desa VARCHAR(50);
ALTER TABLE public.profiles DROP CONSTRAINT IF EXISTS profiles_role_check;
ALTER TABLE public.profiles ADD CONSTRAINT profiles_role_check CHECK (role IN ('admin', 'pengurus', 'kelompok', 'viewer'));
UPDATE public.profiles p SET email = u.email FROM auth.users u WHERE p.id = u.id AND p.email IS NULL;

-- ==============================================================================
-- 1. TABEL: GENERUS (Database Generasi Penerus)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.generus (
    id BIGSERIAL PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    gender VARCHAR(1) NOT NULL CHECK (gender IN ('L', 'P')),
    tanggal_lahir DATE,
    kategori VARCHAR(50) NOT NULL CHECK (kategori IN ('PAUD', 'Caberawit', 'Pra Remaja', 'Remaja', 'Usia Nikah')),
    kelompok VARCHAR(50) NOT NULL,
    desa VARCHAR(100) DEFAULT 'Maksel 2',
    nama_ortu VARCHAR(150),
    no_hp VARCHAR(30),
    alamat TEXT,
    status VARCHAR(30) DEFAULT 'Aktif' CHECK (status IN ('Aktif', 'Alumni', 'Pindah', 'Nonaktif')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_generus_kategori ON public.generus(kategori);
CREATE INDEX IF NOT EXISTS idx_generus_kelompok ON public.generus(kelompok);
CREATE INDEX IF NOT EXISTS idx_generus_nama ON public.generus USING gin (to_tsvector('indonesian', nama));
-- Daftar kelompok dikelola aplikasi (assets/wilayah.js), bukan dikunci di database.
ALTER TABLE public.generus DROP CONSTRAINT IF EXISTS generus_kelompok_check;
-- Jenjang "Pra Nikah" diganti "Usia Nikah" (mengikuti format LUPG).
ALTER TABLE public.generus DROP CONSTRAINT IF EXISTS generus_kategori_check;
UPDATE public.generus SET kategori = 'Usia Nikah' WHERE kategori = 'Pra Nikah';
ALTER TABLE public.generus ADD CONSTRAINT generus_kategori_check CHECK (kategori IN ('PAUD', 'Caberawit', 'Pra Remaja', 'Remaja', 'Usia Nikah'));

-- ==============================================================================
-- 2. TABEL: ABSENSI (Presensi Kehadiran Pengurus)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.absensi (
    id BIGSERIAL PRIMARY KEY,
    generus_id BIGINT REFERENCES public.generus(id) ON DELETE SET NULL,
    nama_generus VARCHAR(150) NOT NULL,
    kategori VARCHAR(50),
    kegiatan VARCHAR(150) NOT NULL,
    tanggal DATE NOT NULL DEFAULT CURRENT_DATE,
    kelompok VARCHAR(50) NOT NULL,
    desa VARCHAR(100) DEFAULT 'Maksel 2',
    waktu TIME,
    status VARCHAR(20) NOT NULL CHECK (status IN ('Hadir', 'Izin', 'Sakit', 'Alpha')),
    catatan TEXT,
    dicatat_oleh VARCHAR(100) DEFAULT 'Admin',
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_absensi_tanggal ON public.absensi(tanggal);
CREATE INDEX IF NOT EXISTS idx_absensi_kegiatan ON public.absensi(kegiatan);
CREATE INDEX IF NOT EXISTS idx_absensi_kelompok ON public.absensi(kelompok);

-- Migrasi aman bila schema versi awal pernah dijalankan.
ALTER TABLE public.absensi ADD COLUMN IF NOT EXISTS kategori VARCHAR(50);
ALTER TABLE public.absensi ADD COLUMN IF NOT EXISTS desa VARCHAR(100) DEFAULT 'Maksel 2';
ALTER TABLE public.absensi ADD COLUMN IF NOT EXISTS waktu TIME;
UPDATE public.absensi SET kategori = 'Usia Nikah' WHERE kategori = 'Pra Nikah';
-- Absensi dipakai untuk kehadiran pengurus; kolom nama_generus berisi nama pengurus.
ALTER TABLE public.absensi ADD COLUMN IF NOT EXISTS jabatan VARCHAR(100);
COMMENT ON TABLE public.absensi IS 'Kehadiran pengurus: Musyawarah Pengurus, Penyampaian PPG Pusat, Penyampaian PPG Daerah';

-- ==============================================================================
-- 3. TABEL: PROGRAM_KERJA (Manajemen Program Kerja & Kegiatan PPG)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.program_kerja (
    id BIGSERIAL PRIMARY KEY,
    nama_proker VARCHAR(200) NOT NULL,
    bidang VARCHAR(100) NOT NULL,
    tanggal_mulai DATE,
    tanggal_selesai DATE,
    pic VARCHAR(150) NOT NULL,
    status VARCHAR(50) DEFAULT 'Pending' CHECK (status IN ('Aktif', 'Pending', 'Selesai', 'Ditunda')),
    prioritas VARCHAR(20) DEFAULT 'Sedang' CHECK (prioritas IN ('Tinggi', 'Sedang', 'Rendah')),
    progress INT DEFAULT 0 CHECK (progress >= 0 AND progress <= 100),
    anggaran NUMERIC(15,2) DEFAULT 0,
    deskripsi TEXT,
    icon VARCHAR(100) DEFAULT 'fas fa-tasks',
    warna VARCHAR(30) DEFAULT 'blue',
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_proker_bidang ON public.program_kerja(bidang);
CREATE INDEX IF NOT EXISTS idx_proker_status ON public.program_kerja(status);
ALTER TABLE public.program_kerja DROP CONSTRAINT IF EXISTS program_kerja_bidang_check;
ALTER TABLE public.program_kerja DROP CONSTRAINT IF EXISTS program_kerja_status_check;
UPDATE public.program_kerja SET status = CASE WHEN status = 'Berjalan' THEN 'Aktif' WHEN status = 'Belum Mulai' THEN 'Pending' ELSE status END;
ALTER TABLE public.program_kerja ALTER COLUMN status SET DEFAULT 'Pending';
ALTER TABLE public.program_kerja ADD CONSTRAINT program_kerja_status_check CHECK (status IN ('Aktif', 'Pending', 'Selesai', 'Ditunda'));
ALTER TABLE public.program_kerja ADD COLUMN IF NOT EXISTS prioritas VARCHAR(20) DEFAULT 'Sedang';
ALTER TABLE public.program_kerja ADD COLUMN IF NOT EXISTS icon VARCHAR(100) DEFAULT 'fas fa-tasks';
ALTER TABLE public.program_kerja ADD COLUMN IF NOT EXISTS warna VARCHAR(30) DEFAULT 'blue';

-- ==============================================================================
-- 4. TABEL: LAPORAN_LUPG (Rekap Laporan Usaha Pembinaan Generus)
-- ==============================================================================
-- Satu laporan per kelompok per bulan. Nilai berupa persentase (0-100) per jenjang:
-- kunci paud, k1..k6 (kelas Caberawit), pra_remaja, remaja, usia_nikah. Jenjang yang tidak dilaporkan tidak disimpan.
CREATE TABLE IF NOT EXISTS public.laporan_lupg (
    id BIGSERIAL PRIMARY KEY,
    kelompok VARCHAR(50) NOT NULL,
    desa VARCHAR(50),
    bulan VARCHAR(30) NOT NULL,
    tahun INT NOT NULL DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::int,
    kehadiran JSONB NOT NULL DEFAULT '{}'::jsonb,
    ketercapaian JSONB NOT NULL DEFAULT '{}'::jsonb,
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- Migrasi dari format lama (target/tercapai per kelompok).
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS desa VARCHAR(50);
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS kehadiran JSONB NOT NULL DEFAULT '{}'::jsonb;
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS ketercapaian JSONB NOT NULL DEFAULT '{}'::jsonb;
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS updated_at TIMESTAMPTZ DEFAULT now();
ALTER TABLE public.laporan_lupg DROP COLUMN IF EXISTS persentase;
ALTER TABLE public.laporan_lupg DROP COLUMN IF EXISTS target_peserta;
ALTER TABLE public.laporan_lupg DROP COLUMN IF EXISTS tercapai_peserta;
ALTER TABLE public.laporan_lupg DROP COLUMN IF EXISTS status;
ALTER TABLE public.laporan_lupg ALTER COLUMN tahun SET DEFAULT EXTRACT(YEAR FROM CURRENT_DATE)::int;
DROP INDEX IF EXISTS public.idx_lupg_periode;
CREATE UNIQUE INDEX IF NOT EXISTS uq_lupg_kelompok_periode ON public.laporan_lupg(kelompok, tahun, bulan);

-- ==============================================================================
-- 5. TABEL: DOKUMENTASI (Galeri Foto & Dokumentasi Kegiatan)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.dokumentasi (
    id BIGSERIAL PRIMARY KEY,
    judul VARCHAR(200) NOT NULL,
    kategori VARCHAR(100) NOT NULL,
    tanggal DATE DEFAULT CURRENT_DATE,
    jumlah_foto INT DEFAULT 1,
    lokasi VARCHAR(150),
    image_url TEXT,
    storage_path TEXT,
    deskripsi TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS lokasi VARCHAR(150);
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS storage_path TEXT;

-- ==============================================================================
-- 6. TABEL: ARSIP_DOKUMEN (Berkas Digital & Dokumen Organisasi)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.arsip_dokumen (
    id BIGSERIAL PRIMARY KEY,
    judul VARCHAR(200) NOT NULL,
    kategori VARCHAR(100) NOT NULL,
    tipe_file VARCHAR(20) DEFAULT 'PDF',
    ukuran_file VARCHAR(30),
    tanggal DATE DEFAULT CURRENT_DATE,
    file_url TEXT,
    storage_path TEXT,
    catatan TEXT,
    diunggah_oleh VARCHAR(100) DEFAULT 'Admin',
    created_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.arsip_dokumen ADD COLUMN IF NOT EXISTS storage_path TEXT;
ALTER TABLE public.arsip_dokumen ADD COLUMN IF NOT EXISTS catatan TEXT;
ALTER TABLE public.arsip_dokumen ADD COLUMN IF NOT EXISTS tanggal DATE DEFAULT CURRENT_DATE;

-- ==============================================================================
-- 7. TABEL: PENGATURAN_SISTEM (Profil & Konfigurasi PPG Maksel 2)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.pengaturan_sistem (
    id VARCHAR(50) PRIMARY KEY DEFAULT 'config_utama',
    nama_organisasi VARCHAR(150) DEFAULT 'PPG Maksel 2',
    deskripsi TEXT,
    wilayah VARCHAR(100) DEFAULT 'Makassar Selatan 2',
    tahun_kepengurusan VARCHAR(30) DEFAULT '2026/2027',
    email_admin VARCHAR(100) DEFAULT 'admin@ppgmaksel2.org',
    notifikasi_wa BOOLEAN DEFAULT true,
    backup_otomatis BOOLEAN DEFAULT true,
    updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.pengaturan_sistem ADD COLUMN IF NOT EXISTS deskripsi TEXT;

-- ==============================================================================
-- 8. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================================
ALTER TABLE public.generus ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.absensi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.program_kerja ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.laporan_lupg ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.dokumentasi ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.arsip_dokumen ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.pengaturan_sistem ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.profiles ENABLE ROW LEVEL SECURITY;

-- Hapus policy development/versi lama agar migrasi tidak meninggalkan akses anon.
DROP POLICY IF EXISTS "Allow public read generus" ON public.generus;
DROP POLICY IF EXISTS "Allow public read absensi" ON public.absensi;
DROP POLICY IF EXISTS "Allow public read proker" ON public.program_kerja;
DROP POLICY IF EXISTS "Allow public read lupg" ON public.laporan_lupg;
DROP POLICY IF EXISTS "Allow public read dokumentasi" ON public.dokumentasi;
DROP POLICY IF EXISTS "Allow public read arsip" ON public.arsip_dokumen;
DROP POLICY IF EXISTS "Allow public read pengaturan" ON public.pengaturan_sistem;
DROP POLICY IF EXISTS "Allow anon insert generus" ON public.generus;
DROP POLICY IF EXISTS "Allow anon update generus" ON public.generus;
DROP POLICY IF EXISTS "Allow anon delete generus" ON public.generus;
DROP POLICY IF EXISTS "Allow anon write absensi" ON public.absensi;
DROP POLICY IF EXISTS "Allow anon write proker" ON public.program_kerja;
DROP POLICY IF EXISTS "Allow anon write lupg" ON public.laporan_lupg;
DROP POLICY IF EXISTS "Allow anon write dokumentasi" ON public.dokumentasi;
DROP POLICY IF EXISTS "Allow anon write arsip" ON public.arsip_dokumen;
DROP POLICY IF EXISTS "Allow anon write pengaturan" ON public.pengaturan_sistem;
DROP POLICY IF EXISTS "Authenticated read generus" ON public.generus;
DROP POLICY IF EXISTS "Authenticated read absensi" ON public.absensi;
DROP POLICY IF EXISTS "Authenticated read proker" ON public.program_kerja;
DROP POLICY IF EXISTS "Authenticated read lupg" ON public.laporan_lupg;
DROP POLICY IF EXISTS "Authenticated read dokumentasi" ON public.dokumentasi;
DROP POLICY IF EXISTS "Authenticated read arsip" ON public.arsip_dokumen;
DROP POLICY IF EXISTS "Authenticated read pengaturan" ON public.pengaturan_sistem;
DROP POLICY IF EXISTS "Managers write generus" ON public.generus;
DROP POLICY IF EXISTS "Managers write absensi" ON public.absensi;
DROP POLICY IF EXISTS "Managers write proker" ON public.program_kerja;
DROP POLICY IF EXISTS "Managers write lupg" ON public.laporan_lupg;
DROP POLICY IF EXISTS "Managers write dokumentasi" ON public.dokumentasi;
DROP POLICY IF EXISTS "Managers write arsip" ON public.arsip_dokumen;
DROP POLICY IF EXISTS "Admins write pengaturan" ON public.pengaturan_sistem;
DROP POLICY IF EXISTS "Users read own profile" ON public.profiles;

-- Hak akses. Semua fungsi mensyaratkan akun sudah disetujui (status = 'approved').
-- admin    : Ketua, Wakil Ketua, Sekretaris — CRUD semua data + persetujuan user.
-- pengurus : CRUD semua data.
-- kelompok : baca data; tulis LUPG & Dokumentasi hanya untuk kelompoknya sendiri.
-- viewer   : baca saja.
CREATE OR REPLACE FUNCTION public.is_approved() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND status = 'approved') $$;

CREATE OR REPLACE FUNCTION public.can_manage_ppg() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND status = 'approved' AND role IN ('admin', 'pengurus')) $$;

CREATE OR REPLACE FUNCTION public.is_ppg_admin() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND status = 'approved' AND role = 'admin') $$;

CREATE OR REPLACE FUNCTION public.is_kelompok_user() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND status = 'approved' AND role = 'kelompok') $$;

CREATE OR REPLACE FUNCTION public.my_kelompok() RETURNS VARCHAR
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT kelompok FROM public.profiles WHERE id = auth.uid() AND status = 'approved' $$;

-- Seluruh data aplikasi hanya dapat dibaca oleh pengguna yang sudah login dan disetujui.
CREATE POLICY "Authenticated read generus" ON public.generus FOR SELECT TO authenticated USING (public.is_approved());
CREATE POLICY "Authenticated read absensi" ON public.absensi FOR SELECT TO authenticated USING (public.is_approved());
CREATE POLICY "Authenticated read proker" ON public.program_kerja FOR SELECT TO authenticated USING (public.is_approved());
-- User kelompok hanya melihat laporan kelompoknya sendiri.
CREATE POLICY "Authenticated read lupg" ON public.laporan_lupg FOR SELECT TO authenticated
USING (public.is_approved() AND (NOT public.is_kelompok_user() OR kelompok = public.my_kelompok()));
CREATE POLICY "Authenticated read dokumentasi" ON public.dokumentasi FOR SELECT TO authenticated USING (public.is_approved());
CREATE POLICY "Authenticated read arsip" ON public.arsip_dokumen FOR SELECT TO authenticated USING (public.is_approved());
CREATE POLICY "Authenticated read pengaturan" ON public.pengaturan_sistem FOR SELECT TO authenticated USING (public.is_approved());


CREATE POLICY "Managers write generus" ON public.generus FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write absensi" ON public.absensi FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write proker" ON public.program_kerja FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write lupg" ON public.laporan_lupg FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write dokumentasi" ON public.dokumentasi FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write arsip" ON public.arsip_dokumen FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Admins write pengaturan" ON public.pengaturan_sistem FOR ALL TO authenticated
USING (public.is_ppg_admin()) WITH CHECK (public.is_ppg_admin());
-- Data pribadi pengguna (email, no HP) hanya untuk pemiliknya dan admin.
CREATE POLICY "Users read own profile" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid() OR public.is_ppg_admin());
-- User kelompok mengisi LUPG kelompoknya sendiri.
DROP POLICY IF EXISTS "Kelompok write own lupg" ON public.laporan_lupg;
CREATE POLICY "Kelompok write own lupg" ON public.laporan_lupg FOR ALL TO authenticated
USING (public.is_kelompok_user() AND kelompok = public.my_kelompok())
WITH CHECK (public.is_kelompok_user() AND kelompok = public.my_kelompok());
-- Admin dapat mengubah nama/role pengguna lain (manajemen hak akses).
DROP POLICY IF EXISTS "Admins update profiles" ON public.profiles;
CREATE POLICY "Admins update profiles" ON public.profiles FOR UPDATE TO authenticated
USING (public.is_ppg_admin()) WITH CHECK (public.is_ppg_admin());

-- updated_at otomatis diperbarui setiap baris diubah.
CREATE OR REPLACE FUNCTION public.set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;
-- Pengaman: selalu harus ada minimal satu admin aktif, agar sistem tidak terkunci.
CREATE OR REPLACE FUNCTION public.jaga_admin_terakhir() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    IF OLD.role = 'admin' AND OLD.status = 'approved'
       AND (TG_OP = 'DELETE' OR NEW.role <> 'admin' OR NEW.status <> 'approved')
       AND NOT EXISTS (SELECT 1 FROM public.profiles WHERE id <> OLD.id AND role = 'admin' AND status = 'approved') THEN
        RAISE EXCEPTION 'Tidak bisa: ini admin aktif terakhir. Jadikan pengguna lain admin terlebih dahulu.';
    END IF;
    RETURN COALESCE(NEW, OLD);
END; $$;
DROP TRIGGER IF EXISTS jaga_admin_terakhir ON public.profiles;
CREATE TRIGGER jaga_admin_terakhir BEFORE UPDATE OR DELETE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.jaga_admin_terakhir();
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.generus;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.generus FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.program_kerja;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.program_kerja FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.laporan_lupg;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.laporan_lupg FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.pengaturan_sistem;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.pengaturan_sistem FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Buat profil otomatis dari form registrasi (status pending). Role TIDAK diambil dari metadata
-- (bisa dipalsukan klien): pendaftar kelompok menjadi 'kelompok', lainnya 'viewer'; admin menyesuaikan saat menyetujui.
-- Akun pertama perlu dinaikkan menjadi admin lewat SQL Editor.
CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
DECLARE meta JSONB := COALESCE(new.raw_user_meta_data, '{}'::jsonb);
BEGIN
    INSERT INTO public.profiles (id, nama, email, no_hp, jabatan, kelompok, desa, role, status)
    VALUES (
        new.id,
        COALESCE(NULLIF(meta->>'nama', ''), split_part(new.email, '@', 1)),
        new.email,
        NULLIF(meta->>'no_hp', ''),
        NULLIF(meta->>'jabatan', ''),
        NULLIF(meta->>'kelompok', ''),
        NULLIF(meta->>'desa', ''),
        CASE WHEN NULLIF(meta->>'kelompok', '') IS NULL THEN 'viewer' ELSE 'kelompok' END,
        'pending'
    );
    RETURN new;
END; $$;
DROP TRIGGER IF EXISTS on_auth_user_created ON auth.users;
CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();

-- Storage buckets dan policy file.
-- Bucket privat: file hanya bisa diakses lewat signed URL yang dibuat aplikasi. Batas 50 MB per file.
INSERT INTO storage.buckets (id, name, public, file_size_limit) VALUES ('ppg-dokumentasi', 'ppg-dokumentasi', false, 52428800), ('ppg-arsip', 'ppg-arsip', false, 52428800)
ON CONFLICT (id) DO UPDATE SET public = EXCLUDED.public, file_size_limit = EXCLUDED.file_size_limit;
DROP POLICY IF EXISTS "Authenticated read PPG files" ON storage.objects;
DROP POLICY IF EXISTS "Managers upload PPG files" ON storage.objects;
DROP POLICY IF EXISTS "Managers update PPG files" ON storage.objects;
DROP POLICY IF EXISTS "Managers delete PPG files" ON storage.objects;
CREATE POLICY "Authenticated read PPG files" ON storage.objects FOR SELECT TO authenticated USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.is_approved());
CREATE POLICY "Managers upload PPG files" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());
CREATE POLICY "Managers update PPG files" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());
CREATE POLICY "Managers delete PPG files" ON storage.objects FOR DELETE TO authenticated USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());
-- User kelompok boleh mengunggah foto dokumentasi dan menghapus file unggahannya sendiri.
DROP POLICY IF EXISTS "Kelompok upload dokumentasi" ON storage.objects;
DROP POLICY IF EXISTS "Kelompok delete own dokumentasi" ON storage.objects;
CREATE POLICY "Kelompok upload dokumentasi" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id = 'ppg-dokumentasi' AND public.is_kelompok_user());
CREATE POLICY "Kelompok delete own dokumentasi" ON storage.objects FOR DELETE TO authenticated USING (bucket_id = 'ppg-dokumentasi' AND public.is_kelompok_user() AND owner = auth.uid());

-- ==============================================================================
-- 9. INITIAL SEED DATA
-- ==============================================================================
-- Profil Default
INSERT INTO public.pengaturan_sistem (id, nama_organisasi, wilayah, tahun_kepengurusan, email_admin)
VALUES ('config_utama', 'PPG Maksel 2', 'Makassar Selatan 2', '2026/2027', 'admin@ppgmaksel2.org')
ON CONFLICT (id) DO NOTHING;

-- Sample Program Kerja (hanya diisi saat tabel masih kosong, aman dijalankan ulang)
INSERT INTO public.program_kerja (nama_proker, bidang, tanggal_mulai, tanggal_selesai, pic, status, progress, anggaran, deskripsi)
SELECT * FROM (VALUES
('Musyawarah Bulanan Pengurus', 'Organisasi', DATE '2026-08-01', DATE '2026-08-02', 'Ustadz Ridwan', 'Selesai', 100, 1500000, 'Koordinasi rutin evaluasi pembinaan generus'),
('Asrama Al-Qur''an & Hadits Liburan', 'Pendidikan', '2026-08-10', '2026-08-25', 'H. Ahmad Fauzi', 'Aktif', 75, 8500000, 'Penguatan pemahaman dalil bagi generus Remaja & Pra Nikah'),
('Pelatihan Mengajar Guru PAUD & Caberawit', 'Pendidikan', '2026-09-05', '2026-09-07', 'Ibu Nurul Aini', 'Pending', 0, 3200000, 'Peningkatan kompetensi pedagogik guru generus usia dini'),
('Turnamen Futsal & Fun Gathering Generus', 'Sosial', '2026-09-15', '2026-09-16', 'Bima Sakti', 'Pending', 0, 4500000, 'Ajang keakraban antar kelompok di wilayah Maksel 2')
) AS seed(nama_proker, bidang, tanggal_mulai, tanggal_selesai, pic, status, progress, anggaran, deskripsi)
WHERE NOT EXISTS (SELECT 1 FROM public.program_kerja);

-- Data LUPG asli diimpor lewat supabase/import_lupg_2024.sql.

-- ==============================================================================
-- 10. FITUR LANJUTAN: RAB Proker, Musyawarah LUPG, Dokumentasi Kelompok, Struktur
-- ==============================================================================
-- Program Kerja: RAB berupa nominal (kolom anggaran) + berkas Excel RAB di bucket ppg-arsip.
ALTER TABLE public.program_kerja ADD COLUMN IF NOT EXISTS rab_path TEXT;
ALTER TABLE public.program_kerja ADD COLUMN IF NOT EXISTS rab_nama VARCHAR(200);
ALTER TABLE public.program_kerja ADD COLUMN IF NOT EXISTS lokasi VARCHAR(150);

-- LUPG: hasil musyawarah 5 unsur, kendala, dan keterangan per kelompok per bulan.
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS hasil_musyawarah TEXT;
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS kendala TEXT;
ALTER TABLE public.laporan_lupg ADD COLUMN IF NOT EXISTS keterangan TEXT;

-- Dokumentasi: asal kelompok & tingkatan pengajian, plus link Google Drive untuk album besar.
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS kelompok VARCHAR(50);
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS desa VARCHAR(50);
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS tingkatan VARCHAR(50);
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS drive_url TEXT;
ALTER TABLE public.dokumentasi ADD COLUMN IF NOT EXISTS diunggah_oleh UUID DEFAULT auth.uid();
CREATE INDEX IF NOT EXISTS idx_dokumentasi_kelompok ON public.dokumentasi(kelompok, tingkatan);

DROP POLICY IF EXISTS "Kelompok write own dokumentasi" ON public.dokumentasi;
CREATE POLICY "Kelompok write own dokumentasi" ON public.dokumentasi FOR ALL TO authenticated
USING (public.is_kelompok_user() AND kelompok = public.my_kelompok())
WITH CHECK (public.is_kelompok_user() AND kelompok = public.my_kelompok());

-- Struktur kepengurusan pondok. level: 1 Pimpinan, 2 Pengurus Harian, 3 Koordinator Bidang, 4 Anggota Bidang.
-- Daftar bidang di sini juga menjadi pilihan Bidang & Penanggung Jawab pada form Program Kerja.
CREATE TABLE IF NOT EXISTS public.struktur_pengurus (
    id BIGSERIAL PRIMARY KEY,
    jabatan VARCHAR(100) NOT NULL,
    bidang VARCHAR(100),
    nama VARCHAR(150),
    no_hp VARCHAR(30),
    level SMALLINT NOT NULL DEFAULT 3 CHECK (level BETWEEN 1 AND 4),
    urutan INT NOT NULL DEFAULT 0,
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);
ALTER TABLE public.struktur_pengurus ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "Authenticated read struktur" ON public.struktur_pengurus;
DROP POLICY IF EXISTS "Admins write struktur" ON public.struktur_pengurus;
CREATE POLICY "Authenticated read struktur" ON public.struktur_pengurus FOR SELECT TO authenticated USING (public.is_approved());
CREATE POLICY "Admins write struktur" ON public.struktur_pengurus FOR ALL TO authenticated USING (public.is_ppg_admin()) WITH CHECK (public.is_ppg_admin());
DROP TRIGGER IF EXISTS set_updated_at ON public.struktur_pengurus;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.struktur_pengurus FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

INSERT INTO public.struktur_pengurus (jabatan, bidang, nama, level, urutan)
SELECT * FROM (VALUES
('Ketua', NULL, NULL, 1, 1),
('Wakil Ketua', NULL, NULL, 2, 1),
('Sekretaris', NULL, NULL, 2, 2),
('Bendahara', NULL, NULL, 2, 3),
('Koordinator', 'Pendidikan', NULL, 3, 1),
('Koordinator', 'Keagamaan', NULL, 3, 2),
('Koordinator', 'Organisasi', NULL, 3, 3),
('Koordinator', 'Sosial', NULL, 3, 4)
) AS seed(jabatan, bidang, nama, level, urutan)
WHERE NOT EXISTS (SELECT 1 FROM public.struktur_pengurus);
