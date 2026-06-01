const SUPABASE_URL = 'https://fghccefhxorhnpgvxjvb.supabase.co';
const SUPABASE_ANON_KEY = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZnaGNjZWZoeG9yaG5wZ3Z4anZiIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODAyMjEwMTMsImV4cCI6MjA5NTc5NzAxM30.wK7KvMbvYax4u9jTCDRIVwX4NC00EMxgvEk1awWptKQ';
const sb = window.supabase.createClient(SUPABASE_URL, SUPABASE_ANON_KEY);

let currentUser = null;
let currentLang = localStorage.getItem('admin_lang') || 'ar';
let categoryChart = null;

const LANG = {
  ar: {
    loginTitle: 'لوحة تحكم بلّغ',
    loginSubtitle: 'تسجيل الدخول لحساب المشرف',
    email: 'البريد الإلكتروني',
    password: 'كلمة المرور',
    login: 'تسجيل الدخول',
    loginError: 'البريد الإلكتروني أو كلمة المرور غير صحيحة',
    noAccess: 'ليس لديك صلاحية الوصول إلى لوحة التحكم',
    reports: 'البلاغات',
    users: 'المستخدمون',
    notifications: 'الإشعارات',
    logout: 'تسجيل الخروج',
    totalReports: 'إجمالي البلاغات',
    pending: 'قيد الانتظار',
    validated: 'موثقة',
    falseReport: 'كاذبة',
    allCategories: 'كل التصنيفات',
    allStatuses: 'كل الحالات',
    statusPending: 'قيد الانتظار',
    statusValidated: 'موثق',
    statusFalseReport: 'بلاغ كاذب',
    filter: 'تصفية',
    thPhoto: 'صورة',
    thUser: 'المستخدم',
    thCategory: 'التصنيف',
    thDescription: 'الوصف',
    thVotes: '✅ ❌',
    thCredibility: 'المصداقية',
    thLocation: 'الموقع',
    thDate: 'التاريخ',
    thStatus: 'الحالة',
    thActions: 'الإجراءات',
    loading: 'جارٍ التحميل...',
    noReports: 'لا توجد بلاغات',
    delete: 'حذف',
    view: 'عرض',
    statusChanged: 'تم تغيير حالة البلاغ بنجاح',
    statusFailed: 'فشل تغيير الحالة',
    noPermission: 'ليس لديك صلاحية',
    confirmDelete: 'هل أنت متأكد من حذف هذا البلاغ؟',
    deleted: 'تم حذف البلاغ بنجاح',
    deleteFailed: 'فشل حذف البلاغ',
    error: 'خطأ',
    usersTitle: 'المستخدمون',
    thUsername: 'المستخدم',
    thEmail: 'البريد',
    thRegistered: 'تاريخ التسجيل',
    thReports: 'البلاغات',
    thConfirmed: 'موثقة',
    thReputation: 'السمعة',
    thAdmin: 'مسؤول',
    noUsers: 'لا يوجد مستخدمون',
    notificationsTitle: 'الإشعارات',
    thMessage: 'الرسالة',
    read: 'مقروء',
    unread: 'غير مقروء',
    noNotifications: 'لا توجد إشعارات',
    clearFilter: 'إزالة الفلتر',
    langToggle: 'FR',
    reportDetail: 'تفاصيل البلاغ',
    detailCategory: 'التصنيف',
    detailDescription: 'الوصف',
    detailLocation: 'الموقع',
    detailDate: 'التاريخ',
    detailStatus: 'الحالة',
    detailVotes: 'التصويتات',
    detailConfirm: 'موثق',
    detailDeny: 'مرفوض',
    detailCredibility: 'المصداقية',
    detailUser: 'المستخدم',
    detailPhoto: 'الصورة',
    toggleAdmin: 'تعيين كمسؤول',
    removeAdmin: 'إزالة الصلاحية',
    userDeleted: 'تم حذف المستخدم',
    userDeleteFailed: 'فشل حذف المستخدم',
    confirmDeleteUser: 'هل أنت متأكد من حذف هذا المستخدم؟',
    adminUpdated: 'تم تحديث صلاحية المسؤول',
  },
  fr: {
    loginTitle: 'Tableau de bord بلّغ',
    loginSubtitle: 'Connexion administrateur',
    email: 'Email',
    password: 'Mot de passe',
    login: 'Se connecter',
    loginError: 'Email ou mot de passe incorrect',
    noAccess: "Vous n'avez pas les droits d'accès",
    reports: 'Signalements',
    users: 'Utilisateurs',
    notifications: 'Notifications',
    logout: 'Déconnexion',
    totalReports: 'Total signalements',
    pending: 'En attente',
    validated: 'Validés',
    falseReport: 'Faux',
    allCategories: 'Toutes catégories',
    allStatuses: 'Tous statuts',
    statusPending: 'En attente',
    statusValidated: 'Validé',
    statusFalseReport: 'Faux signalement',
    filter: 'Filtrer',
    thPhoto: 'Photo',
    thUser: 'Utilisateur',
    thCategory: 'Catégorie',
    thDescription: 'Description',
    thVotes: '✅ ❌',
    thCredibility: 'Crédibilité',
    thLocation: 'Localisation',
    thDate: 'Date',
    thStatus: 'Statut',
    thActions: 'Actions',
    loading: 'Chargement...',
    noReports: 'Aucun signalement',
    delete: 'Supprimer',
    view: 'Voir',
    statusChanged: 'Statut modifié avec succès',
    statusFailed: 'Échec de modification',
    noPermission: 'Action non autorisée',
    confirmDelete: 'Confirmer la suppression ?',
    deleted: 'Signalement supprimé',
    deleteFailed: 'Échec de suppression',
    error: 'Erreur',
    usersTitle: 'Utilisateurs',
    thUsername: 'Utilisateur',
    thEmail: 'Email',
    thRegistered: "Date d'inscription",
    thReports: 'Signalements',
    thConfirmed: 'Validés',
    thReputation: 'Réputation',
    thAdmin: 'Admin',
    noUsers: 'Aucun utilisateur',
    notificationsTitle: 'Notifications',
    thMessage: 'Message',
    read: 'Lu',
    unread: 'Non lu',
    noNotifications: 'Aucune notification',
    clearFilter: 'Voir tout',
    langToggle: 'AR',
    reportDetail: 'Détails du signalement',
    detailCategory: 'Catégorie',
    detailDescription: 'Description',
    detailLocation: 'Localisation',
    detailDate: 'Date',
    detailStatus: 'Statut',
    detailVotes: 'Votes',
    detailConfirm: 'Validé',
    detailDeny: 'Rejeté',
    detailCredibility: 'Crédibilité',
    detailUser: 'Utilisateur',
    detailPhoto: 'Photo',
    toggleAdmin: 'Promouvoir admin',
    removeAdmin: 'Rétrograder',
    userDeleted: 'Utilisateur supprimé',
    userDeleteFailed: 'Échec de suppression',
    confirmDeleteUser: 'Confirmer la suppression ?',
    adminUpdated: 'Statut admin mis à jour',
  },
};

