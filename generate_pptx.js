const pptxgen = require("pptxgenjs");

const GREEN = "2E7D32";
const YELLOW = "FDD835";
const WHITE = "FFFFFF";
const DARK = "1A1A1A";
const GRAY = "666666";
const LIGHT_GRAY = "F5F5F5";

const pptx = new pptxgen();
pptx.defineLayout({ name: "WIDE", width: 13.33, height: 7.5 });
pptx.layout = "WIDE";

// ── Helper: add slide number ──────────────────────────────────────
function addSlideNumber(slide, num) {
  slide.addText(num.toString(), {
    x: 12.4, y: 7.0, w: 0.7, h: 0.4,
    fontSize: 9, color: GRAY, align: "right", fontFace: "Arial",
  });
}

// ── Slide 1 — Cover ──────────────────────────────────────────────
const s1 = pptx.addSlide();
s1.background = { color: GREEN };
s1.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 7.5, fill: { color: GREEN },
});
// Decorative diagonal stripe
s1.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 0.08, fill: { color: YELLOW },
});
s1.addText("🇲🇷", {
  x: 5.9, y: 1.2, w: 1.5, h: 1.0,
  fontSize: 60, align: "center", fontFace: "Arial",
});
s1.addText("بلّغ", {
  x: 1.5, y: 2.2, w: 10.3, h: 1.4,
  fontSize: 64, color: WHITE, bold: true, align: "center", fontFace: "Arial",
});
s1.addText("Baligh", {
  x: 1.5, y: 3.4, w: 10.3, h: 0.8,
  fontSize: 36, color: YELLOW, align: "center", fontFace: "Arial",
});
s1.addText("Civic Reporting Platform for Mauritania", {
  x: 1.5, y: 4.3, w: 10.3, h: 0.7,
  fontSize: 20, color: WHITE, align: "center", fontFace: "Arial",
  transparency: 15,
});
s1.addShape(pptx.ShapeType.rect, {
  x: 5.5, y: 5.2, w: 2.3, h: 0.06, fill: { color: YELLOW },
});
s1.addText("Institut Supérieur du Numérique — L2 DWM S4 2024", {
  x: 1.5, y: 5.5, w: 10.3, h: 0.5,
  fontSize: 13, color: WHITE, align: "center", fontFace: "Arial",
  transparency: 25,
});
addSlideNumber(s1, 1);

