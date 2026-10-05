// Master wilayah PPG Maksel 2: desa dan kelompok (sumber: format Laporan LUPG).
// Ubah daftar di sini untuk menambah/mengganti kelompok; semua dropdown mengikuti.
(function (window) {
    "use strict";
    const DESA = [
        { desa: "Gowata", kelompok: ["Sengka", "Barembeng", "BT.Mattiro", "Talamangape", "Paku"] },
        { desa: "Bataraya", kelompok: ["BT.Ramba", "Sombala Bella", "Allu", "Turatea"] },
        { desa: "Babuta", kelompok: ["Bissappu", "Lonrong", "Borong Kaluku", "Bulukumba", "Tanete"] },
        { desa: "Selayar", kelompok: ["Benteng", "Balang Butung"] },
    ];
    const desaByKelompok = new Map(DESA.flatMap(d => d.kelompok.map(k => [k, d.desa])));

    function option(value, label = value) {
        const el = document.createElement("option");
        el.value = value; el.textContent = label;
        return el;
    }

    // <select data-wilayah="kelompok|desa" data-semua="Semua Kelompok" data-desa-target="idSelectDesa">
    function fillSelects(root = document) {
        root.querySelectorAll("select[data-wilayah]").forEach(select => {
            const current = select.value;
            select.replaceChildren();
            if (select.dataset.semua) select.append(option("", select.dataset.semua));
            if (select.dataset.wilayah === "desa") {
                DESA.forEach(d => select.append(option(d.desa)));
            } else {
                DESA.forEach(d => {
                    const group = document.createElement("optgroup");
                    group.label = `Desa ${d.desa}`;
                    d.kelompok.forEach(k => group.append(option(k)));
                    select.append(group);
                });
                if (select.dataset.desaTarget && !select.dataset.desaBound) {
                    select.dataset.desaBound = "true";
                    select.addEventListener("change", () => syncDesa(select));
                }
            }
            if (current && [...select.options].some(o => o.value === current)) select.value = current;
        });
        // Sinkronkan setelah semua dropdown terisi, karena dropdown desa bisa berada setelah dropdown kelompok.
        root.querySelectorAll("select[data-desa-target]").forEach(syncDesa);
    }

    // Desa mengikuti kelompok yang dipilih (form Generus).
    function syncDesa(select) {
        const target = select.dataset.desaTarget && document.getElementById(select.dataset.desaTarget);
        const desa = desaByKelompok.get(select.value);
        if (target && desa) target.value = desa;
    }

    window.PPG_WILAYAH = {
        desa: DESA.map(d => d.desa),
        kelompok: DESA.flatMap(d => d.kelompok),
        struktur: DESA,
        desaOf: kelompok => desaByKelompok.get(kelompok) || "",
        fillSelects,
    };
    fillSelects();
})(window);
