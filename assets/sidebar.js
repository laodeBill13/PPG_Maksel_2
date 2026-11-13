// Menu tambahan disisipkan ke semua sidebar (desktop + drawer mobile) agar markup tiap halaman tidak perlu diubah.
const EXTRA_MENU = [
    { href: 'struktur.html', icon: 'fa-sitemap', label: 'Struktur Kepengurusan', after: 'arsip.html' },
    { href: 'pengguna.html', icon: 'fa-user-check', label: 'Persetujuan User', after: 'struktur.html', adminOnly: true, badge: 'pengguna' },
];

function injectMenu(item) {
    document.querySelectorAll('nav').forEach(nav => {
        if (nav.querySelector(`a.sidebar-link[href="${item.href}"]`)) return;
        const anchor = nav.querySelector(`a.sidebar-link[href="${item.after}"]`);
        if (!anchor) return;
        const link = document.createElement('a');
        link.href = item.href;
        link.className = 'sidebar-link flex items-center justify-between px-4 py-3 rounded-xl transition text-sm font-medium';
        link.innerHTML = `<div class="flex items-center gap-3.5"><i class="fas ${item.icon} w-5 text-center text-base"></i><span>${item.label}</span></div>`
            + (item.badge ? `<span data-badge="${item.badge}" class="hidden bg-red-500 text-white text-[11px] px-2 py-0.5 rounded-full font-semibold"></span>` : '');
        anchor.after(link);
    });
}

function highlightActiveLinks() {
    const currentPage = window.location.pathname.split("/").pop().split("?")[0].split("#")[0] || "dashboard.html";
    document.querySelectorAll(".sidebar-link").forEach((link) => {
        const href = link.getAttribute("href");
        if (!href) return;
        const linkPage = href.split("/").pop().split("?")[0].split("#")[0];
        if (linkPage === currentPage) {
            link.classList.add("bg-white", "text-blue-700", "font-semibold", "shadow-sm");
            link.classList.remove("hover:bg-blue-600", "text-white");
        } else {
            link.classList.remove("bg-white", "text-blue-700", "font-semibold", "shadow-sm");
            link.classList.add("text-white", "hover:bg-blue-600");
        }
    });
}

// Nama, peran, email & inisial akun yang sedang login: kartu kaki sidebar, profil di pojok kanan atas,
// dan elemen lain yang bertanda data-user-name / data-user-role / data-user-email / data-user-initial.
function showAccount(profile) {
    const nama = profile?.nama || profile?.email || 'Pengguna';
    const label = profile ? (profile.jabatan || window.PPG_DB.profile.ROLES[profile.role] || profile.role || '') : '';
    const labelLengkap = profile?.kelompok ? `${label} · ${profile.kelompok}` : label;
    document.querySelectorAll('aside .border-t .bg-blue-800\\/60').forEach(card => {
        if (!profile) return;
        const [nameEl, roleEl] = card.querySelectorAll('p');
        if (nameEl) nameEl.textContent = nama;
        if (roleEl) roleEl.textContent = labelLengkap;
    });
    document.querySelectorAll('[data-user-name]').forEach(el => { el.textContent = nama; });
    document.querySelectorAll('[data-user-role]').forEach(el => { el.textContent = labelLengkap; });
    document.querySelectorAll('[data-user-email]').forEach(el => { el.textContent = profile?.email || ''; });
    document.querySelectorAll('[data-user-initial]').forEach(el => { el.textContent = nama.trim().charAt(0).toUpperCase() || '?'; });
}

async function initSidebar() {
    const live = window.PPG_DB?.isLive();
    if (live) {
        try {
            const session = await window.PPG_DB.auth.getSession();
            if (!session) { window.location.replace('login.html'); return; }
        } catch (error) {
            console.error('Pemeriksaan sesi gagal:', error);
            window.location.replace('login.html'); return;
        }
    }

    EXTRA_MENU.filter(item => !item.adminOnly).forEach(injectMenu);
    highlightActiveLinks();

    // Akun yang belum disetujui admin tidak boleh membuka halaman aplikasi.
    // Gagal memuat profil (mis. jaringan) tidak mengunci halaman; RLS tetap membatasi data.
    let profile = null, profileLoaded = false;
    try { profile = await window.PPG_DB?.profile.me(); profileLoaded = true; }
    catch (error) { console.warn('Profil gagal dimuat:', error.message); }
    if (live && profileLoaded && profile?.status !== 'approved') {
        try { await window.PPG_DB.auth.signOut(); } catch {}
        window.location.replace(`login.html?status=${profile?.status || 'pending'}`); return;
    }
    window.PPG_PROFILE = profile;
    terapkanHakAkses(profile, profileLoaded);
    if (window.PPG_DB?.profile.isAdmin(profile)) {
        EXTRA_MENU.filter(item => item.adminOnly).forEach(injectMenu);
        highlightActiveLinks();
    }
    showAccount(profile);
    document.dispatchEvent(new CustomEvent('ppg:profile', { detail: profile }));

    refreshSidebarBadges();
    tampilkanKreditSetelahLogin();

    document.querySelectorAll('a[href="login.html"]').forEach(link => {
        if (link.dataset.logoutBound) return;
        link.dataset.logoutBound = 'true';
        link.addEventListener('click', async event => {
            event.preventDefault();
            try { await window.PPG_DB?.auth.signOut(); }
            catch (error) { console.error('Logout gagal:', error); }
            window.location.href = 'login.html';
        });
    });
}

