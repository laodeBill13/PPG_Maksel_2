---
name: supabase-integration
description: Guidelines and conventions for Supabase backend integration in PPG Maksel 2 web app, including PostgreSQL schema design, Row Level Security (RLS), and frontend client integration.
---

# Supabase Integration Guidelines for PPG Maksel 2

This skill defines the schema design, client configuration, and data synchronization patterns for Supabase in this project.

## Database Entities & Architecture

### 1. `generus` (Santri & Generasi Penerus)
- Primary key: `id` (UUID or BigSerial)
- Fields:
  - `nama`: VARCHAR NOT NULL
  - `gender`: CHAR(1) ('L' / 'P')
  - `tanggal_lahir`: DATE
  - `kategori`: VARCHAR ('PAUD', 'Caberawit', 'Pra Remaja', 'Remaja', 'Pra Nikah')
  - `kelompok`: VARCHAR ('A', 'B', 'C', 'D')
  - `desa`: VARCHAR (default 'Maksel 2')
  - `nama_ortu`: VARCHAR
  - `no_hp`: VARCHAR
  - `alamat`: TEXT
  - `status`: VARCHAR ('Aktif', 'Alumni', 'Pindah')
  - `created_at`: TIMESTAMPTZ DEFAULT now()

### 2. `absensi` (Catatan Presensi Generus)
- Primary key: `id`
- Foreign keys: `generus_id` references `generus(id)`
- Fields:
  - `kegiatan`: VARCHAR (e.g. 'Pengajian Rutin', 'Asrama Liburan', 'Kajian Mandiri')
  - `tanggal`: DATE DEFAULT CURRENT_DATE
  - `kelompok`: VARCHAR
  - `status`: VARCHAR ('Hadir', 'Izin', 'Sakit', 'Alpha')
  - `catatan`: TEXT
  - `petugas`: VARCHAR

### 3. `program_kerja` (Manajemen Kegiatan & Proker)
- Primary key: `id`
- Fields:
  - `nama_proker`: VARCHAR NOT NULL
  - `bidang`: VARCHAR ('Kurikulum', 'Keputrian', 'Tahfidz', 'Bina Bakat', 'Sarpras')
  - `tanggal_mulai`: DATE
  - `tanggal_selesai`: DATE
  - `pic`: VARCHAR
  - `status`: VARCHAR ('Belum Mulai', 'Berjalan', 'Selesai', 'Ditunda')
  - `progress`: INT DEFAULT 0 (0-100%)
  - `anggaran`: NUMERIC DEFAULT 0
  - `deskripsi`: TEXT

### 4. `laporan_lupg` (Laporan Usaha Pembinaan Generus)
- Primary key: `id`
- Fields:
  - `kelompok`: VARCHAR
  - `bulan`: VARCHAR
  - `tahun`: INT
  - `target_peserta`: INT
  - `tercapai_peserta`: INT
  - `persentase`: NUMERIC
  - `status_pencapaian`: VARCHAR ('Baik', 'Perlu Evaluasi', 'Kritis')
  - `catatan_evaluasi`: TEXT
  - `file_lampiran_url`: TEXT

### 5. `arsip_dokumen` & `dokumentasi`
- Secure storage bucket: `ppg-arsip`, `ppg-dokumentasi`
- Metadata tables for file indexing, category filters, and download links.

## Client Integration Pattern (Hybrid Offline-First)

Every screen connects to Supabase via `assets/supabase-client.js`:
- If Supabase credentials (`SUPABASE_URL` and `SUPABASE_ANON_KEY`) are configured, live queries are executed.
- If running in preview/offline mode or credentials are blank, seamless fallback to `localStorage` preserves full mock UI functionality without crashing.