const CATEGORY_LABELS = {
  ar: { electricity: 'الكهرباء', road: 'الطرق', flood: 'الفيضانات', security: 'الأمن', water: 'المياه', health: 'الصحة', internet: 'الإنترنت', market: 'السوق', government: 'الحكومة', fire: 'الحرائق', infrastructure: 'البنية التحتية', fraud: 'الاحتيال' },
  fr: { electricity: 'Électricité', road: 'Routes', flood: 'Inondations', security: 'Sécurité', water: 'Eau', health: 'Santé', internet: 'Internet', market: 'Marché', government: 'Gouvernement', fire: 'Incendies', infrastructure: 'Infrastructure', fraud: 'Fraude' },
};
const CATEGORY_COLORS = {
  electricity: '#F59E0B', road: '#6366F1', flood: '#06B6D4', security: '#DC2626', water: '#2563EB',
  health: '#16A34A', internet: '#8B5CF6', market: '#EC4899', government: '#0D9488', fire: '#EB6424',
  infrastructure: '#6B7280', fraud: '#9333EA',
};

function t(key) { return LANG[currentLang][key] || key; }
function catLabel(key) { return CATEGORY_LABELS[currentLang][key] || key; }

function toggleLang() {
  currentLang = currentLang === 'ar' ? 'fr' : 'ar';
  localStorage.setItem('admin_lang', currentLang);
  document.documentElement.dir = currentLang === 'ar' ? 'rtl' : 'ltr';
  applyLang();
  document.getElementById('langToggle').textContent = t('langToggle');
  initCategoryFilter();
  if (document.getElementById('dashboard').style.display !== 'none') {
    loadReports(); loadUsers(); loadNotifications();
  }
}