// Badge menu (desktop + drawer mobile) dihitung dari data, bukan angka tetap.
async function refreshSidebarBadges() {
    const badges = document.querySelectorAll('[data-badge]');
    if (!badges.length || !window.PPG_DB) return;
    const loaders = {
        generus: async () => String((await window.PPG_DB.generus.list()).length),
        absensi: async () => {
            const rows = await window.PPG_DB.absensi.list();
            return rows.length ? `${(rows.filter(r => r.status === 'Hadir').length / rows.length * 100).toFixed(0)}%` : '0%';
        },
        proker: async () => `${(await window.PPG_DB.proker.list()).filter(p => p.status === 'Aktif').length} Aktif`,
        pengguna: async () => {
            const pending = window.PPG_DB.isLive() ? (await window.PPG_DB.profile.list()).filter(p => p.status === 'pending').length : 0;
            document.querySelectorAll('[data-badge="pengguna"]').forEach(el => el.classList.toggle('hidden', !pending));
            return String(pending);
        }
    };
    for (const [name, load] of Object.entries(loaders)) {
        if (!document.querySelector(`[data-badge="${name}"]`)) continue;
        try {
            const text = await load();
            document.querySelectorAll(`[data-badge="${name}"]`).forEach(el => { el.textContent = text; });
        } catch (error) { console.warn(`Badge ${name} gagal dimuat:`, error.message); }
    }
}
window.refreshSidebarBadges = refreshSidebarBadges;

// Pop-up kredit pembuat aplikasi: kartu besar di tengah layar, tampil sekali setelah login,
// tertutup otomatis dalam 5 detik (hitungan berhenti selama kursor berada di atas kartu).
function tampilkanKreditSetelahLogin() {
    try {
        if (sessionStorage.getItem('ppg_kredit_login') !== '1') return;
        sessionStorage.removeItem('ppg_kredit_login');
    } catch { return; }
    const DURASI = 5000;
    const URL_STUDIO = 'https://nadhestudio.id';

    const latar = document.createElement('div');
    latar.className = 'fixed inset-0 z-[95] flex items-center justify-center p-4 bg-slate-900/60 backdrop-blur-sm transition-opacity duration-300 opacity-0';
    latar.setAttribute('role', 'dialog');
    latar.setAttribute('aria-modal', 'true');
    latar.setAttribute('aria-labelledby', 'kreditJudul');

    const kartu = document.createElement('a');
    kartu.href = URL_STUDIO;
    kartu.target = '_blank';
    kartu.rel = 'noopener';
    kartu.className = 'relative block w-full max-w-md bg-white rounded-3xl shadow-2xl overflow-hidden text-center transition-all duration-300 scale-95 opacity-0 hover:shadow-blue-900/30';
    kartu.innerHTML = `
        <div class="bg-gradient-to-br from-blue-700 via-blue-600 to-indigo-600 px-8 pt-10 pb-14">
            <div class="w-20 h-20 mx-auto rounded-3xl bg-white/15 border border-white/30 text-white flex items-center justify-center text-3xl shadow-lg"><i class="fas fa-code"></i></div>
        </div>
        <div class="px-8 pb-8 -mt-8">
            <div class="bg-white rounded-2xl shadow-lg border border-slate-100 px-6 py-5">
                <p class="text-sm text-slate-500">Aplikasi ini dibuat oleh</p>
                <h2 id="kreditJudul" class="text-3xl sm:text-4xl font-extrabold tracking-tight text-slate-900 mt-1">NadheStudio</h2>
            </div>
            <span class="mt-6 inline-flex items-center justify-center gap-2 w-full bg-blue-700 hover:bg-blue-800 text-white font-semibold py-3.5 rounded-xl transition">
                Kunjungi nadhestudio.id <i class="fas fa-arrow-up-right-from-square text-sm"></i>
            </span>
            <p class="mt-4 text-xs text-slate-400">Menutup otomatis dalam <span data-kredit-detik>5</span> detik</p>
        </div>
        <div class="h-1.5 bg-slate-100"><div data-kredit-bar class="h-full bg-blue-600" style="width:100%"></div></div>`;

    const tutup = document.createElement('button');
    tutup.type = 'button';
    tutup.setAttribute('aria-label', 'Tutup');
    tutup.className = 'absolute top-3 right-3 w-10 h-10 rounded-xl text-white/80 hover:text-white hover:bg-white/15 flex items-center justify-center';
    tutup.innerHTML = '<i class="fas fa-times"></i>';
    kartu.appendChild(tutup);
    latar.appendChild(kartu);
    document.body.appendChild(latar);

    const bar = kartu.querySelector('[data-kredit-bar]');
    const detik = kartu.querySelector('[data-kredit-detik]');
    let sisa = DURASI, mulai = 0, timer = null, ticker = null, selesai = false;
    const hilang = () => {
        if (selesai) return; selesai = true;
        clearTimeout(timer); clearInterval(ticker);
        document.removeEventListener('keydown', escTutup);
        latar.classList.add('opacity-0');
        kartu.classList.add('scale-95', 'opacity-0');
        setTimeout(() => latar.remove(), 300);
    };
    const escTutup = event => { if (event.key === 'Escape') hilang(); };
    const jalan = () => {
        if (selesai) return;
        mulai = Date.now();
        bar.style.transition = `width ${sisa}ms linear`;
        bar.style.width = '0%';
        timer = setTimeout(hilang, sisa);
        clearInterval(ticker);
        ticker = setInterval(() => { detik.textContent = Math.max(1, Math.ceil((sisa - (Date.now() - mulai)) / 1000)); }, 200);
    };
    const jeda = () => {
        clearTimeout(timer); clearInterval(ticker);
        sisa = Math.max(0, sisa - (Date.now() - mulai));
        bar.style.transition = 'none';
        bar.style.width = `${(sisa / DURASI) * 100}%`;
    };

    kartu.addEventListener('mouseenter', jeda);
    kartu.addEventListener('mouseleave', jalan);
    tutup.addEventListener('click', event => { event.preventDefault(); event.stopPropagation(); hilang(); });
    kartu.addEventListener('click', () => setTimeout(hilang, 100));
    latar.addEventListener('click', event => { if (event.target === latar) hilang(); });
    document.addEventListener('keydown', escTutup);
    requestAnimationFrame(() => requestAnimationFrame(() => {
        latar.classList.remove('opacity-0');
        kartu.classList.remove('scale-95', 'opacity-0');
        jalan();
    }));
}

