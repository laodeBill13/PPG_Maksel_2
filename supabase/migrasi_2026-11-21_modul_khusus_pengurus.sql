-- Migrasi 21 Nov 2026: Absensi, Program Kerja, Dokumentasi & Arsip hanya untuk
-- admin (Ketua/Wakil/Sekretaris) dan pengurus bidang. User Kelompok & Viewer tidak bisa melihatnya.
-- Jalankan sekali di Supabase Dashboard → SQL Editor. Aman dijalankan ulang.

DROP POLICY IF EXISTS "Authenticated read absensi" ON public.absensi;
CREATE POLICY "Authenticated read absensi" ON public.absensi FOR SELECT TO authenticated USING (public.can_manage_ppg());

DROP POLICY IF EXISTS "Authenticated read proker" ON public.program_kerja;
CREATE POLICY "Authenticated read proker" ON public.program_kerja FOR SELECT TO authenticated USING (public.can_manage_ppg());

DROP POLICY IF EXISTS "Authenticated read dokumentasi" ON public.dokumentasi;
CREATE POLICY "Authenticated read dokumentasi" ON public.dokumentasi FOR SELECT TO authenticated USING (public.can_manage_ppg());

DROP POLICY IF EXISTS "Authenticated read arsip" ON public.arsip_dokumen;
CREATE POLICY "Authenticated read arsip" ON public.arsip_dokumen FOR SELECT TO authenticated USING (public.can_manage_ppg());

-- User kelompok tidak lagi menulis dokumentasi.
DROP POLICY IF EXISTS "Kelompok write own dokumentasi" ON public.dokumentasi;

-- File dokumentasi & arsip (termasuk RAB program kerja) hanya untuk pengurus.
DROP POLICY IF EXISTS "Authenticated read PPG files" ON storage.objects;
CREATE POLICY "Authenticated read PPG files" ON storage.objects FOR SELECT TO authenticated
USING (bucket_id IN ('ppg-dokumentasi', 'ppg-arsip') AND public.can_manage_ppg());
DROP POLICY IF EXISTS "Kelompok upload dokumentasi" ON storage.objects;
DROP POLICY IF EXISTS "Kelompok delete own dokumentasi" ON storage.objects;