function applyLang() {
  document.querySelectorAll('[data-i18n]').forEach(el => {
    const key = el.dataset.i18n;
    el.textContent = t(key);
  });
  document.getElementById('emailInput').placeholder = t('email');
  document.getElementById('passwordInput').placeholder = t('password');
  const fs = document.getElementById('filterStatus');
  fs.innerHTML =
    `<option value="">${t('allStatuses')}</option>` +
    `<option value="pending">${t('statusPending')}</option>` +
    `<option value="validated">${t('statusValidated')}</option>` +
    `<option value="falseReport">${t('statusFalseReport')}</option>`;
}

function showToast(msg, type = 'success') {
  const tEl = document.getElementById('toast');
  tEl.textContent = msg; tEl.className = `toast ${type}`; tEl.style.display = 'block';
  setTimeout(() => tEl.style.display = 'none', 3000);
}

async function login() {
  const email = document.getElementById('emailInput').value;
  const password = document.getElementById('passwordInput').value;
  const errEl = document.getElementById('loginError');
  errEl.style.display = 'none';
  try {
    const { data, error } = await sb.auth.signInWithPassword({ email, password });
    if (error) throw error;
    const { data: profile } = await sb.from('users').select('*').eq('id', data.user.id).single();
    if (!profile || !profile.is_admin) {
      await sb.auth.signOut();
      errEl.textContent = t('noAccess');
      errEl.style.display = 'block';
      return;
    }
    currentUser = profile;
    applyLang();
    document.getElementById('loginPage').style.display = 'none';
    document.getElementById('dashboard').style.display = 'block';
    document.getElementById('userInfo').textContent = `👤 ${profile.username || profile.email}`;
    document.getElementById('langToggle').textContent = t('langToggle');
    initCategoryFilter();
    loadReports(); loadUsers(); loadNotifications();
  } catch (e) {
    errEl.textContent = e.message.includes('Invalid login credentials') ? t('loginError') : e.message;
    errEl.style.display = 'block';
  }
}

async function logout() {
  await sb.auth.signOut();
  currentUser = null;
  document.getElementById('dashboard').style.display = 'none';
  document.getElementById('loginPage').style.display = 'flex';
  document.getElementById('emailInput').value = '';
  document.getElementById('passwordInput').value = '';
}

function toggleMobileMenu() {
  document.getElementById('sidebar').classList.toggle('open');
  document.getElementById('sidebarOverlay').classList.toggle('open');
}

function switchPage(page, el) {
  toggleMobileMenu();
  document.querySelectorAll('.sidebar a').forEach(a => a.classList.remove('active'));
  el.classList.add('active');
  document.querySelectorAll('.page').forEach(p => p.classList.remove('active'));
  document.getElementById(`page-${page}`).classList.add('active');
  if (page === 'reports') setTimeout(() => renderCategoryChart(), 100);
}

function initCategoryFilter() {
  const sel = document.getElementById('filterCategory');
  const labels = CATEGORY_LABELS[currentLang];
  sel.innerHTML = `<option value="">${t('allCategories')}</option>`;
  Object.entries(labels).forEach(([k, v]) => { sel.innerHTML += `<option value="${k}">${v}</option>`; });
}

// ── Reports ──
let _allReports = [];
let _sortCol = 'date';
let _sortDir = 'desc';

