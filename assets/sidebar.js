// Global Sidebar Active Link & Mobile Drawer Handler
async function initSidebar() {
    if (window.PPG_DB?.isLive()) {
        try {
            const session = await window.PPG_DB.auth.getSession();
            if (!session) { window.location.replace('login.html'); return; }
        } catch (error) {
            console.error('Pemeriksaan sesi gagal:', error);
            window.location.replace('login.html'); return;
        }
    }
    const currentPath = window.location.pathname;
    const currentPage = currentPath.split("/").pop().split("?")[0].split("#")[0] || "dashboard.html";

    const sidebarLinks = document.querySelectorAll(".sidebar-link");

    sidebarLinks.forEach((link) => {
        const href = link.getAttribute("href");
        if (!href) return;
        const linkPage = href.split("/").pop().split("?")[0].split("#")[0];

        if (linkPage === currentPage || (currentPage === "" && linkPage === "dashboard.html")) {
            link.classList.add("bg-white", "text-blue-700", "font-semibold", "shadow-sm");
            link.classList.remove("hover:bg-blue-600", "text-white");
        } else {
            link.classList.remove("bg-white", "text-blue-700", "font-semibold", "shadow-sm");
            link.classList.add("text-white", "hover:bg-blue-600");
        }
    });

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
        proker: async () => `${(await window.PPG_DB.proker.list()).filter(p => p.status === 'Aktif').length} Aktif`
    };
    for (const [name, load] of Object.entries(loaders)) {
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
