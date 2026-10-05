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

// Kartu di kaki sidebar menampilkan akun yang sedang login.
function showAccount(profile) {
    if (!profile) return;
    const label = profile.jabatan || window.PPG_DB.profile.ROLES[profile.role] || profile.role;
    document.querySelectorAll('aside .border-t .bg-blue-800\\/60').forEach(card => {
        const [nameEl, roleEl] = card.querySelectorAll('p');
        if (nameEl) nameEl.textContent = profile.nama || profile.email || 'Pengguna';
        if (roleEl) roleEl.textContent = profile.kelompok ? `${label} · ${profile.kelompok}` : label;
    });
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
    if (window.PPG_DB?.profile.isAdmin(profile)) {
        EXTRA_MENU.filter(item => item.adminOnly).forEach(injectMenu);
        highlightActiveLinks();
    }
    showAccount(profile);
    document.dispatchEvent(new CustomEvent('ppg:profile', { detail: profile }));

    refreshSidebarBadges();

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