async function loadReports() {
  const category = document.getElementById('filterCategory').value;
  const status = document.getElementById('filterStatus').value;
  const date = document.getElementById('filterDate').value;
  const tbody = document.getElementById('reportsBody');
  tbody.innerHTML = `<tr><td colspan="12" style="text-align:center;padding:40px">${t('loading')}</td></tr>`;

  try {
    let query = sb.from('reports').select('*, users!reports_user_id_fkey(username, email)').order('created_at', { ascending: false });
    if (category) query = query.eq('category', category);
    if (status) query = query.eq('status', status);
    if (date) query = query.gte('created_at', date + 'T00:00:00Z').lte('created_at', date + 'T23:59:59Z');

    const [
      { count: total },
      { count: pending },
      { count: validated },
      { count: falseR },
      { count: totalUsers },
      { data, error }
    ] = await Promise.all([
      sb.from('reports').select('*', { count: 'exact', head: true }),
      sb.from('reports').select('*', { count: 'exact', head: true }).eq('status', 'pending'),
      sb.from('reports').select('*', { count: 'exact', head: true }).eq('status', 'validated'),
      sb.from('reports').select('*', { count: 'exact', head: true }).eq('status', 'falseReport'),
      sb.from('users').select('*', { count: 'exact', head: true }),
      query
    ]);

    if (error) throw error;
    _allReports = data;

    // Stats
    document.getElementById('reportsStats').innerHTML = `
      <div class="stat-card"><div class="num">${total || 0}</div><div class="label">${t('totalReports')}</div></div>
      <div class="stat-card"><div class="num">${pending || 0}</div><div class="label">${t('pending')}</div></div>
      <div class="stat-card"><div class="num">${validated || 0}</div><div class="label">${t('validated')}</div></div>
      <div class="stat-card"><div class="num">${falseR || 0}</div><div class="label">${t('falseReport')}</div></div>
      <div class="stat-card"><div class="num">${totalUsers || 0}</div><div class="label">${t('usersTitle')}</div></div>
    `;

    renderCategoryChart(data);
    renderReportsTable(data);

  } catch (e) {
    document.getElementById('reportsBody').innerHTML = `<tr><td colspan="12" style="text-align:center;padding:40px;color:var(--danger)">${t('error')}: ${escapeHtml(e.message)}</td></tr>`;
  }
}

