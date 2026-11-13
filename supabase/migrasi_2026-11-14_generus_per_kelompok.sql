-- Migrasi 14 Nov 2026: User Kelompok hanya bisa melihat data generus kelompoknya sendiri.
-- Jalankan sekali di Supabase Dashboard → SQL Editor. Aman dijalankan ulang.
DROP POLICY IF EXISTS "Authenticated read generus" ON public.generus;
CREATE POLICY "Authenticated read generus" ON public.generus FOR SELECT TO authenticated
USING (public.is_approved() AND (NOT public.is_kelompok_user() OR kelompok = public.my_kelompok()));