// ── Slide 2 — Team ─────────────────────────────────────────────────
const s2 = pptx.addSlide();
s2.background = { color: WHITE };
s2.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s2.addText("Équipe de Développement", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
const team = [
  { name: "Ahmed Bedou", role: "Développeur", emoji: "👨‍💻" },
  { name: "Abdsalam Abdelvetah", role: "Développeur", emoji: "👨‍💻" },
  { name: "Abdy Mohameden", role: "Développeur", emoji: "👨‍💻" },
  { name: "Hasseen Salem", role: "Développeur", emoji: "👨‍💻" },
];
team.forEach((m, i) => {
  const cx = 0.8 + i * 3.1;
  s2.addShape(pptx.ShapeType.roundRect, {
    x: cx, y: 1.8, w: 2.7, h: 3.6,
    fill: { color: LIGHT_GRAY },
    rectRadius: 0.15,
    shadow: { type: "outer", blur: 8, offset: 2, color: "000000", opacity: 0.1 },
  });
  s2.addShape(pptx.ShapeType.ellipse, {
    x: cx + 0.7, y: 2.1, w: 1.3, h: 1.3,
    fill: { color: GREEN },
  });
  s2.addText(m.emoji, {
    x: cx + 0.7, y: 2.15, w: 1.3, h: 1.2,
    fontSize: 28, align: "center", fontFace: "Arial",
  });
  s2.addText(m.name, {
    x: cx + 0.15, y: 3.6, w: 2.4, h: 0.7,
    fontSize: 14, color: DARK, bold: true, align: "center", fontFace: "Arial",
    wrap: true,
  });
  s2.addText(m.role, {
    x: cx + 0.15, y: 4.2, w: 2.4, h: 0.5,
    fontSize: 12, color: GRAY, align: "center", fontFace: "Arial",
  });
});
s2.addText("SupNum — L2 DWM S4 • 2024", {
  x: 0.6, y: 5.8, w: 12, h: 0.5,
  fontSize: 14, color: GREEN, bold: true, align: "center", fontFace: "Arial",
});
addSlideNumber(s2, 2);

// ── Slide 3 — Problem ─────────────────────────────────────────────
const s3 = pptx.addSlide();
s3.background = { color: WHITE };
s3.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s3.addText("Problématique", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
const problems = [
  { icon: "⚡", text: "Coupures d'électricité fréquentes et non signalées" },
  { icon: "🛣️", text: "Routes endommagées et nids-de-poule dangereux" },
  { icon: "🌊", text: "Inondations pendant la saison des pluies" },
  { icon: "🗑️", text: "Accumulation de déchets sans collecte" },
  { icon: "🚰", text: "Problèmes d'accès à l'eau potable" },
  { icon: "📱", text: "Aucun système officiel de signalement en temps réel" },
];
s3.addText("Les citoyens de Nouakchott font face à des défis quotidiens", {
  x: 0.8, y: 1.6, w: 11.5, h: 0.6,
  fontSize: 18, color: DARK, fontFace: "Arial",
});
problems.forEach((p, i) => {
  const row = Math.floor(i / 2);
  const col = i % 2;
  const px = 0.8 + col * 6.2;
  const py = 2.5 + row * 1.3;
  s3.addShape(pptx.ShapeType.roundRect, {
    x: px, y: py, w: 5.7, h: 1.0,
    fill: { color: LIGHT_GRAY },
    rectRadius: 0.1,
  });
  s3.addText(p.icon, {
    x: px + 0.2, y: py + 0.15, w: 0.7, h: 0.7,
    fontSize: 24, align: "center", fontFace: "Arial",
  });
  s3.addText(p.text, {
    x: px + 1.0, y: py + 0.15, w: 4.4, h: 0.7,
    fontSize: 14, color: DARK, fontFace: "Arial", valign: "middle",
  });
});
addSlideNumber(s3, 3);

// ── Slide 4 — Solution ────────────────────────────────────────────
const s4 = pptx.addSlide();
s4.background = { color: WHITE };
s4.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s4.addText("Notre Solution — بلّغ", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
const features = [
  { icon: "📝", title: "Signalement Express", desc: "Signalez un problème en 4 étapes avec photo et localisation" },
  { icon: "🗺️", title: "Carte Interactive", desc: "Visualisez tous les signalements sur une carte OSM en temps réel" },
  { icon: "👍", title: "Vote Communautaire", desc: "Confirmez ou rejetez les signalements pour établir leur crédibilité" },
  { icon: "💬", title: "Messagerie", desc: "Communiquez directement avec les auteurs des signalements" },
];
features.forEach((f, i) => {
  const cx = 0.6 + i * 3.15;
  s4.addShape(pptx.ShapeType.roundRect, {
    x: cx, y: 1.8, w: 2.85, h: 4.5,
    fill: { color: LIGHT_GRAY },
    rectRadius: 0.15,
    shadow: { type: "outer", blur: 6, offset: 2, color: "000000", opacity: 0.08 },
  });
  s4.addShape(pptx.ShapeType.roundRect, {
    x: cx + 0.7, y: 2.1, w: 1.45, h: 1.45,
    fill: { color: GREEN },
    rectRadius: 0.12,
  });
  s4.addText(f.icon, {
    x: cx + 0.7, y: 2.15, w: 1.45, h: 1.35,
    fontSize: 32, align: "center", fontFace: "Arial",
  });
  s4.addText(f.title, {
    x: cx + 0.2, y: 3.7, w: 2.45, h: 0.6,
    fontSize: 15, color: GREEN, bold: true, align: "center", fontFace: "Arial",
  });
  s4.addText(f.desc, {
    x: cx + 0.2, y: 4.3, w: 2.45, h: 1.4,
    fontSize: 12, color: GRAY, align: "center", fontFace: "Arial",
    wrap: true,
  });
});
addSlideNumber(s4, 4);

// ── Slide 5 — Architecture ────────────────────────────────────────
const s5 = pptx.addSlide();
s5.background = { color: WHITE };
s5.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s5.addText("Architecture MVC", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
// Flow boxes
const layers = [
  { label: "Vues\n(Flutter Widgets)", x: 0.6, y: 1.8, w: 2.8, h: 2.0, color: "E8F5E9" },
  { label: "Contrôleurs\n(ChangeNotifier)", x: 3.9, y: 1.8, w: 2.6, h: 2.0, color: "FFF9C4" },
  { label: "Services / DAOs\n(Abstraction)", x: 7.0, y: 1.8, w: 2.6, h: 2.0, color: "E3F2FD" },
  { label: "Supabase\n(PostgreSQL + RLS)", x: 10.1, y: 1.8, w: 2.8, h: 2.0, color: "F3E5F5" },
];
layers.forEach((l) => {
  s5.addShape(pptx.ShapeType.roundRect, {
    x: l.x, y: l.y, w: l.w, h: l.h,
    fill: { color: l.color },
    rectRadius: 0.12,
    line: { color: GREEN, width: 1.5 },
  });
  s5.addText(l.label, {
    x: l.x + 0.1, y: l.y + 0.2, w: l.w - 0.2, h: l.h - 0.4,
    fontSize: 14, color: DARK, bold: true, align: "center", fontFace: "Arial",
    valign: "middle", wrap: true,
  });
});
// Arrows between layers (text-based for reliability)
s5.addText("  →  ", {
  x: 3.3, y: 2.5, w: 0.7, h: 0.6,
  fontSize: 24, color: GREEN, bold: true, align: "center", fontFace: "Arial",
});
s5.addText("  →  ", {
  x: 6.4, y: 2.5, w: 0.7, h: 0.6,
  fontSize: 24, color: GREEN, bold: true, align: "center", fontFace: "Arial",
});
s5.addText("  →  ", {
  x: 9.5, y: 2.5, w: 0.7, h: 0.6,
  fontSize: 24, color: GREEN, bold: true, align: "center", fontFace: "Arial",
});

// Tech stack badges
s5.addText("Stack Technique", {
  x: 2.5, y: 4.2, w: 8, h: 0.5,
  fontSize: 16, color: DARK, bold: true, align: "center", fontFace: "Arial",
});
const badges = ["Flutter", "Dart", "Provider", "Supabase", "PostgreSQL", "OSM", "Vercel"];
badges.forEach((b, i) => {
  const bx = 0.5 + i * 1.8;
  const bw = 1.5;
  s5.addShape(pptx.ShapeType.roundRect, {
    x: bx, y: 4.9, w: bw, h: 0.6,
    fill: { color: GREEN },
    rectRadius: 0.3,
  });
  s5.addText(b, {
    x: bx, y: 4.9, w: bw, h: 0.6,
    fontSize: 12, color: WHITE, bold: true, align: "center", fontFace: "Arial",
    valign: "middle",
  });
});
s5.addText("Provider  ←  Flutter ←  Dart  ↔  Supabase SDK  →  PostgreSQL  (RLS sécurisé)", {
  x: 0.6, y: 5.9, w: 12, h: 0.5,
  fontSize: 11, color: GRAY, align: "center", fontFace: "Arial",
});
addSlideNumber(s5, 5);

// ── Slide 6 — Database ────────────────────────────────────────────
const s6 = pptx.addSlide();
s6.background = { color: WHITE };
s6.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s6.addText("Base de Données", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
s6.addText("Supabase PostgreSQL — 5 tables avec Row Level Security", {
  x: 0.8, y: 1.5, w: 11.5, h: 0.5,
  fontSize: 14, color: GRAY, fontFace: "Arial",
});
const tables = [
  { name: "users", cols: "id, username, email, avatar_url, reputation, is_admin", desc: "Profils utilisateurs" },
  { name: "reports", cols: "id, user_id, category, description, location, photo_url, status, confirm_count, deny_count", desc: "Signalements citoyens" },
  { name: "votes", cols: "id, user_id, report_id, vote_type", desc: "Votes de crédibilité" },
  { name: "notifications", cols: "id, user_id, type, message, is_read", desc: "Notifications" },
  { name: "messages", cols: "id, report_id, sender_id, receiver_id, content, is_read", desc: "Messagerie" },
];
const headerY = 2.3;
const rowH = 0.85;
// Table header
["Table", "Colonnes principales", "Description"].forEach((h, i) => {
  const hx = [0.6, 3.0, 9.5][i];
  const hw = [2.2, 6.3, 3.2][i];
  s6.addShape(pptx.ShapeType.rect, {
    x: hx, y: headerY, w: hw, h: 0.6,
    fill: { color: GREEN },
  });
  s6.addText(h, {
    x: hx, y: headerY, w: hw, h: 0.6,
    fontSize: 12, color: WHITE, bold: true, align: "center", fontFace: "Arial",
    valign: "middle",
  });
});
tables.forEach((t, i) => {
  const ty = headerY + 0.6 + i * rowH;
  const bg = i % 2 === 0 ? LIGHT_GRAY : WHITE;
  [[0.6, 2.2, t.name], [3.0, 6.3, t.cols], [9.5, 3.2, t.desc]].forEach(([tx, tw, text]) => {
    s6.addShape(pptx.ShapeType.rect, {
      x: tx, y: ty, w: tw, h: rowH,
      fill: { color: bg },
    });
    s6.addText(text, {
      x: tx + 0.1, y: ty, w: tw - 0.2, h: rowH,
      fontSize: 11, color: DARK, fontFace: "Arial",
      valign: "middle",
      wrap: true,
    });
  });
});
addSlideNumber(s6, 6);

// ── Slide 7 — Screenshots ─────────────────────────────────────────
const s7 = pptx.addSlide();
s7.background = { color: WHITE };
s7.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s7.addText("Aperçu de l'Application", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
const shots = [
  { label: "Connexion", emoji: "🔐" },
  { label: "Accueil", emoji: "🏠" },
  { label: "Carte", emoji: "🗺️" },
  { label: "Signalement", emoji: "📝" },
  { label: "Détails", emoji: "📋" },
  { label: "Messagerie", emoji: "💬" },
];
shots.forEach((s, i) => {
  const col = i % 3;
  const row = Math.floor(i / 3);
  const sx = 0.8 + col * 4.1;
  const sy = 1.8 + row * 2.6;
  s7.addShape(pptx.ShapeType.roundRect, {
    x: sx, y: sy, w: 3.6, h: 2.1,
    fill: { color: LIGHT_GRAY },
    rectRadius: 0.1,
    line: { color: "DDDDDD", width: 1 },
  });
  s7.addText(s.emoji, {
    x: sx + 0.3, y: sy + 0.3, w: 3.0, h: 1.0,
    fontSize: 40, align: "center", fontFace: "Arial",
  });
  s7.addText(s.label, {
    x: sx + 0.3, y: sy + 1.3, w: 3.0, h: 0.5,
    fontSize: 13, color: GRAY, align: "center", fontFace: "Arial",
  });
});
addSlideNumber(s7, 7);

// ── Slide 8 — Features Grid ───────────────────────────────────────
const s8 = pptx.addSlide();
s8.background = { color: WHITE };
s8.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s8.addText("Fonctionnalités", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
const allFeatures = [
  { emoji: "📝", text: "Signalement en 4 étapes" },
  { emoji: "🗺️", text: "Carte OSM interactive" },
  { emoji: "🔍", text: "Recherche et filtres" },
  { emoji: "👍", text: "Vote de crédibilité" },
  { emoji: "💬", text: "Messagerie temps réel" },
  { emoji: "🔔", text: "Notifications" },
  { emoji: "🌙", text: "Thème sombre/clair" },
  { emoji: "🌍", text: "3 langues (AR/FR/EN)" },
  { emoji: "📊", text: "Dashboard admin" },
];
allFeatures.forEach((f, i) => {
  const col = i % 3;
  const row = Math.floor(i / 3);
  const fx = 0.6 + col * 4.2;
  const fy = 1.6 + row * 1.6;
  s8.addShape(pptx.ShapeType.roundRect, {
    x: fx, y: fy, w: 3.8, h: 1.2,
    fill: { color: LIGHT_GRAY },
    rectRadius: 0.1,
    shadow: { type: "outer", blur: 4, offset: 1, color: "000000", opacity: 0.06 },
  });
  s8.addShape(pptx.ShapeType.roundRect, {
    x: fx + 0.15, y: fy + 0.15, w: 0.9, h: 0.9,
    fill: { color: GREEN },
    rectRadius: 0.1,
  });
  s8.addText(f.emoji, {
    x: fx + 0.15, y: fy + 0.15, w: 0.9, h: 0.9,
    fontSize: 22, align: "center", fontFace: "Arial",
    valign: "middle",
  });
  s8.addText(f.text, {
    x: fx + 1.25, y: fy, w: 2.4, h: 1.2,
    fontSize: 14, color: DARK, bold: true, fontFace: "Arial",
    valign: "middle",
  });
});
addSlideNumber(s8, 8);

// ── Slide 9 — Tech Stack ──────────────────────────────────────────
const s9 = pptx.addSlide();
s9.background = { color: WHITE };
s9.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 1.3, fill: { color: GREEN },
});
s9.addText("Technologies Utilisées", {
  x: 0.6, y: 0.2, w: 12, h: 0.9,
  fontSize: 32, color: WHITE, bold: true, fontFace: "Arial",
});
const techs = [
  { name: "Flutter", desc: "Framework mobile cross-platform", color: "02569B" },
  { name: "Dart", desc: "Langage de programmation", color: "0175C2" },
  { name: "Supabase", desc: "Backend-as-a-Service (BaaS)", color: "3ECF8E" },
  { name: "PostgreSQL", desc: "Base de données relationnelle", color: "4169E1" },
  { name: "Provider", desc: "Gestion d'état (State management)", color: "D32F2F" },
  { name: "OpenStreetMap", desc: "Cartes libres et ouvertes", color: "7EBC6F" },
  { name: "Vercel", desc: "Déploiement dashboard admin", color: "000000" },
];
techs.forEach((t, i) => {
  const col = i % 4;
  const row = Math.floor(i / 4);
  const tx = 0.6 + col * 3.15;
  const ty = 1.7 + row * 2.5;
  s9.addShape(pptx.ShapeType.roundRect, {
    x: tx, y: ty, w: 2.75, h: 2.0,
    fill: { color: LIGHT_GRAY },
    rectRadius: 0.12,
    shadow: { type: "outer", blur: 4, offset: 1, color: "000000", opacity: 0.06 },
  });
  s9.addShape(pptx.ShapeType.roundRect, {
    x: tx + 0.3, y: ty + 0.25, w: 2.15, h: 0.7,
    fill: { color: t.color },
    rectRadius: 0.08,
  });
  s9.addText(t.name, {
    x: tx + 0.3, y: ty + 0.25, w: 2.15, h: 0.7,
    fontSize: 16, color: WHITE, bold: true, align: "center", fontFace: "Arial",
    valign: "middle",
  });
  s9.addText(t.desc, {
    x: tx + 0.2, y: ty + 1.1, w: 2.35, h: 0.7,
    fontSize: 11, color: GRAY, align: "center", fontFace: "Arial",
    valign: "middle",
  });
});
addSlideNumber(s9, 9);

// ── Slide 10 — Demo / Q&A ─────────────────────────────────────────
const s10 = pptx.addSlide();
s10.background = { color: GREEN };
s10.addShape(pptx.ShapeType.rect, {
  x: 0, y: 0, w: 13.33, h: 7.5, fill: { color: GREEN },
});
s10.addText("Démonstration", {
  x: 1.5, y: 0.5, w: 10.3, h: 1.0,
  fontSize: 40, color: WHITE, bold: true, align: "center", fontFace: "Arial",
});
s10.addShape(pptx.ShapeType.rect, {
  x: 5.5, y: 1.4, w: 2.3, h: 0.06, fill: { color: YELLOW },
});
// Links
s10.addText("🔗", {
  x: 1.5, y: 2.0, w: 10.3, h: 0.6,
  fontSize: 32, align: "center", fontFace: "Arial",
});
s10.addText("Code source", {
  x: 1.5, y: 2.5, w: 10.3, h: 0.5,
  fontSize: 18, color: YELLOW, bold: true, align: "center", fontFace: "Arial",
});
s10.addText("github.com/mohameden19961/project-baligh", {
  x: 1.5, y: 3.0, w: 10.3, h: 0.5,
  fontSize: 14, color: WHITE, align: "center", fontFace: "Arial",
  underline: true,
});
s10.addText("Dashboard Admin", {
  x: 1.5, y: 3.8, w: 10.3, h: 0.5,
  fontSize: 18, color: YELLOW, bold: true, align: "center", fontFace: "Arial",
});
s10.addText("admin-dashboard-pearl-delta-63.vercel.app", {
  x: 1.5, y: 4.3, w: 10.3, h: 0.5,
  fontSize: 14, color: WHITE, align: "center", fontFace: "Arial",
  underline: true,
});
// Thank you
s10.addShape(pptx.ShapeType.rect, {
  x: 2.0, y: 5.2, w: 9.3, h: 0.06, fill: { color: YELLOW },
});
const thanks = [
  "شكراً لاهتمامكم — Questions ?",
  "Merci de votre attention — Questions ?",
  "Thank you — Questions ?",
];
thanks.forEach((t, i) => {
  s10.addText(t, {
    x: 1.5, y: 5.5 + i * 0.55, w: 10.3, h: 0.5,
    fontSize: 16, color: WHITE, align: "center", fontFace: "Arial",
  });
});
addSlideNumber(s10, 10);

// ── Save ─────────────────────────────────────────────────────────
pptx.writeFile({ fileName: "baligh_presentation.pptx" })
  .then(() => console.log("✅ Presentation saved as baligh_presentation.pptx"))
  .catch((err) => console.error("❌ Error:", err));