function renderReportsTable(data) {
  const tbody = document.getElementById('reportsBody');
  if (!data.length) {
    tbody.innerHTML = `<tr><td colspan="12"><div class="empty-state" style="text-align:center;padding:60px 20px;color:var(--muted)"><div style="font-size:48px;margin-bottom:12px;opacity:0.4">📭</div>${t('noReports')}</div></td></tr>`;
    return;
  }

  // Sort
  const sorted = [...data].sort((a, b) => {
    let va, vb;
    switch (_sortCol) {
      case 'id':       va = a.id; vb = b.id; break;
      case 'user':     va = (a.users?.username || ''); vb = (b.users?.username || ''); break;
      case 'category': va = catLabel(a.category); vb = catLabel(b.category); break;
      case 'date':     va = a.created_at; vb = b.created_at; break;
      case 'confirm':  va = a.confirm_count || 0; vb = b.confirm_count || 0; break;
      case 'deny':     va = a.deny_count || 0; vb = b.deny_count || 0; break;
      case 'cred': {
        const tv = (a.confirm_count||0)+(a.deny_count||0);
        const tw = (b.confirm_count||0)+(b.deny_count||0);
        va = tv > 0 ? (a.confirm_count||0)/tv : 0;
        vb = tw > 0 ? (b.confirm_count||0)/tw : 0;
        break;
      }
      case 'status':   va = a.status; vb = b.status; break;
      default:         va = a.id; vb = b.id;
    }
    if (va < vb) return _sortDir === 'asc' ? -1 : 1;
    if (va > vb) return _sortDir === 'asc' ? 1 : -1;
    return 0;
  });

  tbody.innerHTML = sorted.map((r, idx) => {
    const totalVotes = (r.confirm_count || 0) + (r.deny_count || 0);
    const credPct = totalVotes > 0 ? Math.round((r.confirm_count || 0) / totalVotes * 100) : 0;
    const credColor = credPct >= 70 ? '#16A34A' : credPct >= 40 ? '#F59E0B' : '#DC2626';
    const photoHtml = r.photo_url
      ? `<img src="${escapeHtml(r.photo_url)}" class="thumb" onerror="this.style.display='none'" loading="lazy">`
      : `<div class="thumb">📷</div>`;
    const userLabel = r.users?.username || r.users?.email || r.user_id?.substring(0,8) || '—';
    const rowBg = idx % 2 === 0 ? '#ffffff' : '#f8fafc';
    return `<tr style="cursor:pointer;background:${rowBg}" onclick="showReportDetail(${r.id})">
      <td style="font-weight:700;color:var(--muted);font-size:12px;width:52px">${r.id}</td>
      <td style="width:60px">${photoHtml}</td>
      <td style="min-width:120px"><div class="user-cell">${r.users?.username ? `<div class="avatar" style="background:${avatarColor(r.users.username)};width:28px;height:28px;font-size:11px">${(r.users.username||'?')[0].toUpperCase()}</div>` : ''}<span style="font-size:13px">${escapeHtml(userLabel)}</span></div></td>
      <td style="min-width:100px"><span style="display:inline-flex;align-items:center;gap:5px"><span style="width:9px;height:9px;border-radius:50%;background:${CATEGORY_COLORS[r.category]||'#888'};display:inline-block;flex-shrink:0"></span><span style="font-size:12px">${catLabel(r.category)}</span></span></td>
      <td style="max-width:180px"><div style="overflow:hidden;text-overflow:ellipsis;white-space:nowrap;font-size:13px" title="${escapeHtml(r.description||'')}">${escapeHtml((r.description||'').substring(0,60))}${(r.description||'').length>60?'…':''}</div></td>
      <td style="white-space:nowrap;font-size:12px;color:var(--muted)">${formatDate(r.created_at)}</td>
      <td style="font-size:11px;color:var(--muted);white-space:nowrap;min-width:90px">${r.latitude?.toFixed(3)||'—'},<br>${r.longitude?.toFixed(3)||'—'}</td>
      <td style="text-align:center;font-weight:700;color:var(--success)">${r.confirm_count||0}</td>
      <td style="text-align:center;font-weight:700;color:var(--danger)">${r.deny_count||0}</td>
      <td style="min-width:90px"><div class="cred-bar"><span style="font-size:12px;font-weight:700;color:${credColor};min-width:34px">${credPct}%</span><div class="bar"><div class="bar-fill" style="width:${credPct}%;background:${credColor}"></div></div></div></td>
      <td style="min-width:110px">
        <select class="status-select" data-id="${r.id}" onclick="event.stopPropagation()" onchange="changeStatus(${r.id}, this.value)" style="background:${statusBg(r.status)};color:${statusFg(r.status)};border-color:${statusFg(r.status)}40">
          <option value="pending" ${r.status==='pending'?'selected':''}>${t('statusPending')}</option>
          <option value="validated" ${r.status==='validated'?'selected':''}>${t('statusValidated')}</option>
          <option value="falseReport" ${r.status==='falseReport'?'selected':''}>${t('statusFalseReport')}</option>
        </select>
      </td>
      <td style="width:110px"><div class="actions" onclick="event.stopPropagation()">
        <button class="btn-view btn-icon-only" onclick="showReportDetail(${r.id})" title="${t('view')}">👁️</button>
        <button class="btn-delete btn-icon-only" onclick="deleteReport(${r.id})" title="${t('delete')}">🗑️</button>
      </div></td>
    </tr>`;
  }).join('');
}

// Sortable column headers
document.addEventListener('DOMContentLoaded', () => {
  document.querySelectorAll('#reportsTable th.sort-col').forEach(th => {
    th.addEventListener('click', () => {
      const col = th.dataset.col;
      if (_sortCol === col) {
        _sortDir = _sortDir === 'asc' ? 'desc' : 'asc';
      } else {
        _sortCol = col;
        _sortDir = col === 'date' ? 'desc' : 'asc';
      }
      document.querySelectorAll('#reportsTable th').forEach(h => h.classList.remove('sort-asc', 'sort-desc'));
      th.classList.add(_sortDir === 'asc' ? 'sort-asc' : 'sort-desc');
      renderReportsTable(_allReports);
    });
  });
});

async function changeStatus(id, newStatus) {
  try {
    const { data, error } = await sb.from('reports').update({ status: newStatus }).eq('id', id).select();
    if (error) throw error;
    if (!data || data.length === 0) { showToast(t('noPermission') || 'عذراً، لا تملك الصلاحية (RLS)', 'error'); return; }
    showToast(t('statusChanged'), 'success');
    loadReports();
  } catch (e) { showToast(t('statusFailed') + ': ' + e.message, 'error'); }
}

