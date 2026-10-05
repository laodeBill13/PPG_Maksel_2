// Central data gateway for PPG Maksel 2: Supabase live mode + local demo mode.
(function (window) {
    "use strict";
    const URL_KEY = "ppg_supabase_url";
    const ANON_KEY = "ppg_supabase_key";
    const DEMO_SESSION = "ppg_demo_session";
    const PAGE_SIZE = 1000; // batas default baris per request PostgREST
    const SIGNED_URL_TTL = 60 * 60; // 1 jam; URL ditandatangani ulang setiap data dimuat
    // assets/config.js (deploy) mengalahkan isian halaman Pengaturan (per browser).
    const fileConfigured = Boolean(window.SUPABASE_URL && window.SUPABASE_ANON_KEY);
    const config = fileConfigured
        ? { url: window.SUPABASE_URL, key: window.SUPABASE_ANON_KEY }
        : { url: localStorage.getItem(URL_KEY) || "", key: localStorage.getItem(ANON_KEY) || "" };
    let client = null;

    function initClient() {
        client = null;
        if (config.url && config.key && window.supabase?.createClient) {
            client = window.supabase.createClient(config.url, config.key, { auth: { persistSession: true, autoRefreshToken: true, detectSessionInUrl: true } });
        }
        return client;
    }
    function setConfig(url, key) {
        if (fileConfigured) throw new Error("Konfigurasi Supabase dikunci oleh assets/config.js.");
        config.url = String(url || "").trim(); config.key = String(key || "").trim();
        localStorage.setItem(URL_KEY, config.url); localStorage.setItem(ANON_KEY, config.key);
        return Boolean(initClient());
    }

    // Mode demo: key yang belum pernah ada diisi data contoh sekali. Array kosong adalah data sah dan tidak di-seed ulang.
    function readLocal(key) {
        const raw = localStorage.getItem(key);
        if (raw === null) {
            const seed = window.PPG_DEMO_SEED?.[key];
            if (!seed) return [];
            const rows = seed.map(row => ({ ...row }));
            writeLocal(key, rows);
            return rows;
        }
        try { const rows = JSON.parse(raw); return Array.isArray(rows) ? rows : []; } catch { return []; }
    }
    function writeLocal(key, rows) {
        try { localStorage.setItem(key, JSON.stringify(rows)); }
        catch (error) { throw new Error(error?.name === "QuotaExceededError" ? "Penyimpanan browser penuh. Gunakan berkas lebih kecil atau hubungkan Supabase." : error.message); }
    }
    const normalizeId = id => Number.isFinite(Number(id)) ? Number(id) : id;
    const put = (object, key, value) => { if (value !== undefined) object[key] = value; return object; };
    // Kolom DATE/TIME/INT di Postgres menolak string kosong.
    const orNull = value => value === "" ? null : value;
    // Kolom ber-DEFAULT (mis. tanggal DEFAULT CURRENT_DATE): kosong = tidak dikirim, agar default database berlaku.
    const orDefault = value => value === "" || value === null ? undefined : value;
    const numOrUndef = value => value === undefined ? undefined : (value === "" || value === null ? null : Number(value));

    // Pesan error Supabase/PostgREST yang bisa dipahami pengguna.
    function friendlyError(error) {
        const code = error?.code;
        if (code === "42501" || /row-level security/i.test(error?.message || "")) return new Error("Akun Anda tidak memiliki izin untuk mengubah data ini.");
        if (code === "PGRST116") return new Error("Data tidak ditemukan atau akun Anda tidak memiliki izin mengubahnya.");
        if (code === "23505") return new Error("Data untuk periode/kelompok ini sudah ada.");
        if (code === "23514") return new Error(`Nilai tidak sesuai aturan database (${error.message}).`);
        if (code === "22007" || code === "22P02") return new Error(`Format data tidak valid (${error.message}).`);
        return error instanceof Error ? error : new Error(error?.message || "Terjadi kesalahan pada database.");
    }

    async function signRows(rows, bucket, urlField, pathField = "storagePath") {
        const paths = rows.map(row => row[pathField]).filter(Boolean);
        if (!client || !bucket || !paths.length) return rows;
        const { data, error } = await client.storage.from(bucket).createSignedUrls(paths, SIGNED_URL_TTL);
        if (error) { console.warn("Signed URL gagal dibuat:", error.message); return rows; }
        const byPath = new Map((data || []).filter(x => x.signedUrl).map(x => [x.path, x.signedUrl]));
        return rows.map(row => byPath.has(row[pathField]) ? { ...row, [urlField]: byPath.get(row[pathField]) } : row);
    }

    function service({ table, key, toDb, fromDb, order = "id", bucket, urlField, pathField }) {
        return {
            async list() {
                if (!client) return readLocal(key);
                const rows = [];
                for (let from = 0; ; from += PAGE_SIZE) {
                    const { data, error } = await client.from(table).select("*").order(order, { ascending: false }).range(from, from + PAGE_SIZE - 1);
                    if (error) throw friendlyError(error);
                    rows.push(...(data || []));
                    if (!data || data.length < PAGE_SIZE) break;
                }
                return signRows(rows.map(fromDb), bucket, urlField, pathField);
            },
            async insert(item) {
                if (client) {
                    const { data, error } = await client.from(table).insert(toDb(item)).select().single();
                    if (error) throw friendlyError(error);
                    return (await signRows([fromDb(data)], bucket, urlField, pathField))[0];
                }
                const rows = readLocal(key); const created = { id: Date.now(), ...item };
                rows.unshift(created); writeLocal(key, rows); return created;
            },
            async update(id, fields) {
                if (client) {
                    const { data, error } = await client.from(table).update(toDb(fields)).eq("id", normalizeId(id)).select().single();
                    if (error) throw friendlyError(error);
                    return (await signRows([fromDb(data)], bucket, urlField, pathField))[0];
                }
                const rows = readLocal(key); const index = rows.findIndex(row => String(row.id) === String(id));
                if (index < 0) throw new Error("Data tidak ditemukan");
                rows[index] = { ...rows[index], ...fields }; writeLocal(key, rows); return rows[index];
            },
            async delete(id) {
                if (client) {
                    // RLS tidak melempar error saat baris tidak boleh dihapus; ia hanya menghapus 0 baris.
                    const { data, error } = await client.from(table).delete().eq("id", normalizeId(id)).select("id");
                    if (error) throw friendlyError(error);
                    if (!data?.length) throw new Error("Data tidak ditemukan atau akun Anda tidak memiliki izin menghapusnya.");
                }
                else writeLocal(key, readLocal(key).filter(row => String(row.id) !== String(id)));
                return true;
            }
        };
    }

    const generusFromDb = r => ({ id:r.id,name:r.nama,gender:r.gender,birthDate:r.tanggal_lahir,category:r.kategori,group:r.kelompok,village:r.desa,phone:r.no_hp,parent:r.nama_ortu,address:r.alamat,status:r.status === "Nonaktif" ? "Tidak Aktif" : r.status,createdAt:r.created_at });
    const generusToDb = r => {
        const x={}; put(x,"nama",r.name); put(x,"gender",r.gender); put(x,"tanggal_lahir",orNull(r.birthDate));
        put(x,"kategori",r.category); put(x,"kelompok",r.group); put(x,"desa",r.village); put(x,"no_hp",r.phone); put(x,"nama_ortu",r.parent); put(x,"alamat",r.address);
        put(x,"status",r.status === "Tidak Aktif" ? "Nonaktif" : r.status); return x;
    };
    // Absensi = kehadiran PENGURUS (Musyawarah Pengurus, Penyampaian PPG Pusat/Daerah). Kolom nama_generus menyimpan nama pengurus.
    const absensiFromDb = r => ({ id:r.id,name:r.nama_generus,jabatan:r.jabatan,group:r.kelompok,village:r.desa,event:r.kegiatan,date:r.tanggal,time:r.waktu ? String(r.waktu).slice(0,5) : "-",status:r.status,notes:r.catatan,officer:r.dicatat_oleh });
    const absensiToDb = r => {
        const x={}; put(x,"nama_generus",r.name); put(x,"jabatan",r.jabatan); put(x,"kelompok",r.group); put(x,"desa",r.village);
        put(x,"kegiatan",r.event); put(x,"tanggal",orDefault(r.date)); put(x,"waktu",r.time === "-" ? null : orNull(r.time)); put(x,"status",r.status); put(x,"catatan",r.notes); put(x,"dicatat_oleh",r.officer); return x;
    };
    // RAB: nominal di kolom anggaran + berkas Excel RAB (rabPath di bucket ppg-arsip, rabUrl = signed URL).
    const prokerFromDb = r => ({ id:r.id,nama:r.nama_proker,kategori:r.bidang,status:r.status,tanggalMulai:r.tanggal_mulai,tanggalSelesai:r.tanggal_selesai,pj:r.pic,prioritas:r.prioritas,progress:r.progress,anggaran:r.anggaran,deskripsi:r.deskripsi,icon:r.icon,color:r.warna,lokasi:r.lokasi,rabPath:r.rab_path,rabNama:r.rab_nama });
    const prokerToDb = r => { const x={}; put(x,"nama_proker",r.nama); put(x,"bidang",r.kategori); put(x,"status",r.status); put(x,"tanggal_mulai",orNull(r.tanggalMulai)); put(x,"tanggal_selesai",orNull(r.tanggalSelesai)); put(x,"pic",r.pj); put(x,"prioritas",r.prioritas); put(x,"progress",numOrUndef(r.progress)); put(x,"anggaran",r.anggaran === undefined ? undefined : Number(r.anggaran)||0); put(x,"deskripsi",r.deskripsi); put(x,"icon",r.icon); put(x,"warna",r.color); put(x,"lokasi",r.lokasi); put(x,"rab_path",r.rabPath); put(x,"rab_nama",r.rabNama); return x; };
    // LUPG: persentase kehadiran & ketercapaian materi per jenjang, satu laporan per kelompok per bulan.
    const LUPG_JENJANG = [["paud","PAUD"],["k1","1"],["k2","2"],["k3","3"],["k4","4"],["k5","5"],["k6","6"],["pra_remaja","Pra Remaja"],["remaja","Remaja"],["usia_nikah","Usia Nikah"]].map(([key,label])=>({key,label}));
    const cleanPersen = obj => Object.fromEntries(Object.entries(obj || {}).filter(([k,v]) => LUPG_JENJANG.some(j => j.key === k) && v !== null && v !== "" && Number.isFinite(Number(v))).map(([k,v]) => [k, Math.max(0, Math.min(100, Number(v)))]));
    // hasilMusyawarah = hasil musyawarah 5 unsur kelompok; kendala & keterangan per kelompok per bulan.
    const lupgFromDb = r => ({id:r.id,kelompok:r.kelompok,desa:r.desa,bulan:r.bulan,tahun:r.tahun,kehadiran:r.kehadiran||{},ketercapaian:r.ketercapaian||{},catatan:r.catatan,hasilMusyawarah:r.hasil_musyawarah,kendala:r.kendala,keterangan:r.keterangan});
    const lupgToDb = r => { const x={}; put(x,"kelompok",r.kelompok); put(x,"desa",r.desa); put(x,"bulan",r.bulan); put(x,"tahun",numOrUndef(r.tahun)); put(x,"kehadiran",r.kehadiran===undefined?undefined:cleanPersen(r.kehadiran)); put(x,"ketercapaian",r.ketercapaian===undefined?undefined:cleanPersen(r.ketercapaian)); put(x,"catatan",r.catatan); put(x,"hasil_musyawarah",r.hasilMusyawarah); put(x,"kendala",r.kendala); put(x,"keterangan",r.keterangan); return x; };
    // Dokumentasi per kelompok & tingkatan pengajian; driveUrl untuk album besar di Google Drive.
    const dokFromDb = r => ({id:r.id,judul:r.judul,kategori:r.kategori,tanggal:r.tanggal,lokasi:r.lokasi,fotoCount:r.jumlah_foto,deskripsi:r.deskripsi,imageUrl:r.image_url,storagePath:r.storage_path,kelompok:r.kelompok,desa:r.desa,tingkatan:r.tingkatan,driveUrl:r.drive_url});
    const dokToDb = r => { const x={}; ["judul","kategori","lokasi","deskripsi","kelompok","desa","tingkatan"].forEach(k=>put(x,k,r[k])); put(x,"drive_url",r.driveUrl); put(x,"tanggal",orDefault(r.tanggal)); put(x,"jumlah_foto",r.fotoCount===undefined?undefined:Number(r.fotoCount)||1); put(x,"image_url",r.storagePath ? null : r.imageUrl); put(x,"storage_path",r.storagePath); return x; };
    const arsipFromDb = r => ({id:r.id,nama:r.judul,kategori:r.kategori,tipe:r.tipe_file,ukuran:r.ukuran_file,tanggal:r.tanggal||String(r.created_at||"").slice(0,10),catatan:r.catatan,fileUrl:r.file_url,storagePath:r.storage_path});
    const arsipToDb = r => { const x={}; put(x,"judul",r.nama); put(x,"kategori",r.kategori); put(x,"tipe_file",r.tipe); put(x,"ukuran_file",r.ukuran); put(x,"tanggal",orDefault(r.tanggal)); put(x,"catatan",r.catatan); put(x,"file_url",r.storagePath ? null : r.fileUrl); put(x,"storage_path",r.storagePath); return x; };
    const strukturFromDb = r => ({id:r.id,jabatan:r.jabatan,bidang:r.bidang,nama:r.nama,noHp:r.no_hp,level:r.level,urutan:r.urutan});
    const strukturToDb = r => { const x={}; put(x,"jabatan",r.jabatan); put(x,"bidang",r.bidang); put(x,"nama",r.nama); put(x,"no_hp",r.noHp); put(x,"level",numOrUndef(r.level)); put(x,"urutan",numOrUndef(r.urutan)); return x; };
    const identity = x => x;

    // ===== Profil & hak akses pengguna =====
    // role: admin (Ketua/Wakil/Sekretaris), pengurus, kelompok (pengurus kelompok), viewer. status: pending/approved/rejected.
    const ROLES = { admin:"Admin", pengurus:"Pengurus", kelompok:"User Kelompok", viewer:"Viewer" };
    const ADMIN_JABATAN = ["Ketua", "Wakil Ketua", "Sekretaris"];
    const profileFromDb = r => ({id:r.id,nama:r.nama,email:r.email,noHp:r.no_hp,jabatan:r.jabatan,kelompok:r.kelompok,desa:r.desa,role:r.role,status:r.status,createdAt:r.created_at});
    const profileToDb = r => { const x={}; put(x,"nama",r.nama); put(x,"no_hp",r.noHp); put(x,"jabatan",r.jabatan); put(x,"kelompok",r.kelompok===undefined?undefined:(r.kelompok||null)); put(x,"desa",r.desa===undefined?undefined:(r.desa||null)); put(x,"role",r.role); put(x,"status",r.status); return x; };
    const DEMO_PROFILE = { id:"demo", nama:"Administrator", email:"demo@ppgmaksel2.local", jabatan:"Ketua", role:"admin", status:"approved" };
    let myProfilePromise = null;
    const profile = {
        // Profil akun yang sedang login (di-cache per halaman). null bila belum login.
        me() {
            if (!myProfilePromise) myProfilePromise = (async () => {
                if (!client) return { ...DEMO_PROFILE };
                const { data: { session } } = await client.auth.getSession();
                if (!session) return null;
                const { data, error } = await client.from("profiles").select("*").eq("id", session.user.id).maybeSingle();
                if (error) throw friendlyError(error);
                return data ? profileFromDb(data) : null;
            })().catch(error => { myProfilePromise = null; throw error; });
            return myProfilePromise;
        },
        isAdmin: p => p?.status === "approved" && p.role === "admin",
        canManage: p => p?.status === "approved" && (p.role === "admin" || p.role === "pengurus"),
        isKelompokUser: p => p?.status === "approved" && p.role === "kelompok",
        async list() {
            if (!client) return [{ ...DEMO_PROFILE }];
            const { data, error } = await client.from("profiles").select("*").order("created_at", { ascending: false });
            if (error) throw friendlyError(error);
            return (data || []).map(profileFromDb);
        },
        async update(id, fields) {
            if (!client) throw new Error("Mode demo: hubungkan Supabase untuk mengelola pengguna.");
            const { data, error } = await client.from("profiles").update(profileToDb(fields)).eq("id", id).select().single();
            if (error) throw friendlyError(error);
            return profileFromDb(data);
        },
        ROLES, ADMIN_JABATAN
    };

    function fileDataUrl(file) { return new Promise((resolve,reject)=>{ const reader=new FileReader(); reader.onload=()=>resolve(reader.result); reader.onerror=()=>reject(reader.error||new Error("File gagal dibaca")); reader.readAsDataURL(file); }); }
    async function upload(bucket,file) {
        if (!client) return { path:"", publicUrl:await fileDataUrl(file) };
        const name=file.name.replace(/[^a-zA-Z0-9._-]/g,"-"); const path=`${new Date().getFullYear()}/${crypto.randomUUID()}-${name}`;
        const { error }=await client.storage.from(bucket).upload(path,file,{upsert:false,contentType:file.type}); if(error) throw friendlyError(error);
        const { data:signed,error:signedError }=await client.storage.from(bucket).createSignedUrl(path,SIGNED_URL_TTL); if(signedError)throw signedError;
        return { path, publicUrl:signed.signedUrl };
    }
    async function remove(bucket,path) { if(client&&path){const {error}=await client.storage.from(bucket).remove([path]);if(error)throw friendlyError(error);} return true; }
    // Pembersihan file setelah operasi database berhasil: gagal hapus file hanya meninggalkan file yatim, bukan metadata rusak.
    async function removeQuietly(bucket,path) { try { await remove(bucket,path); } catch (error) { console.warn(`File ${path} gagal dihapus dari ${bucket}:`, error.message); } }

    // Escape untuk interpolasi ke innerHTML (teks maupun atribut ber-kutip).
    const HTML_ESCAPES = { "&":"&amp;", "<":"&lt;", ">":"&gt;", '"':"&quot;", "'":"&#39;" };
    function escapeHtml(value) { return value === null || value === undefined ? "" : String(value).replace(/[&<>"']/g, c => HTML_ESCAPES[c]); }
    // Hanya izinkan URL http(s), blob, atau data:image untuk src/href hasil input pengguna.
    function safeUrl(value) { const url = String(value || "").trim(); return /^(https?:|blob:|data:image\/)/i.test(url) ? url : ""; }
    // Salinan baris dengan semua field string sudah di-escape, untuk template HTML.
    function escapeRow(row) { return Object.fromEntries(Object.entries(row || {}).map(([k, v]) => [k, typeof v === "string" ? escapeHtml(v) : v])); }

    // Tanggal YYYY-MM-DD menurut jam perangkat (toISOString memakai UTC, sehingga di WIB/WITA/WIT
    // tanggal mundur sehari antara tengah malam dan pagi).
    function tanggalLokal(d = new Date()) { const p = n => String(n).padStart(2, "0"); return `${d.getFullYear()}-${p(d.getMonth() + 1)}-${p(d.getDate())}`; }

    // CSV siap-Excel: BOM UTF-8, semua sel dikutip, dan sel berawalan = + - @ dinetralkan (formula injection).
    function downloadCsv(filename, header, rows) {
        const cell = value => { let text = value === null || value === undefined ? "" : String(value); if (/^[=+\-@]/.test(text)) text = "'" + text; return `"${text.replace(/"/g, '""')}"`; };
        const csv = [header, ...rows].map(row => row.map(cell).join(",")).join("\r\n");
        const link = document.createElement("a");
        link.href = URL.createObjectURL(new Blob(["﻿" + csv], { type: "text/csv;charset=utf-8" }));
        link.download = filename;
        document.body.appendChild(link); link.click(); link.remove();
        setTimeout(() => URL.revokeObjectURL(link.href), 1000);
    }

    initClient();
    window.PPG_DB = {
        isLive:()=>Boolean(client), getClient:()=>client, getConfig:()=>({...config}), isConfigLocked:()=>fileConfigured, setConfig,
        escapeHtml, escapeRow, safeUrl, downloadCsv, tanggalLokal, LUPG_JENJANG,
        generus:service({table:"generus",key:"ppg_maksel2_generus_data",toDb:generusToDb,fromDb:generusFromDb}),
        absensi:service({table:"absensi",key:"ppg_maksel2_absensi_data",toDb:absensiToDb,fromDb:absensiFromDb}),
        proker:service({table:"program_kerja",key:"proker_data",toDb:prokerToDb,fromDb:prokerFromDb,bucket:"ppg-arsip",urlField:"rabUrl",pathField:"rabPath"}),
        lupg:service({table:"laporan_lupg",key:"ppg_laporan_data",toDb:lupgToDb,fromDb:lupgFromDb}),
        struktur:service({table:"struktur_pengurus",key:"ppg_struktur_data",toDb:strukturToDb,fromDb:strukturFromDb,order:"urutan"}),
        profile,
        dokumentasi:service({table:"dokumentasi",key:"ppg_dokumentasi_data",toDb:dokToDb,fromDb:dokFromDb,bucket:"ppg-dokumentasi",urlField:"imageUrl"}),
        arsip:service({table:"arsip_dokumen",key:"ppg_arsip_data",toDb:arsipToDb,fromDb:arsipFromDb,bucket:"ppg-arsip",urlField:"fileUrl"}),
        pengaturan:service({table:"pengaturan_sistem",key:"ppg_pengaturan_data",toDb:identity,fromDb:identity}),
        storage:{uploadDokumentasi:f=>upload("ppg-dokumentasi",f),uploadArsip:f=>upload("ppg-arsip",f),removeDokumentasi:p=>removeQuietly("ppg-dokumentasi",p),removeArsip:p=>removeQuietly("ppg-arsip",p),uploadRab:f=>upload("ppg-arsip",f),removeRab:p=>removeQuietly("ppg-arsip",p)},
        auth:{
            async signIn(email,password){if(!client){const s={user:{email,user_metadata:{nama:"Administrator"}},demo:true};sessionStorage.setItem(DEMO_SESSION,JSON.stringify(s));return s;}const{data,error}=await client.auth.signInWithPassword({email,password});if(error)throw friendlyError(error);return data;},
            // Registrasi: profil dibuat trigger handle_new_user dengan status pending sampai disetujui admin.
            async signUp({email,password,nama,noHp,jabatan,kelompok,desa}){if(!client)throw new Error("Mode demo: registrasi membutuhkan koneksi Supabase.");const emailRedirectTo=new URL("login.html",window.location.href).href;const{data,error}=await client.auth.signUp({email,password,options:{emailRedirectTo,data:{nama,no_hp:noHp,jabatan,kelompok:kelompok||"",desa:desa||""}}});if(error)throw friendlyError(error);return data;},
            async signOut(){myProfilePromise=null;sessionStorage.removeItem(DEMO_SESSION);if(client){const{error}=await client.auth.signOut();if(error)throw friendlyError(error);}},
            async resetPassword(email){if(!client)return{demo:true};const redirectTo=new URL("reset_password.html",window.location.href).href;const{data,error}=await client.auth.resetPasswordForEmail(email,{redirectTo});if(error)throw friendlyError(error);return data;},
            async updatePassword(password){if(!client)throw new Error("Mode demo: hubungkan Supabase untuk mengganti password.");const{data,error}=await client.auth.updateUser({password});if(error)throw friendlyError(error);return data;},
            onAuthStateChange(callback){return client?client.auth.onAuthStateChange(callback):{data:{subscription:{unsubscribe(){}}}};},
            async getSession(){if(!client){try{return JSON.parse(sessionStorage.getItem(DEMO_SESSION)||"null");}catch{return null;}}const{data,error}=await client.auth.getSession();if(error)throw friendlyError(error);return data.session;}
        }
    };
})(window);
