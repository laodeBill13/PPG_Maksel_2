---
name: anti-ui-slop
description: Enforces high-craft, anti-AI-slop design standards for PPG Maksel 2 web interfaces. Eliminates generic AI templates, ensures proper states (loading, empty, error, active), authentic Islamic/community branding, and full accessibility.
---

# Anti-UI-Slop Guidelines (PPG Maksel 2)

This skill enforces strict frontend design and implementation quality gates to eliminate generic "AI slop" from the codebase.

## Core Principles

### 1. Reject Generic AI Tropes
- **No Meaningless Aesthetics**: Avoid random purple-pink mesh gradients, disconnected floating blobs without purpose, or generic SaaS card grids.
- **Brand Identity**: Ground every screen in the distinct visual identity of PPG Maksel 2:
  - Primary: Deep Royal & Navy Blue (`#1d4ed8` to `#1e3a8a`), representing trust, structure, and leadership.
  - Accent: Emerald Green (`#10b981` / `#059669`), representing growth, Islamic spirit, and positive status.
  - Highlights: Warm Amber (`#f59e0b`) and Rose (`#f43f5e`) for alerts, deadlines, and secondary categories.
  - Backgrounds: Clean slate (`#f8fafc` / `#f1f5f9`) with crisp micro-borders (`#e2e8f0`).

### 2. Mandatory Functional States
Every UI component, table, and form must account for all lifecycle states:
- **Empty State**: When filters or searches return zero items, display a helpful illustration or icon, explanatory text, and a quick "Reset Filter" or "Tambah Data" action.
- **Loading State**: Provide skeleton placeholders or smooth spinner badges when fetching or processing asynchronous actions.
- **Error State**: Field-level validation styling (`border-red-500`, red helper text) and non-blocking toast notifications.
- **Success State**: Clear feedback upon creation, update, or deletion.

### 3. Contextual, Authentic Language (No Robotic Phrasing)
- Use authentic Indonesian community terminology used by PPG Maksel 2:
  - Generus, Pengurus, Mubaligh/Mubalighot, Dewan Penasehat
  - Jenjang: PAUD, Caberawit, Pra-Remaja, Remaja, Pra-Nikah
  - Struktur: Wilayah Maksel 2, Desa, Kelompok (Kelompok A, B, C, D)
  - Program: Musyawarah Bulanan, LUPG (Laporan Usaha Pembinaan Generus), Asrama Al-Qur'an/Hadits
- Never use machine-translated pseudo-English terms where natural Indonesian is expected.

### 4. Zero Broken Affordances
- No dead `#` anchor links. Every button, tab, and link must either trigger a modal, run a handler, or navigate to a real screen.
- Modals must be dismissible via overlay click, Close button, and the `Escape` key.
- Tables must have active sorting/filtering indicators and responsive horizontal scrolling wrappers (`overflow-x-auto`) to prevent viewport breaking on mobile screens.

### 5. Mobile-First Responsiveness & Accessibility
- Test layouts on 375px (mobile) up to 1440px+ (desktop).
- Mobile bottom navigation bar + slide-out drawer sidebar must be synchronized.
- Touch targets must be at least 44x44px.
- High color contrast meeting WCAG AA standards.