async function deleteReport(id) {
  if (!confirm(t('confirmDelete'))) return;
  try {
    const { data, error } = await sb.from('reports').delete().eq('id', id).select();
    if (error) throw error;
    if (!data || data.length === 0) { showToast(t('noPermission') || 'عذراً، لا تملك الصلاحية (RLS)', 'error'); return; }
    showToast(t('deleted'), 'success');
    loadReports();
  } catch (e) { showToast(t('deleteFailed') + ': ' + e.message, 'error'); }
}

// ── Report Detail Modal ──
function showReportDetail(r) {
  if (typeof r === 'number') {
    // Called with ID from button — fetch full data
    fetchReportDetail(r);
    return;
  }
  openModal(r);
}

async function fetchReportDetail(id) {
  try {
    const { data, error } = await sb.from('reports').select('*, users!reports_user_id_fkey(username, email)').eq('id', id).single();
    if (error) throw error;
    openModal(data);
  } catch (e) { showToast(t('error') + ': ' + e.message, 'error'); }
}

function openModal(r) {
  const totalVotes = (r.confirm_count || 0) + (r.deny_count || 0);
  const credPct = totalVotes > 0 ? Math.round((r.confirm_count || 0) / totalVotes * 100) : 0;
  const credColor = credPct >= 70 ? '#16A34A' : credPct >= 40 ? '#F59E0B' : '#DC2626';
  const modalBody = document.getElementById('modalBody');
  modalBody.innerHTML = `
    ${r.photo_url ? `<img src="${escapeHtml(r.photo_url)}" class="modal-photo" onerror="this.style.display='none'" loading="lazy">` : ''}
    <div class="field-row">
      <div class="field">
        <div class="field-label">${t('detailCategory')}</div>
        <div class="field-value"><span style="display:inline-flex;align-items:center;gap:6px"><span style="width:12px;height:12px;border-radius:50%;background:${CATEGORY_COLORS[r.category]||'#888'};display:inline-block"></span>${catLabel(r.category)}</span></div>
      </div>
      <div class="field">
        <div class="field-label">${t('detailStatus')}</div>
        <div class="field-value"><span class="badge badge-${r.status}">${t('status' + r.status.charAt(0).toUpperCase() + r.status.slice(1)) || r.status}</span></div>
      </div>
    </div>
    <div class="field">
      <div class="field-label">${t('detailUser')}</div>
      <div class="field-value">${escapeHtml(r.users?.username || r.users?.email || '—')}</div>
    </div>
    <div class="field">
      <div class="field-label">${t('detailDescription')}</div>
      <div class="field-value">${escapeHtml(r.description || '')}</div>
    </div>
    <div class="field-row">
      <div class="field">
        <div class="field-label">${t('detailLocation')}</div>
        <div class="field-value" style="font-size:13px;color:var(--text-secondary)">${r.latitude?.toFixed(4) || '—'}, ${r.longitude?.toFixed(4) || '—'}${r.address ? '<br>' + escapeHtml(r.address) : ''}</div>
      </div>
      <div class="field">
        <div class="field-label">${t('detailDate')}</div>
        <div class="field-value" style="font-size:13px">${formatDate(r.created_at)}</div>
      </div>
    </div>
    <div class="field">
      <div class="field-label">${t('detailVotes')} (${totalVotes})</div>
      <div style="display:flex;gap:24px;align-items:center">
        <span style="font-size:15px;font-weight:600;color:var(--success)">✅ ${r.confirm_count||0} ${t('detailConfirm')}</span>
        <span style="font-size:15px;font-weight:600;color:var(--danger)">❌ ${r.deny_count||0} ${t('detailDeny')}</span>
      </div>
    </div>
    <div class="field">
      <div class="field-label">${t('detailCredibility')}</div>
      <div class="cred-bar"><span style="font-size:18px;font-weight:800;color:${credColor};min-width:48px">${credPct}%</span><div class="bar" style="width:100%"><div class="bar-fill" style="width:${credPct}%;background:${credColor}"></div></div></div>
    </div>
  `;
  document.getElementById('reportModal').classList.add('open');
}

function closeModal() {
  document.getElementById('reportModal').classList.remove('open');
}
document.getElementById('reportModal').addEventListener('click', function(e) {
  if (e.target === this) closeModal();
});

