-- Impor data LUPG 2024 (Maret, April, Mei, Juni, September) dari laporan Excel Makassar Selatan 2.
-- Jalankan SETELAH schema.sql terbaru. Aman dijalankan ulang: laporan yang sudah ada untuk
-- kelompok + bulan + tahun yang sama akan diperbarui, bukan diduplikasi.
-- Juni 2024: acuan screenshot 6, kelompok yang kosong dilengkapi dari screenshot 7.

-- Hapus baris contoh format lama yang tidak berisi data persentase.
DELETE FROM public.laporan_lupg WHERE kehadiran = '{}'::jsonb AND ketercapaian = '{}'::jsonb;

INSERT INTO public.laporan_lupg (kelompok, desa, bulan, tahun, kehadiran, ketercapaian) VALUES
('Paku', 'Gowata', 'Maret', 2024, '{"paud":0,"k1":0,"k2":0,"k3":5,"k4":2,"k5":1,"k6":3,"pra_remaja":2,"remaja":14,"usia_nikah":2}'::jsonb, '{"paud":0,"k1":0,"k2":0,"k3":80,"k4":78,"k5":77,"k6":72,"pra_remaja":89,"remaja":80,"usia_nikah":84}'::jsonb),
('Turatea', 'Bataraya', 'Maret', 2024, '{"paud":61,"k1":0,"k2":0,"k3":100,"k4":100,"k5":100,"k6":100,"pra_remaja":50,"remaja":70,"usia_nikah":100}'::jsonb, '{"paud":30,"k1":0,"k2":0,"k3":70,"k4":70,"k5":70,"k6":70,"pra_remaja":40,"remaja":45,"usia_nikah":50}'::jsonb),
('Lonrong', 'Babuta', 'Maret', 2024, '{"k2":77,"k4":78,"pra_remaja":78,"remaja":78,"usia_nikah":78}'::jsonb, '{"k2":73,"k4":76,"pra_remaja":72,"remaja":86,"usia_nikah":73}'::jsonb),
('BT.Mattiro', 'Gowata', 'April', 2024, '{"paud":100,"k1":100,"k2":100,"k3":1,"k4":98,"k5":95,"pra_remaja":100,"remaja":90,"usia_nikah":95}'::jsonb, '{"paud":95,"k1":95,"k2":90,"k4":95,"k5":90,"pra_remaja":100,"remaja":100,"usia_nikah":100}'::jsonb),
('Talamangape', 'Gowata', 'April', 2024, '{"k2":65,"k3":66,"k4":68,"k5":68,"pra_remaja":80,"remaja":30,"usia_nikah":30}'::jsonb, '{"k2":60,"k3":60,"k4":70,"k5":70,"pra_remaja":40,"remaja":40}'::jsonb),
('Paku', 'Gowata', 'April', 2024, '{"paud":0,"k1":0,"k2":0,"k3":5,"k4":2,"k5":1,"k6":3,"pra_remaja":2,"remaja":14,"usia_nikah":2}'::jsonb, '{"paud":0,"k1":0,"k2":0,"k3":80,"k4":78,"k5":77,"k6":72,"pra_remaja":89,"remaja":80,"usia_nikah":84}'::jsonb),
('BT.Ramba', 'Bataraya', 'April', 2024, '{"paud":81,"k1":50,"k2":51,"k3":43,"k4":63,"k5":50,"k6":80,"pra_remaja":80,"remaja":81,"usia_nikah":40}'::jsonb, '{"paud":70,"k1":60,"k2":31,"k3":50,"k4":80,"k5":60,"k6":80,"pra_remaja":50,"remaja":70,"usia_nikah":82}'::jsonb),
('Allu', 'Bataraya', 'April', 2024, '{"paud":39,"k1":37,"k2":41,"k3":38,"k4":32,"k5":0,"k6":33,"pra_remaja":32,"remaja":36,"usia_nikah":31}'::jsonb, '{"paud":41,"k1":49,"k2":48,"k3":42,"k4":24,"k5":21,"k6":15,"pra_remaja":29,"remaja":32,"usia_nikah":19}'::jsonb),
('Turatea', 'Bataraya', 'April', 2024, '{"paud":61,"k1":0,"k2":0,"k3":100,"k4":100,"k5":100,"k6":100,"pra_remaja":50,"remaja":70,"usia_nikah":100}'::jsonb, '{"paud":30,"k1":0,"k2":0,"k3":70,"k4":70,"k5":70,"k6":70,"pra_remaja":40,"remaja":45,"usia_nikah":50}'::jsonb),
('Borong Kaluku', 'Babuta', 'April', 2024, '{"k1":35,"k2":80,"k3":80,"k4":80,"pra_remaja":80}'::jsonb, '{"k1":40,"k2":60,"k3":75,"k4":75,"pra_remaja":50}'::jsonb),
('Barembeng', 'Gowata', 'Mei', 2024, '{"paud":80,"k1":77,"k2":85,"k3":80,"k4":85,"k5":86,"k6":80,"pra_remaja":90,"remaja":90,"usia_nikah":49}'::jsonb, '{"paud":65,"k1":65,"k2":70,"k3":60,"k4":70,"k5":70,"k6":70,"pra_remaja":70,"remaja":70,"usia_nikah":70}'::jsonb),
('BT.Mattiro', 'Gowata', 'Mei', 2024, '{"paud":100,"k1":100,"k2":100,"k4":100,"k5":94,"pra_remaja":99,"remaja":91,"usia_nikah":90}'::jsonb, '{"paud":100,"k1":100,"k2":90,"k4":96,"k5":90,"pra_remaja":100,"remaja":100,"usia_nikah":100}'::jsonb),
('Talamangape', 'Gowata', 'Mei', 2024, '{"k2":100,"k3":100,"k4":100,"k5":100,"k6":100,"pra_remaja":100,"remaja":40,"usia_nikah":40}'::jsonb, '{"k2":80,"k3":80,"k4":78,"k5":80,"k6":81,"pra_remaja":50,"remaja":40,"usia_nikah":80}'::jsonb),
('Paku', 'Gowata', 'Mei', 2024, '{"paud":0,"k1":0,"k2":0,"k3":5,"k4":2,"k5":1,"k6":3,"pra_remaja":2,"remaja":14,"usia_nikah":2}'::jsonb, '{"paud":0,"k1":0,"k2":0,"k3":80,"k4":78,"k5":77,"k6":72,"pra_remaja":89,"remaja":80,"usia_nikah":84}'::jsonb),
('BT.Ramba', 'Bataraya', 'Mei', 2024, '{"paud":85,"k1":71,"k3":60,"k4":80,"k5":75,"k6":75,"pra_remaja":80,"remaja":80,"usia_nikah":0}'::jsonb, '{"paud":81,"k1":70,"k2":70,"k3":80,"k4":90,"k5":80,"k6":60,"pra_remaja":76,"remaja":86,"usia_nikah":100}'::jsonb),
('Turatea', 'Bataraya', 'Mei', 2024, '{"paud":61,"k1":0,"k2":0,"k3":100,"k4":100,"k5":100,"k6":100,"pra_remaja":50,"remaja":70,"usia_nikah":100}'::jsonb, '{"paud":30,"k1":0,"k2":0,"k3":70,"k4":70,"k5":70,"k6":70,"pra_remaja":40,"remaja":45,"usia_nikah":50}'::jsonb),
('Bissappu', 'Babuta', 'Mei', 2024, '{"paud":84,"k1":95,"k2":70,"k3":64,"pra_remaja":27,"remaja":35,"usia_nikah":32}'::jsonb, '{"paud":72,"k1":83,"k2":72,"k3":70,"pra_remaja":35,"remaja":47,"usia_nikah":25}'::jsonb),
('Lonrong', 'Babuta', 'Mei', 2024, '{"k2":70,"k4":82,"pra_remaja":78,"remaja":78,"usia_nikah":78}'::jsonb, '{"k2":73,"k4":76,"pra_remaja":75,"remaja":77,"usia_nikah":74}'::jsonb),
('Borong Kaluku', 'Babuta', 'Mei', 2024, '{"k1":35,"k2":80,"k3":81,"k4":80,"pra_remaja":80}'::jsonb, '{"k1":40,"k2":80,"k3":80,"k4":80,"pra_remaja":80}'::jsonb),
('Barembeng', 'Gowata', 'Juni', 2024, '{"paud":70,"k1":70,"k2":80,"k3":56,"k4":80,"k5":50,"k6":81,"pra_remaja":91,"remaja":91,"usia_nikah":50}'::jsonb, '{"paud":60,"k1":60,"k2":60,"k3":60,"k4":70,"k5":60,"k6":75,"pra_remaja":70,"remaja":70,"usia_nikah":40}'::jsonb),
('Talamangape', 'Gowata', 'Juni', 2024, '{"k2":100,"k3":100,"k4":100,"k5":100,"k6":100,"pra_remaja":100,"remaja":40,"usia_nikah":40}'::jsonb, '{"k2":80,"k3":80,"k4":78,"k5":80,"k6":81,"pra_remaja":50,"remaja":81,"usia_nikah":83}'::jsonb),
('Paku', 'Gowata', 'Juni', 2024, '{"paud":0,"k1":0,"k2":0,"k3":5,"k4":2,"k5":1,"k6":3,"pra_remaja":2,"remaja":14,"usia_nikah":2}'::jsonb, '{"paud":0,"k1":0,"k2":0,"k3":80,"k4":78,"k5":77,"k6":72,"pra_remaja":89,"remaja":80,"usia_nikah":84}'::jsonb),
('BT.Ramba', 'Bataraya', 'Juni', 2024, '{"paud":100,"k1":81,"k2":66,"k3":83,"k4":85,"k5":80,"k6":81,"pra_remaja":85,"remaja":92,"usia_nikah":52}'::jsonb, '{"paud":85,"k1":75,"k2":70,"k3":80,"k4":90,"k5":74,"k6":75,"pra_remaja":87,"remaja":80,"usia_nikah":100}'::jsonb),
('Turatea', 'Bataraya', 'Juni', 2024, '{"paud":61,"k1":0,"k2":0,"k3":100,"k4":100,"k5":100,"k6":100,"pra_remaja":50,"remaja":70,"usia_nikah":100}'::jsonb, '{"paud":30,"k1":0,"k2":0,"k3":70,"k4":70,"k5":70,"k6":70,"pra_remaja":40,"remaja":45,"usia_nikah":50}'::jsonb),
('Lonrong', 'Babuta', 'Juni', 2024, '{"k2":79,"k4":82,"pra_remaja":80,"remaja":81,"usia_nikah":78}'::jsonb, '{"k2":80,"k4":82,"pra_remaja":76,"remaja":69,"usia_nikah":75}'::jsonb),
('Balang Butung', 'Selayar', 'Juni', 2024, '{"paud":80,"k1":90,"k2":60,"k3":81,"k4":60,"k5":100,"k6":50,"pra_remaja":60,"remaja":60,"usia_nikah":90}'::jsonb, '{"paud":50,"k1":50,"k2":50,"k3":50,"k4":50,"k5":50,"k6":50,"pra_remaja":50,"remaja":50,"usia_nikah":50}'::jsonb),
('Sengka', 'Gowata', 'Juni', 2024, '{"paud":80,"k1":80,"k2":80,"k3":80,"k4":80,"k6":80,"pra_remaja":80,"remaja":80,"usia_nikah":80}'::jsonb, '{"k1":80,"k2":80,"k3":80,"k4":80,"k5":80,"pra_remaja":80,"remaja":80,"usia_nikah":80}'::jsonb),
('Allu', 'Bataraya', 'Juni', 2024, '{"paud":58,"k1":61,"k2":59,"k3":41,"k4":20,"k5":4,"k6":8,"pra_remaja":34,"remaja":37,"usia_nikah":31}'::jsonb, '{"paud":55,"k1":63,"k2":65,"k3":41,"k4":16,"k5":17,"k6":23,"pra_remaja":30,"remaja":34,"usia_nikah":23}'::jsonb),
('Bissappu', 'Babuta', 'Juni', 2024, '{"paud":50,"k1":25,"k2":55,"k3":60,"pra_remaja":25,"remaja":33,"usia_nikah":44}'::jsonb, '{"paud":75,"k1":45,"k2":85,"k3":55,"pra_remaja":26,"remaja":40,"usia_nikah":30}'::jsonb),
('Borong Kaluku', 'Babuta', 'Juni', 2024, '{"paud":80,"k1":80,"k2":80,"k3":80,"k4":80,"pra_remaja":75}'::jsonb, '{"paud":65,"k1":80,"k2":65,"k3":65,"k4":60,"pra_remaja":45}'::jsonb),
('Benteng', 'Selayar', 'Juni', 2024, '{"paud":90,"k1":90,"k2":90,"k3":90,"k4":90,"k5":80,"pra_remaja":100,"remaja":100,"usia_nikah":70}'::jsonb, '{"paud":80,"k1":80,"k2":70,"k3":85,"k4":90,"pra_remaja":80,"remaja":80,"usia_nikah":70}'::jsonb),
('Turatea', 'Bataraya', 'September', 2024, '{"paud":85,"k4":92,"k5":84,"k6":84,"pra_remaja":84,"remaja":76,"usia_nikah":87}'::jsonb, '{"paud":60,"k1":0,"k4":61,"k5":60,"k6":60,"pra_remaja":50,"remaja":50,"usia_nikah":41}'::jsonb)
ON CONFLICT (kelompok, tahun, bulan) DO UPDATE
SET desa = EXCLUDED.desa, kehadiran = EXCLUDED.kehadiran, ketercapaian = EXCLUDED.ketercapaian;