// Global Mobile Drawer Functions
function openMobileDrawer() {
    const drawer = document.getElementById('mobileSidebarDrawer');
    const overlay = document.getElementById('drawerOverlay');
    if (drawer) drawer.classList.add('drawer-open');
    if (overlay) overlay.classList.add('overlay-visible');
    document.body.style.overflow = 'hidden';
}

function closeMobileDrawer() {
    const drawer = document.getElementById('mobileSidebarDrawer');
    const overlay = document.getElementById('drawerOverlay');
    if (drawer) drawer.classList.remove('drawer-open');
    if (overlay) overlay.classList.remove('overlay-visible');
    document.body.style.overflow = '';
}

// Expose globally to window
window.openMobileDrawer = openMobileDrawer;
window.closeMobileDrawer = closeMobileDrawer;

window.addEventListener('unhandledrejection', event => {
    console.error('Operasi aplikasi gagal:', event.reason);
    const notice = document.createElement('div');
    notice.setAttribute('role', 'alert');
    notice.className = 'fixed right-4 top-4 z-[100] max-w-sm rounded-xl bg-red-600 px-4 py-3 text-sm font-medium text-white shadow-xl';
    notice.textContent = `Operasi gagal: ${event.reason?.message || 'Terjadi kesalahan yang tidak terduga.'}`;
    document.body.appendChild(notice);
    setTimeout(() => notice.remove(), 5000);
});

document.addEventListener('keydown', (e) => {
    if (e.key === 'Escape') {
        closeMobileDrawer();
        document.querySelectorAll('.fixed[id^="modal"]').forEach(modal => {
            if (!modal.classList.contains('hidden')) modal.classList.add('hidden');
        });
    }
});

if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initSidebar);
} else {
    initSidebar();
}

// Tombol sesuai role. Tandai elemen dengan kelas:
//   manage-only  → hanya admin & pengurus      admin-only → hanya admin
//   lupg-only    → admin, pengurus & user kelompok (isi LUPG)
//   manage-click → terlihat semua, tapi hanya admin & pengurus yang bisa klik
// Bila profil gagal dimuat (mis. jaringan), tombol tetap tampil; RLS Supabase tetap menolak perubahan tanpa izin.
function terapkanHakAkses(profile, profileLoaded) {
    if (!document.getElementById('ppgHakAksesStyle')) {
        const style = document.createElement('style');
        style.id = 'ppgHakAksesStyle';
        style.textContent = 'body:not(.can-manage) .manage-only, body:not(.is-admin) .admin-only, body:not(.can-lupg) .lupg-only { display: none !important; }'
            + ' body:not(.can-manage) .manage-click { pointer-events: none; cursor: default; }';
        document.head.appendChild(style);
    }
    const P = window.PPG_DB?.profile;
    const manage = !profileLoaded || Boolean(P?.canManage(profile));
    document.body.classList.toggle('can-manage', manage);
    document.body.classList.toggle('is-admin', !profileLoaded || Boolean(P?.isAdmin(profile)));
    document.body.classList.toggle('can-lupg', manage || Boolean(P?.isKelompokUser(profile)));
}