// ── Users ──
async function loadUsers() {
  const tbody = document.getElementById('usersBody');
  tbody.innerHTML = `<tr><td colspan="9" style="text-align:center;padding:40px">${t('loading')}</td></tr>`;
  try {
    const { data, error } = await sb.from('users').select('*').order('created_at', { ascending: false });
    if (error) throw error;
    if (!data.length) {
      tbody.innerHTML = `<tr><td colspan="9"><div class="empty-state" style="text-align:center;padding:60px 20px;color:var(--muted)"><div style="font-size:48px;margin-bottom:12px;opacity:0.4">👥</div>${t('noUsers')}</div></td></tr>`;
      return;
    }
    tbody.innerHTML = data.map(u => `
      <tr>
        <td><div class="avatar" style="background:${avatarColor(u.username)}">${(u.username || u.email || '?')[0].toUpperCase()}</div></td>
        <td><strong>${escapeHtml(u.username || '—')}</strong></td>
        <td style="font-size:13px;color:var(--muted)">${escapeHtml(u.email || '—')}</td>
        <td style="font-size:13px;color:var(--muted);white-space:nowrap">${formatDate(u.created_at)}</td>
        <td style="text-align:center">${u.reports_count ?? 0}</td>
        <td style="text-align:center">${u.confirmed_count ?? 0}</td>
        <td style="text-align:center"><span style="font-weight:700;color:${(u.reputation_score||0) >= 50 ? 'var(--success)' : (u.reputation_score||0) >= 20 ? 'var(--warning)' : 'var(--muted)'}">${u.reputation_score ?? 0}</span></td>
        <td><button class="toggle ${u.is_admin ? 'on' : ''}" onclick="toggleAdmin('${u.id}', ${!u.is_admin})"></button></td>
        <td><div class="actions"><button class="btn-delete" onclick="deleteUser('${u.id}')">🗑️</button></div></td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="9" style="text-align:center;padding:40px;color:var(--danger)">${t('error')}: ${escapeHtml(e.message)}</td></tr>`;
  }
}

async function toggleAdmin(userId, makeAdmin) {
  try {
    const { data, error } = await sb.from('users').update({ is_admin: makeAdmin }).eq('id', userId).select();
    if (error) throw error;
    if (!data || data.length === 0) { showToast(t('noPermission') || 'عذراً، لا تملك الصلاحية (RLS)', 'error'); return; }
    showToast(t('adminUpdated'), 'success');
    loadUsers();
  } catch (e) { showToast(e.message, 'error'); }
}

async function deleteUser(id) {
  if (!confirm(t('confirmDeleteUser'))) return;
  try {
    const { data, error } = await sb.from('users').delete().eq('id', id).select();
    if (error) throw error;
    if (!data || data.length === 0) { showToast(t('noPermission') || 'عذراً، لا تملك الصلاحية (RLS)', 'error'); return; }
    showToast(t('userDeleted'), 'success');
    loadUsers();
  } catch (e) { showToast(t('userDeleteFailed') + ': ' + e.message, 'error'); }
}

// ── Notifications ──
async function loadNotifications() {
  const tbody = document.getElementById('notificationsBody');
  tbody.innerHTML = `<tr><td colspan="4" style="text-align:center;padding:40px">${t('loading')}</td></tr>`;
  try {
    const { data, error } = await sb.from('notifications')
      .select('*, users!notifications_user_id_fkey(username, email)')
      .order('created_at', { ascending: false }).limit(100);
    if (error) throw error;
    const badge = document.getElementById('unreadBadge');
    if (badge) {
      const unreadCount = data.filter(n => !n.is_read).length;
      badge.textContent = unreadCount;
      badge.style.display = unreadCount > 0 ? 'inline-block' : 'none';
    }

    if (!data.length) {
      tbody.innerHTML = `<tr><td colspan="4"><div class="empty-state" style="text-align:center;padding:60px 20px;color:var(--muted)"><div style="font-size:48px;margin-bottom:12px;opacity:0.4">🔔</div>${t('noNotifications')}</div></td></tr>`;
      return;
    }
    tbody.innerHTML = data.map(n => `
      <tr>
        <td><div class="user-cell">${n.users?.username ? `<div class="avatar" style="background:${avatarColor(n.users.username)};width:28px;height:28px;font-size:11px">${n.users.username[0].toUpperCase()}</div>` : ''}<span>${escapeHtml(n.users?.username || n.users?.email || n.user_id?.substring(0,8) || '—')}</span></div></td>
        <td class="truncate" style="max-width:300px">${escapeHtml(n.message || '')}</td>
        <td style="font-size:12px;color:var(--muted);white-space:nowrap">${formatDate(n.created_at)}</td>
        <td>${n.is_read ? '✅ ' + t('read') : '🔴 ' + t('unread')}</td>
      </tr>
    `).join('');
  } catch (e) {
    tbody.innerHTML = `<tr><td colspan="4" style="text-align:center;padding:40px;color:var(--danger)">${t('error')}: ${escapeHtml(e.message)}</td></tr>`;
  }
}

async function markAllNotificationsRead() {
  try {
    const { data, error } = await sb.from('notifications').update({ is_read: true }).eq('is_read', false).select();
    if (error) throw error;
    if (!data || data.length === 0) {
      showToast('لا توجد إشعارات غير مقروءة أو لا تملك الصلاحية', 'error'); 
      return; 
    }
    showToast('تم التحديث بنجاح', 'success');
    loadNotifications();
  } catch(e) {
    showToast(e.message, 'error');
  }
}

// ── Chart ──
function renderCategoryChart(reports) {
  const ctx = document.getElementById('categoryChart').getContext('2d');
  if (categoryChart) categoryChart.destroy();

  if (!reports || reports.length === 0) return;

  const counts = {};
  reports.forEach(r => { counts[r.category] = (counts[r.category] || 0) + 1; });
  const labels = Object.keys(counts).map(k => catLabel(k));
  const values = Object.values(counts);
  const colors = Object.keys(counts).map(k => CATEGORY_COLORS[k] || '#888');

  categoryChart = new Chart(ctx, {
    type: 'bar',
    data: {
      labels,
      datasets: [{
        data: values,
        backgroundColor: colors,
        borderRadius: 4,
        borderSkipped: false,
      }]
    },
    options: {
      responsive: true,
      maintainAspectRatio: true,
      plugins: { legend: { display: false } },
      scales: {
        y: { beginAtZero: true, ticks: { stepSize: 1, font: { size: 11 } }, grid: { color: '#f0f0f0' } },
        x: { ticks: { font: { size: 10 } }, grid: { display: false } }
      }
    }
  });
}

// ── Helpers ──
function formatDate(d) {
  if (!d) return '—';
  const dt = new Date(d);
  const locale = currentLang === 'fr' ? 'fr-FR' : 'ar-SA';
  return dt.toLocaleDateString(locale, { year: 'numeric', month: 'short', day: 'numeric', hour: '2-digit', minute: '2-digit' });
}
function statusBg(s) { return s === 'pending' ? '#FFF8E1' : s === 'validated' ? '#E8F5E9' : '#FFEBEE'; }
function statusFg(s) { return s === 'pending' ? '#F9A825' : s === 'validated' ? '#2E7D32' : '#C62828'; }
function escapeHtml(str) { if (typeof str !== 'string') return str || ''; const d = document.createElement('div'); d.textContent = str; return d.innerHTML; }
function avatarColor(name) {
  const colors = ['#1B6B2F','#1565C0','#6A1B9A','#C62828','#2E7D32','#E65100','#00838F','#4A148C','#01579B','#F57F17','#283593','#AD1457'];
  let hash = 0; const s = name || '?';
  for (let i = 0; i < s.length; i++) hash = s.charCodeAt(i) + ((hash << 5) - hash);
  return colors[Math.abs(hash) % colors.length];
}

// ── Auto-login ──
(async () => {
  document.documentElement.dir = currentLang === 'ar' ? 'rtl' : 'ltr';
  applyLang();
  document.getElementById('langToggle').textContent = t('langToggle');
  const { data: { session } } = await sb.auth.getSession();
  if (session?.user) {
    const { data: profile } = await sb.from('users').select('*').eq('id', session.user.id).single();
    if (profile && profile.is_admin) {
      currentUser = profile;
      document.getElementById('loginPage').style.display = 'none';
      document.getElementById('dashboard').style.display = 'block';
      document.getElementById('userInfo').textContent = `👤 ${profile.username || profile.email}`;
      initCategoryFilter();
      loadReports(); loadUsers(); loadNotifications();
    }
  }
})();