-- Migrasi 26 Nov 2026
-- 1) Pastikan profil otomatis dibuat saat registrasi (sebelumnya ada akun tanpa profil → tidak muncul di Persetujuan User).
-- 2) Buat profil untuk akun yang telanjur tidak punya profil (status menunggu persetujuan).
-- 3) Fungsi hapus akun untuk admin: pendaftar yang ditolak dihapus agar emailnya bisa daftar ulang.
-- Jalankan sekali di Supabase Dashboard → SQL Editor. Aman dijalankan ulang.

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

INSERT INTO public.profiles (id, nama, email, no_hp, jabatan, kelompok, desa, role, status)
SELECT u.id,
       COALESCE(NULLIF(u.raw_user_meta_data->>'nama', ''), split_part(u.email, '@', 1)),
       u.email,
       NULLIF(u.raw_user_meta_data->>'no_hp', ''),
       NULLIF(u.raw_user_meta_data->>'jabatan', ''),
       NULLIF(u.raw_user_meta_data->>'kelompok', ''),
       NULLIF(u.raw_user_meta_data->>'desa', ''),
       CASE WHEN NULLIF(u.raw_user_meta_data->>'kelompok', '') IS NULL THEN 'viewer' ELSE 'kelompok' END,
       'pending'
FROM auth.users u
WHERE NOT EXISTS (SELECT 1 FROM public.profiles p WHERE p.id = u.id);

-- Admin menghapus akun (mis. pendaftar yang ditolak) agar emailnya bisa dipakai daftar ulang.
-- Profil ikut terhapus (ON DELETE CASCADE); trigger jaga_admin_terakhir tetap melindungi admin aktif terakhir.
CREATE OR REPLACE FUNCTION public.hapus_pengguna(target UUID) RETURNS void
LANGUAGE plpgsql SECURITY DEFINER SET search_path = public
AS $$
BEGIN
    IF NOT public.is_ppg_admin() THEN RAISE EXCEPTION 'Hanya admin yang dapat menghapus akun.'; END IF;
    IF target = auth.uid() THEN RAISE EXCEPTION 'Tidak bisa menghapus akun Anda sendiri.'; END IF;
    DELETE FROM auth.users WHERE id = target;
END; $$;
REVOKE ALL ON FUNCTION public.hapus_pengguna(UUID) FROM PUBLIC, anon;
GRANT EXECUTE ON FUNCTION public.hapus_pengguna(UUID) TO authenticated;
