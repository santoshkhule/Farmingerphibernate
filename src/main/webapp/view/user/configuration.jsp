<%@page import="com.san.farm.adminuser.entity.UserTypeEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.dao.UserTypeService"%>
<%@page import="com.san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@page import="com.san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="com.san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.trim().isEmpty()) activeTab = "userType";

    UserTypeService         utSvc   = new UserTypeService();
    ConfigSiteInformationService siSvc = new ConfigSiteInformationService();
    ConfigCropService       crSvc   = new ConfigCropService();
    ConfigFarmTaskService   ftSvc   = new ConfigFarmTaskService();

    List<UserTypeEntity>              utList = utSvc.fetch();
    List<ConfigSiteInformationEntity> siList = siSvc.fetch();
    List<ConfigCropEntity>            crList = crSvc.fetch();
    List<ConfigFarmTaskEntity>        ftList = ftSvc.fetch();
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title>Configuration for Farming</title>
<style>
    /* ── tab nav ── */
    .cfg-tabs          { display:flex; flex-wrap:wrap; gap:3px;
                         border-bottom:2px solid var(--green-dk,#2e7d32);
                         margin-bottom:20px; }
    .cfg-tab-btn       { background:#f5f5f5; border:1px solid #ccc; border-bottom:none;
                         padding:9px 24px; cursor:pointer; font-size:13px; font-weight:600;
                         color:#555; border-radius:4px 4px 0 0;
                         transition:background .15s, color .15s; }
    .cfg-tab-btn:hover { background:#e8f5e9; color:var(--green-dk,#2e7d32); border-color:var(--green-bd,#a5d6a7); }
    .cfg-tab-btn.active{ background:var(--green-dk,#2e7d32); color:#fff;
                         border-color:var(--green-dk,#2e7d32); }
    .cfg-tab-panel     { display:none; }
    .cfg-tab-panel.active { display:block; }

    /* ── form card ── */
    .cfg-form-card     { background:#f8fdf8; border:1px solid var(--green-bd,#a5d6a7);
                         border-radius:6px; padding:16px 20px; margin-bottom:16px; }
    .cfg-edit-banner   { display:none; background:#fff8e1; border:1px solid #ffc107;
                         color:#856404; padding:6px 12px; border-radius:4px;
                         margin-bottom:10px; font-weight:700; font-size:13px; }
    .cfg-form-row      { display:flex; flex-wrap:wrap; align-items:flex-end; gap:12px 20px; }
    .cfg-field         { display:flex; flex-direction:column; gap:4px; min-width:160px; }
    .cfg-field label   { font-size:11px; font-weight:700; text-transform:uppercase;
                         letter-spacing:.4px; color:var(--text-muted,#666); }
    .cfg-field input   { padding:6px 9px; border:1px solid #ccc; border-radius:4px;
                         font-size:13px; width:100%; box-sizing:border-box; }
    .cfg-field input:focus { border-color:var(--green-dk,#2e7d32); outline:none;
                             box-shadow:0 0 0 2px rgba(46,125,50,.15); }

    /* ── bulk bar ── */
    .cfg-bulk-bar      { display:none; background:#fdecea; border:1px solid #e06060;
                         border-radius:4px; padding:8px 14px; margin-bottom:10px;
                         font-size:13px; align-items:center; gap:10px; }
    .cfg-bulk-bar.show { display:flex; }

    /* ── buttons ── */
    .btn-add    { background:var(--green-dk,#2e7d32); color:#fff; border:none; padding:7px 18px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-update { background:#1565c0; color:#fff; border:none; padding:7px 18px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-delete { background:#c62828; color:#fff; border:none; padding:6px 14px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-cancel { background:#fff; color:#555; border:1px solid #bbb; padding:6px 14px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-add:hover    { background:#1b5e20; }
    .btn-update:hover { background:#0d47a1; }
    .btn-delete:hover { background:#b71c1c; }
    .btn-cancel:hover { background:#f5f5f5; }
    .btn-row-edit { background:#e8f5e9; border:1px solid var(--green-bd,#a5d6a7); color:var(--green-dk,#2e7d32);
                    padding:3px 10px; border-radius:3px; font-size:12px; font-weight:600; cursor:pointer; }
    .btn-row-edit:hover { background:#c8e6c9; }

    /* ── table ── */
    .cfg-table         { width:100%; border-collapse:collapse; font-size:13px; }
    .cfg-table thead th{ background:var(--green-dk,#2e7d32); color:#fff; padding:9px 10px;
                         text-align:left; font-size:12px; text-transform:uppercase; letter-spacing:.4px; }
    .cfg-table thead th:first-child { border-radius:0; }
    .cfg-table tbody tr:nth-child(even) { background:#f5fdf5; }
    .cfg-table tbody tr:hover { background:#e8f5e9; }
    .cfg-table tbody tr.sel-row { background:#c8e6c9 !important; font-weight:600; }
    .cfg-table td      { padding:7px 10px; border-bottom:1px solid #e8e8e8; vertical-align:middle; }
    .cfg-table td.center { text-align:center; }

    /* ── summary chips ── */
    .cfg-count-chip    { display:inline-flex; align-items:center; gap:6px;
                         background:#e8f5e9; border:1px solid var(--green-bd,#a5d6a7);
                         border-radius:20px; padding:3px 12px; font-size:12px;
                         font-weight:700; color:var(--green-dk,#2e7d32); margin-bottom:10px; }
</style>
</head>
<body>
<%@include file="../../header.jsp"%>
<fieldset>
<legend>Configuration for Farming</legend>

<!-- Tab nav -->
<div class="cfg-tabs">
    <button class="cfg-tab-btn<%="userType".equals(activeTab)?" active":""%>" onclick="switchTab('userType')">User Type</button>
    <button class="cfg-tab-btn<%="site".equals(activeTab)?" active":""%>"     onclick="switchTab('site')">Site Information</button>
    <button class="cfg-tab-btn<%="crop".equals(activeTab)?" active":""%>"     onclick="switchTab('crop')">Crops</button>
    <button class="cfg-tab-btn<%="task".equals(activeTab)?" active":""%>"     onclick="switchTab('task')">Farming Task</button>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 1 : User Type
     ══════════════════════════════════════════════════ -->
<div id="tab-userType" class="cfg-tab-panel<%="userType".equals(activeTab)?" active":""%>">

    <span class="cfg-count-chip"><%=utList.size()%> User Types</span>

    <form method="post" id="ut_frm" action="../../UserTypeController">
        <input type="hidden" name="userTypeId" id="ut_id">
        <div class="cfg-form-card">
            <div class="cfg-edit-banner" id="ut_banner"></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="ut_name">User Type Name</label>
                    <input type="text" name="userType" id="ut_name" required placeholder="e.g. Admin, Supervisor">
                </div>
                <div style="display:flex; gap:8px; align-items:flex-end; padding-bottom:1px;">
                    <input type="submit" class="btn-add"    id="ut_btnAdd"    name="add"  value="Add">
                    <input type="submit" class="btn-update" id="ut_btnUpdate" name="edit" value="Update" style="display:none">
                    <button type="button" class="btn-cancel" id="ut_btnCancel" style="display:none" onclick="cfgReset('ut')">Cancel</button>
                </div>
            </div>
        </div>
    </form>

    <div class="cfg-bulk-bar" id="ut_bulkBar">
        <span><strong id="ut_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('ut','../../UserTypeController')">Delete Selected</button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('ut')">Clear</button>
    </div>
    <form method="post" id="ut_frmBulk" action="../../UserTypeController"></form>

    <table class="cfg-table tbl-data" id="ut_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="ut_chkAll" onclick="cfgToggleAll('ut',this)"></th>
            <th width="7%">ID</th>
            <th>User Type</th>
            <th width="10%" style="text-align:center;">Action</th>
        </tr></thead>
        <tbody>
        <% for (UserTypeEntity u : utList) {
               String utEsc = u.getUserType() != null ? u.getUserType().replace("\\","\\\\").replace("'","\\'") : ""; %>
        <tr id="ut_row<%=u.getUserTypeId()%>">
            <td class="center"><input type="checkbox" class="ut_chk" value="<%=u.getUserTypeId()%>" onchange="cfgUpdateBulkBar('ut','ut_chk')"></td>
            <td><%=u.getUserTypeId()%></td>
            <td><%=u.getUserType()%></td>
            <td class="center">
                <button type="button" class="btn-row-edit"
                    onclick="cfgEditRow1('ut','<%=u.getUserTypeId()%>','<%=utEsc%>','ut_name','<%=utEsc%>')">Edit</button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 2 : Site Information
     ══════════════════════════════════════════════════ -->
<div id="tab-site" class="cfg-tab-panel<%="site".equals(activeTab)?" active":""%>">

    <span class="cfg-count-chip"><%=siList.size()%> Sites</span>

    <form method="post" id="si_frm" action="../../ConfigSiteInformationController">
        <input type="hidden" name="siteInfoId" id="si_id">
        <div class="cfg-form-card">
            <div class="cfg-edit-banner" id="si_banner"></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:200px;">
                    <label for="si_siteName">Site Name</label>
                    <input type="text" name="siteName" id="si_siteName" required placeholder="Farm / Plot name">
                </div>
                <div class="cfg-field" style="min-width:130px;">
                    <label for="si_siteArea">Area (acres)</label>
                    <input type="text" name="siteArea" id="si_siteArea" required placeholder="e.g. 2.5" pattern="[0-9]+(\.[0-9]+)?">
                </div>
                <div class="cfg-field" style="min-width:200px;">
                    <label for="si_siteLocation">Location</label>
                    <input type="text" name="siteLocation" id="si_siteLocation" required placeholder="Village / District">
                </div>
                <div style="display:flex; gap:8px; align-items:flex-end; padding-bottom:1px;">
                    <input type="submit" class="btn-add"    id="si_btnAdd"    name="add"  value="Add">
                    <input type="submit" class="btn-update" id="si_btnUpdate" name="edit" value="Update" style="display:none">
                    <button type="button" class="btn-cancel" id="si_btnCancel" style="display:none" onclick="cfgReset('si')">Cancel</button>
                </div>
            </div>
        </div>
    </form>

    <div class="cfg-bulk-bar" id="si_bulkBar">
        <span><strong id="si_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('si','../../ConfigSiteInformationController')">Delete Selected</button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('si')">Clear</button>
    </div>
    <form method="post" id="si_frmBulk" action="../../ConfigSiteInformationController"></form>

    <table class="cfg-table tbl-data" id="si_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="si_chkAll" onclick="cfgToggleAll('si',this)"></th>
            <th width="6%">ID</th>
            <th>Site Name</th>
            <th width="12%">Area (acres)</th>
            <th>Location</th>
            <th width="9%" style="text-align:center;">Action</th>
        </tr></thead>
        <tbody>
        <% for (ConfigSiteInformationEntity s : siList) {
               String siEscName = s.getSiteName()     != null ? s.getSiteName().replace("\\","\\\\").replace("'","\\'") : "";
               String siEscLoc  = s.getSiteLocation() != null ? s.getSiteLocation().replace("\\","\\\\").replace("'","\\'") : "";
               String siArea    = String.valueOf(s.getSiteArea()); %>
        <tr id="si_row<%=s.getSiteInfoId()%>">
            <td class="center"><input type="checkbox" class="si_chk" value="<%=s.getSiteInfoId()%>" onchange="cfgUpdateBulkBar('si','si_chk')"></td>
            <td><%=s.getSiteInfoId()%></td>
            <td><%=s.getSiteName()%></td>
            <td><%=siArea%></td>
            <td><%=s.getSiteLocation() != null ? s.getSiteLocation() : ""%></td>
            <td class="center">
                <button type="button" class="btn-row-edit"
                    onclick="siEditRow(<%=s.getSiteInfoId()%>,'<%=siEscName%>','<%=siArea%>','<%=siEscLoc%>')">Edit</button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 3 : Crops
     ══════════════════════════════════════════════════ -->
<div id="tab-crop" class="cfg-tab-panel<%="crop".equals(activeTab)?" active":""%>">

    <span class="cfg-count-chip"><%=crList.size()%> Crops</span>

    <form method="post" id="cr_frm" action="../../ConfigCropController">
        <input type="hidden" name="cropId" id="cr_id">
        <div class="cfg-form-card">
            <div class="cfg-edit-banner" id="cr_banner"></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="cr_cropName">Crop Name</label>
                    <input type="text" name="cropName" id="cr_cropName" required placeholder="e.g. Wheat, Rice, Cotton">
                </div>
                <div style="display:flex; gap:8px; align-items:flex-end; padding-bottom:1px;">
                    <input type="submit" class="btn-add"    id="cr_btnAdd"    name="add"  value="Add">
                    <input type="submit" class="btn-update" id="cr_btnUpdate" name="edit" value="Update" style="display:none">
                    <button type="button" class="btn-cancel" id="cr_btnCancel" style="display:none" onclick="cfgReset('cr')">Cancel</button>
                </div>
            </div>
        </div>
    </form>

    <div class="cfg-bulk-bar" id="cr_bulkBar">
        <span><strong id="cr_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('cr','../../ConfigCropController')">Delete Selected</button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('cr')">Clear</button>
    </div>
    <form method="post" id="cr_frmBulk" action="../../ConfigCropController"></form>

    <table class="cfg-table tbl-data" id="cr_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="cr_chkAll" onclick="cfgToggleAll('cr',this)"></th>
            <th width="8%">ID</th>
            <th>Crop Name</th>
            <th width="10%" style="text-align:center;">Action</th>
        </tr></thead>
        <tbody>
        <% for (ConfigCropEntity c : crList) {
               String crEsc = c.getCropName() != null ? c.getCropName().replace("\\","\\\\").replace("'","\\'") : ""; %>
        <tr id="cr_row<%=c.getCropId()%>">
            <td class="center"><input type="checkbox" class="cr_chk" value="<%=c.getCropId()%>" onchange="cfgUpdateBulkBar('cr','cr_chk')"></td>
            <td><%=c.getCropId()%></td>
            <td><%=c.getCropName()%></td>
            <td class="center">
                <button type="button" class="btn-row-edit"
                    onclick="cfgEditRow1('cr','<%=c.getCropId()%>','<%=crEsc%>','cr_cropName','<%=crEsc%>')">Edit</button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 4 : Farming Task
     ══════════════════════════════════════════════════ -->
<div id="tab-task" class="cfg-tab-panel<%="task".equals(activeTab)?" active":""%>">

    <span class="cfg-count-chip"><%=ftList.size()%> Tasks</span>

    <form method="post" id="ft_frm" action="../../ConfigFarmTaskController">
        <input type="hidden" name="taskId" id="ft_id">
        <div class="cfg-form-card">
            <div class="cfg-edit-banner" id="ft_banner"></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="ft_taskName">Task Name</label>
                    <input type="text" name="taskName" id="ft_taskName" required placeholder="e.g. Ploughing, Irrigation">
                </div>
                <div style="display:flex; gap:8px; align-items:flex-end; padding-bottom:1px;">
                    <input type="submit" class="btn-add"    id="ft_btnAdd"    name="add"  value="Add">
                    <input type="submit" class="btn-update" id="ft_btnUpdate" name="edit" value="Update" style="display:none">
                    <button type="button" class="btn-cancel" id="ft_btnCancel" style="display:none" onclick="cfgReset('ft')">Cancel</button>
                </div>
            </div>
        </div>
    </form>

    <div class="cfg-bulk-bar" id="ft_bulkBar">
        <span><strong id="ft_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('ft','../../ConfigFarmTaskController')">Delete Selected</button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('ft')">Clear</button>
    </div>
    <form method="post" id="ft_frmBulk" action="../../ConfigFarmTaskController"></form>

    <table class="cfg-table tbl-data" id="ft_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="ft_chkAll" onclick="cfgToggleAll('ft',this)"></th>
            <th width="8%">ID</th>
            <th>Task Name</th>
            <th width="10%" style="text-align:center;">Action</th>
        </tr></thead>
        <tbody>
        <% for (ConfigFarmTaskEntity t : ftList) {
               String ftEsc = t.getTaskName() != null ? t.getTaskName().replace("\\","\\\\").replace("'","\\'") : ""; %>
        <tr id="ft_row<%=t.getTaskId()%>">
            <td class="center"><input type="checkbox" class="ft_chk" value="<%=t.getTaskId()%>" onchange="cfgUpdateBulkBar('ft','ft_chk')"></td>
            <td><%=t.getTaskId()%></td>
            <td><%=t.getTaskName()%></td>
            <td class="center">
                <button type="button" class="btn-row-edit"
                    onclick="cfgEditRow1('ft','<%=t.getTaskId()%>','<%=ftEsc%>','ft_taskName','<%=ftEsc%>')">Edit</button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

</fieldset>
<%@include file="../../footer.jsp"%>

<script>
/* ── tab switching ── */
var dtMap = {};

function switchTab(name) {
    document.querySelectorAll('.cfg-tab-panel').forEach(function(p) { p.classList.remove('active'); });
    document.querySelectorAll('.cfg-tab-btn').forEach(function(b)   { b.classList.remove('active'); });
    document.getElementById('tab-' + name).classList.add('active');
    document.querySelectorAll('.cfg-tab-btn').forEach(function(b) {
        if (b.getAttribute('onclick') === "switchTab('" + name + "')") b.classList.add('active');
    });
    /* adjust DataTables column widths for newly visible table */
    if (dtMap[name]) {
        dtMap[name].columns.adjust().draw(false);
    }
    history.replaceState(null, '', '?tab=' + name);
}

/* ── DataTables init (after document ready from header tableInit.js) ── */
$(document).ready(function () {
    ['ut_table','si_table','cr_table','ft_table'].forEach(function(id) {
        var tabKey = {ut_table:'userType', si_table:'site', cr_table:'crop', ft_table:'task'}[id];
        var dt;
        if ($.fn.DataTable.isDataTable('#' + id)) {
            dt = $('#' + id).DataTable();
        } else {
            dt = $('#' + id).DataTable({
                pageLength: 25,
                autoWidth: false,
                language: {
                    search: '', searchPlaceholder: 'Search...',
                    lengthMenu: 'Show _MENU_ entries',
                    info: '_START_ - _END_ of _TOTAL_',
                    infoEmpty: '0 entries', emptyTable: 'No records found',
                    paginate: { previous: '&#8249;', next: '&#8250;' }
                }
            });
        }
        dtMap[tabKey] = dt;
    });
});

/* ── generic single-field edit (User Type, Crop, Farm Task) ──
   p       = prefix ('ut','cr','ft')
   id      = record id
   label   = shown in edit banner
   fieldId = element id of the single text input
   val     = field value
*/
function cfgEditRow1(p, id, label, fieldId, val) {
    var oldRow = document.querySelector('#tab-' + _tabForPrefix(p) + ' tr.sel-row');
    if (oldRow) oldRow.classList.remove('sel-row');
    var row = document.getElementById(p + '_row' + id);
    if (row) row.classList.add('sel-row');

    document.getElementById(p + '_id').value = id;
    document.getElementById(fieldId).value   = val;

    _cfgShowEditMode(p, label);
}

/* Site Information has 3 extra fields */
function siEditRow(id, name, area, loc) {
    var oldRow = document.querySelector('#tab-site tr.sel-row');
    if (oldRow) oldRow.classList.remove('sel-row');
    var row = document.getElementById('si_row' + id);
    if (row) row.classList.add('sel-row');

    document.getElementById('si_id').value           = id;
    document.getElementById('si_siteName').value     = name;
    document.getElementById('si_siteArea').value     = area;
    document.getElementById('si_siteLocation').value = loc;

    _cfgShowEditMode('si', name);
}

function _cfgShowEditMode(p, label) {
    var banner = document.getElementById(p + '_banner');
    banner.innerText     = 'Editing: ' + label;
    banner.style.display = 'block';
    document.getElementById(p + '_btnAdd').style.display    = 'none';
    document.getElementById(p + '_btnUpdate').style.display = 'inline-block';
    document.getElementById(p + '_btnCancel').style.display = 'inline-block';
    document.getElementById(p + '_frm').scrollIntoView({behavior:'smooth', block:'nearest'});
}

function cfgReset(p) {
    var panel = document.getElementById('tab-' + _tabForPrefix(p));
    var oldRow = panel ? panel.querySelector('tr.sel-row') : null;
    if (oldRow) oldRow.classList.remove('sel-row');

    /* clear all text inputs in the form card */
    document.querySelectorAll('#' + p + '_frm input[type=text], #' + p + '_frm input[type=hidden]:not([name$="Id"])').forEach(function(el) {
        el.value = '';
    });
    document.getElementById(p + '_id').value = '';
    document.getElementById(p + '_banner').style.display    = 'none';
    document.getElementById(p + '_btnAdd').style.display    = 'inline-block';
    document.getElementById(p + '_btnUpdate').style.display = 'none';
    document.getElementById(p + '_btnCancel').style.display = 'none';
}

/* ── checkbox / bulk delete ── */
function cfgToggleAll(p, chk) {
    document.querySelectorAll('.' + p + '_chk').forEach(function(b) { b.checked = chk.checked; });
    cfgUpdateBulkBar(p, p + '_chk');
}

function cfgUpdateBulkBar(p, cls) {
    var checked = document.querySelectorAll('.' + cls + ':checked');
    var all     = document.querySelectorAll('.' + cls);
    var bar = document.getElementById(p + '_bulkBar');
    if (checked.length > 0) {
        bar.classList.add('show');
        document.getElementById(p + '_selCount').innerText = checked.length;
    } else {
        bar.classList.remove('show');
        document.getElementById(p + '_chkAll').checked = false;
    }
    document.getElementById(p + '_chkAll').checked = (checked.length === all.length && all.length > 0);
}

function cfgDeleteSelected(p, action) {
    var checked = document.querySelectorAll('.' + p + '_chk:checked');
    if (checked.length === 0) return;
    if (!confirm('Delete ' + checked.length + ' selected record(s)?')) return;
    var form = document.getElementById(p + '_frmBulk');
    form.innerHTML = '';
    form.action = action;
    checked.forEach(function(b) {
        var inp = document.createElement('input');
        inp.type = 'hidden'; inp.name = 'deleteIds'; inp.value = b.value;
        form.appendChild(inp);
    });
    var flag = document.createElement('input');
    flag.type = 'hidden'; flag.name = 'deleteSelected'; flag.value = '1';
    form.appendChild(flag);
    form.submit();
}

function cfgClearSelection(p) {
    document.querySelectorAll('.' + p + '_chk').forEach(function(b) { b.checked = false; });
    document.getElementById(p + '_chkAll').checked = false;
    document.getElementById(p + '_bulkBar').classList.remove('show');
}

function _tabForPrefix(p) {
    return {ut:'userType', si:'site', cr:'crop', ft:'task'}[p] || p;
}
</script>
</body>
</html>
