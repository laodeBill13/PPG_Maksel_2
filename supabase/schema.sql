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
    role VARCHAR(30) NOT NULL DEFAULT 'viewer' CHECK (role IN ('admin', 'pengurus', 'viewer')),
    created_at TIMESTAMPTZ DEFAULT now(),
    updated_at TIMESTAMPTZ DEFAULT now()
);

-- ==============================================================================
-- 1. TABEL: GENERUS (Database Santri & Generasi Penerus)
-- ==============================================================================
CREATE TABLE IF NOT EXISTS public.generus (
    id BIGSERIAL PRIMARY KEY,
    nama VARCHAR(150) NOT NULL,
    gender VARCHAR(1) NOT NULL CHECK (gender IN ('L', 'P')),
    tanggal_lahir DATE,
    kategori VARCHAR(50) NOT NULL CHECK (kategori IN ('PAUD', 'Caberawit', 'Pra Remaja', 'Remaja', 'Pra Nikah')),
    kelompok VARCHAR(50) NOT NULL CHECK (kelompok IN ('Kelompok A', 'Kelompok B', 'Kelompok C', 'Kelompok D', 'A', 'B', 'C', 'D')),
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

-- ==============================================================================
-- 2. TABEL: ABSENSI (Presensi Kehadiran Generus)
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
CREATE TABLE IF NOT EXISTS public.laporan_lupg (
    id BIGSERIAL PRIMARY KEY,
    kelompok VARCHAR(50) NOT NULL,
    bulan VARCHAR(30) NOT NULL,
    tahun INT NOT NULL DEFAULT 2026,
    target_peserta INT NOT NULL DEFAULT 100,
    tercapai_peserta INT NOT NULL DEFAULT 0,
    persentase INT GENERATED ALWAYS AS (ROUND((tercapai_peserta::numeric / NULLIF(target_peserta, 0)::numeric) * 100)) STORED,
    status VARCHAR(50) DEFAULT 'Baik' CHECK (status IN ('Baik', 'Perlu Evaluasi', 'Kritis')),
    catatan TEXT,
    created_at TIMESTAMPTZ DEFAULT now()
);

CREATE INDEX IF NOT EXISTS idx_lupg_periode ON public.laporan_lupg(bulan, tahun);

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

-- Seluruh data aplikasi hanya dapat dibaca oleh pengguna yang sudah login.
CREATE POLICY "Authenticated read generus" ON public.generus FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read absensi" ON public.absensi FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read proker" ON public.program_kerja FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read lupg" ON public.laporan_lupg FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read dokumentasi" ON public.dokumentasi FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read arsip" ON public.arsip_dokumen FOR SELECT TO authenticated USING (true);
CREATE POLICY "Authenticated read pengaturan" ON public.pengaturan_sistem FOR SELECT TO authenticated USING (true);

-- Admin dan pengurus dapat menjalankan CRUD. Viewer hanya dapat membaca.
CREATE OR REPLACE FUNCTION public.can_manage_ppg() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role IN ('admin', 'pengurus')) $$;

CREATE OR REPLACE FUNCTION public.is_ppg_admin() RETURNS BOOLEAN
LANGUAGE sql STABLE SECURITY DEFINER SET search_path = public
AS $$ SELECT EXISTS (SELECT 1 FROM public.profiles WHERE id = auth.uid() AND role = 'admin') $$;

CREATE POLICY "Managers write generus" ON public.generus FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write absensi" ON public.absensi FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write proker" ON public.program_kerja FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write lupg" ON public.laporan_lupg FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write dokumentasi" ON public.dokumentasi FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Managers write arsip" ON public.arsip_dokumen FOR ALL TO authenticated USING (public.can_manage_ppg()) WITH CHECK (public.can_manage_ppg());
CREATE POLICY "Admins write pengaturan" ON public.pengaturan_sistem FOR ALL TO authenticated
USING (public.is_ppg_admin()) WITH CHECK (public.is_ppg_admin());
CREATE POLICY "Users read own profile" ON public.profiles FOR SELECT TO authenticated USING (id = auth.uid() OR public.can_manage_ppg());
-- Admin dapat mengubah nama/role pengguna lain (manajemen hak akses).
DROP POLICY IF EXISTS "Admins update profiles" ON public.profiles;
CREATE POLICY "Admins update profiles" ON public.profiles FOR UPDATE TO authenticated
USING (public.is_ppg_admin()) WITH CHECK (public.is_ppg_admin());

-- updated_at otomatis diperbarui setiap baris diubah.
CREATE OR REPLACE FUNCTION public.set_updated_at() RETURNS trigger
LANGUAGE plpgsql AS $$ BEGIN NEW.updated_at = now(); RETURN NEW; END; $$;
DROP TRIGGER IF EXISTS set_updated_at ON public.profiles;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.profiles FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.generus;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.generus FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.program_kerja;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.program_kerja FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();
DROP TRIGGER IF EXISTS set_updated_at ON public.pengaturan_sistem;
CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.pengaturan_sistem FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

-- Buat profil otomatis. Akun pertama perlu dinaikkan menjadi admin lewat SQL Editor.
CREATE OR REPLACE FUNCTION public.handle_new_user() RETURNS trigger
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$ BEGIN INSERT INTO public.profiles (id, nama) VALUES (new.id, COALESCE(new.raw_user_meta_data->>'nama', split_part(new.email, '@', 1))); RETURN new; END; $$;
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
CREATE POLICY "Authenticated read PPG files" ON storage.objects FOR SELECT TO authenticated USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip'));
CREATE POLICY "Managers upload PPG files" ON storage.objects FOR INSERT TO authenticated WITH CHECK (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());
CREATE POLICY "Managers update PPG files" ON storage.objects FOR UPDATE TO authenticated USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());
CREATE POLICY "Managers delete PPG files" ON storage.objects FOR DELETE TO authenticated USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());

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

-- Sample LUPG Data (hanya diisi saat tabel masih kosong, aman dijalankan ulang)
INSERT INTO public.laporan_lupg (kelompok, bulan, tahun, target_peserta, tercapai_peserta, status, catatan)
SELECT * FROM (VALUES
('Kelompok A', 'Agustus', 2026, 100, 95, 'Baik', 'Tingkat kehadiran stabil di atas 90%'),
('Kelompok B', 'Agustus', 2026, 100, 82, 'Perlu Evaluasi', 'Beberapa peserta berhalangan karena ujian sekolah'),
('Kelompok C', 'Agustus', 2026, 100, 91, 'Baik', 'Pelaksanaan materi kurikulum tuntas tepat waktu'),
('Kelompok D', 'Agustus', 2026, 100, 67, 'Kritis', 'Perlu koordinasi intensif dengan orang tua santri')
) AS seed(kelompok, bulan, tahun, target_peserta, tercapai_peserta, status, catatan)
WHERE NOT EXISTS (SELECT 1 FROM public.laporan_lupg);
