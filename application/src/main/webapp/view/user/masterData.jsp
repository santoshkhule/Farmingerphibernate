<%@page import="com.san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.entity.CategoryEntity"%>
<%@page import="com.san.farm.adminuser.entity.FertilizerEntity"%>
<%@page import="com.san.farm.adminuser.entity.BrandEntity"%>
<%@page import="com.san.farm.adminuser.entity.UnitEntity"%>
<%@page import="com.san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@page import="com.san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="com.san.farm.adminuser.dao.ConfigFarmTaskService"%>
<%@page import="com.san.farm.adminuser.dao.CategoryService"%>
<%@page import="com.san.farm.adminuser.dao.FertilizerService"%>
<%@page import="com.san.farm.adminuser.dao.BrandService"%>
<%@page import="com.san.farm.adminuser.dao.UnitService"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ include file="../../lang.jsp" %>
<%
    String activeTab = request.getParameter("tab");
    if (activeTab == null || activeTab.trim().isEmpty()) activeTab = "site";

    ConfigSiteInformationService siSvc = new ConfigSiteInformationService();
    ConfigCropService            crSvc = new ConfigCropService();
    ConfigFarmTaskService        ftSvc = new ConfigFarmTaskService();
    CategoryService              caSvc = new CategoryService();
    FertilizerService            prSvc = new FertilizerService();
    BrandService                 brSvc = new BrandService();
    UnitService                  unSvc = new UnitService();

    List<ConfigSiteInformationEntity> siList = siSvc.fetch();
    List<ConfigCropEntity>            crList = crSvc.fetch();
    List<ConfigFarmTaskEntity>        ftList = ftSvc.fetch();
    List<CategoryEntity>              caList = caSvc.fetch();
    List<FertilizerEntity>            prList = prSvc.fetch();
    List<BrandEntity>                 brList = brSvc.fetch();
    List<UnitEntity>                  unList = unSvc.fetch();
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title><%= msg.getString("config.page_title") %></title>
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

    /* ── add-new form card ── */
    .cfg-form-card     { background:#f8fdf8; border:1px solid var(--green-bd,#a5d6a7);
                         border-radius:6px; padding:14px 18px; margin-bottom:16px; }
    .cfg-form-card-title { font-size:11px; font-weight:700; text-transform:uppercase;
                           letter-spacing:.5px; color:var(--green-dk,#2e7d32); margin-bottom:10px; }
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

    /* ── shared buttons ── */
    .btn-add        { background:var(--green-dk,#2e7d32); color:#fff; border:none; padding:7px 18px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-add:hover  { background:#1b5e20; }
    .btn-delete     { background:#c62828; color:#fff; border:none; padding:6px 14px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-delete:hover { background:#b71c1c; }
    .btn-cancel     { background:#fff; color:#555; border:1px solid #bbb; padding:6px 14px; border-radius:4px; font-size:13px; font-weight:600; cursor:pointer; }
    .btn-cancel:hover { background:#f5f5f5; }

    /* ── inline row edit buttons ── */
    .btn-row-edit   { background:#e8f5e9; border:1px solid var(--green-bd,#a5d6a7); color:var(--green-dk,#2e7d32);
                      padding:3px 10px; border-radius:3px; font-size:12px; font-weight:600; cursor:pointer; }
    .btn-row-edit:hover { background:#c8e6c9; }
    .btn-row-save   { background:#1565c0; color:#fff; border:none; padding:3px 10px; border-radius:3px; font-size:12px; font-weight:600; cursor:pointer; }
    .btn-row-save:hover { background:#0d47a1; }
    .btn-row-cancel { background:#fff; color:#666; border:1px solid #bbb; padding:3px 8px; border-radius:3px; font-size:12px; cursor:pointer; }
    .btn-row-cancel:hover { background:#f5f5f5; }

    /* ── inline edit input inside table cell ── */
    .inp-inline     { padding:4px 7px; border:1px solid var(--green-bd,#a5d6a7); border-radius:3px;
                      font-size:13px; width:100%; box-sizing:border-box; min-width:100px; }
    .inp-inline:focus { border-color:var(--green-dk,#2e7d32); outline:none; }
    .inp-inline-sm  { width:80px; }
    tr.editing-row  { background:#fff8e1 !important; }

    /* ── table ── */
    .cfg-table         { width:100%; border-collapse:collapse; font-size:13px; }
    .cfg-table thead th{ background:var(--green-dk,#2e7d32); color:#fff; padding:9px 10px;
                         text-align:left; font-size:12px; text-transform:uppercase; letter-spacing:.4px; }
    .cfg-table tbody tr:nth-child(even) { background:#f5fdf5; }
    .cfg-table tbody tr:hover { background:#e8f5e9; }
    .cfg-table td      { padding:6px 10px; border-bottom:1px solid #e8e8e8; vertical-align:middle; }
    .cfg-table td.center { text-align:center; }

    /* ── inline error/success banners ── */
    .cfg-err-msg   { display:flex; align-items:center; gap:8px; background:#fdecea;
                     border:1px solid #ef9a9a; color:#c62828; border-radius:4px;
                     padding:8px 12px; margin-bottom:10px; font-size:12px; }
    .cfg-err-msg strong { font-weight:700; }

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
<legend><%= msg.getString("config.fieldset_title") %></legend>

<!-- Tab nav -->
<div class="cfg-tabs">
    <button class="cfg-tab-btn<%="site".equals(activeTab)?" active":""%>"     onclick="switchTab('site')"><%= msg.getString("config.tab_site_info") %></button>
    <button class="cfg-tab-btn<%="crop".equals(activeTab)?" active":""%>"     onclick="switchTab('crop')"><%= msg.getString("config.tab_crops") %></button>
    <button class="cfg-tab-btn<%="task".equals(activeTab)?" active":""%>"     onclick="switchTab('task')"><%= msg.getString("config.tab_farming_task") %></button>
    <button class="cfg-tab-btn<%="category".equals(activeTab)?" active":""%>" onclick="switchTab('category')"><%= msg.getString("config.tab_category") %></button>
    <button class="cfg-tab-btn<%="product".equals(activeTab)?" active":""%>"  onclick="switchTab('product')"><%= msg.getString("config.tab_product") %></button>
    <button class="cfg-tab-btn<%="brand".equals(activeTab)?" active":""%>"    onclick="switchTab('brand')"><%= msg.getString("config.tab_brand") %></button>
    <button class="cfg-tab-btn<%="unit".equals(activeTab)?" active":""%>"     onclick="switchTab('unit')"><%= msg.getString("config.tab_units") %></button>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 1 : Site Information
     ══════════════════════════════════════════════════ -->
<div id="tab-site" class="cfg-tab-panel<%="site".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=siList.size()%> <%= msg.getString("config.count.sites") %></span>
    <form method="post" id="si_frm" action="../../ConfigSiteInformationController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.site.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:200px;">
                    <label for="si_siteName"><%= msg.getString("site.label_site_name") %></label>
                    <input type="text" name="siteName" id="si_siteName" required placeholder="Farm / Plot name">
                </div>
                <div class="cfg-field" style="min-width:120px;">
                    <label for="si_siteArea"><%= msg.getString("site.label_site_area") %></label>
                    <input type="text" name="siteArea" id="si_siteArea" required placeholder="e.g. 2.5">
                </div>
                <div class="cfg-field" style="min-width:200px;">
                    <label for="si_siteLocation"><%= msg.getString("site.label_site_location") %></label>
                    <input type="text" name="siteLocation" id="si_siteLocation" required placeholder="Village / District">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="si_bulkBar">
        <span><strong id="si_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('si','../../ConfigSiteInformationController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('si')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="si_frmBulk" action="../../ConfigSiteInformationController"></form>
    <table class="cfg-table tbl-data" id="si_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="si_chkAll" onclick="cfgToggleAll('si',this)"></th>
            <th width="5%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_site_name") %></th>
            <th width="12%"><%= msg.getString("tbl.col_area_acres") %></th>
            <th><%= msg.getString("tbl.col_location") %></th>
            <th width="14%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (ConfigSiteInformationEntity s : siList) {
               int sid  = s.getSiteInfoId();
               String sn  = s.getSiteName()     != null ? s.getSiteName()     : "";
               String sa  = String.valueOf(s.getSiteArea());
               String sl  = s.getSiteLocation() != null ? s.getSiteLocation() : "";
               String snE = sn.replace("\\","\\\\").replace("\"","&quot;");
               String slE = sl.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="si_row<%=sid%>">
            <td class="center"><input type="checkbox" class="si_chk" value="<%=sid%>" onchange="cfgUpdateBulkBar('si','si_chk')"></td>
            <td><%=sid%></td>
            <td>
                <span id="si_vn_<%=sid%>"><%=sn%></span>
                <input type="text" id="si_en_<%=sid%>" class="inp-inline" value="<%=snE%>" style="display:none">
            </td>
            <td>
                <span id="si_va_<%=sid%>"><%=sa%></span>
                <input type="text" id="si_ea_<%=sid%>" class="inp-inline inp-inline-sm" value="<%=sa%>" style="display:none">
            </td>
            <td>
                <span id="si_vl_<%=sid%>"><%=sl%></span>
                <input type="text" id="si_el_<%=sid%>" class="inp-inline" value="<%=slE%>" style="display:none">
                <form id="si_frmUpd_<%=sid%>" method="post" action="../../ConfigSiteInformationController" style="display:none">
                    <input type="hidden" name="siteInfoId"   value="<%=sid%>">
                    <input type="hidden" name="siteName"     id="si_hn_<%=sid%>">
                    <input type="hidden" name="siteArea"     id="si_ha_<%=sid%>">
                    <input type="hidden" name="siteLocation" id="si_hl_<%=sid%>">
                    <input type="hidden" name="edit"         value="1">
                </form>
            </td>
            <td class="center">
                <button id="si_btnE_<%=sid%>" type="button" class="btn-row-edit"   onclick="siInlineEdit(<%=sid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="si_btnS_<%=sid%>" type="button" class="btn-row-save"   onclick="siInlineSave(<%=sid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="si_btnC_<%=sid%>" type="button" class="btn-row-cancel" onclick="siInlineCancel(<%=sid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 2 : Crops
     ══════════════════════════════════════════════════ -->
<div id="tab-crop" class="cfg-tab-panel<%="crop".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=crList.size()%> <%= msg.getString("config.count.crops") %></span>
    <form method="post" id="cr_frm" action="../../ConfigCropController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.crop.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="cr_cropName"><%= msg.getString("crop.label_crop_name") %></label>
                    <input type="text" name="cropName" id="cr_cropName" required placeholder="e.g. Wheat, Rice, Cotton">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="cr_bulkBar">
        <span><strong id="cr_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('cr','../../ConfigCropController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('cr')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="cr_frmBulk" action="../../ConfigCropController"></form>
    <table class="cfg-table tbl-data" id="cr_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="cr_chkAll" onclick="cfgToggleAll('cr',this)"></th>
            <th width="8%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_crop_name") %></th>
            <th width="16%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (ConfigCropEntity c : crList) {
               int cid = c.getCropId();
               String cval = c.getCropName() != null ? c.getCropName() : "";
               String cesc = cval.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="cr_row<%=cid%>">
            <td class="center"><input type="checkbox" class="cr_chk" value="<%=cid%>" onchange="cfgUpdateBulkBar('cr','cr_chk')"></td>
            <td><%=cid%></td>
            <td>
                <span id="cr_vn_<%=cid%>"><%=cval%></span>
                <input type="text" id="cr_en_<%=cid%>" class="inp-inline" value="<%=cesc%>" style="display:none">
                <form id="cr_frmUpd_<%=cid%>" method="post" action="../../ConfigCropController" style="display:none">
                    <input type="hidden" name="cropId"   value="<%=cid%>">
                    <input type="hidden" name="cropName" id="cr_hn_<%=cid%>">
                    <input type="hidden" name="edit"     value="1">
                </form>
            </td>
            <td class="center">
                <button id="cr_btnE_<%=cid%>" type="button" class="btn-row-edit"   onclick="cfgInlineEdit('cr',<%=cid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="cr_btnS_<%=cid%>" type="button" class="btn-row-save"   onclick="cfgInlineSave('cr',<%=cid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="cr_btnC_<%=cid%>" type="button" class="btn-row-cancel" onclick="cfgInlineCancel('cr',<%=cid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 3 : Farming Task
     ══════════════════════════════════════════════════ -->
<div id="tab-task" class="cfg-tab-panel<%="task".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=ftList.size()%> <%= msg.getString("config.count.tasks") %></span>
    <form method="post" id="ft_frm" action="../../ConfigFarmTaskController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.task.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="ft_taskName"><%= msg.getString("config.farm_task.label_task_name") %></label>
                    <input type="text" name="taskName" id="ft_taskName" required placeholder="e.g. Ploughing, Irrigation">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="ft_bulkBar">
        <span><strong id="ft_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('ft','../../ConfigFarmTaskController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('ft')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="ft_frmBulk" action="../../ConfigFarmTaskController"></form>
    <table class="cfg-table tbl-data" id="ft_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="ft_chkAll" onclick="cfgToggleAll('ft',this)"></th>
            <th width="8%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_task_name") %></th>
            <th width="16%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (ConfigFarmTaskEntity t : ftList) {
               int tid = t.getTaskId();
               String tval = t.getTaskName() != null ? t.getTaskName() : "";
               String tesc = tval.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="ft_row<%=tid%>">
            <td class="center"><input type="checkbox" class="ft_chk" value="<%=tid%>" onchange="cfgUpdateBulkBar('ft','ft_chk')"></td>
            <td><%=tid%></td>
            <td>
                <span id="ft_vn_<%=tid%>"><%=tval%></span>
                <input type="text" id="ft_en_<%=tid%>" class="inp-inline" value="<%=tesc%>" style="display:none">
                <form id="ft_frmUpd_<%=tid%>" method="post" action="../../ConfigFarmTaskController" style="display:none">
                    <input type="hidden" name="taskId"   value="<%=tid%>">
                    <input type="hidden" name="taskName" id="ft_hn_<%=tid%>">
                    <input type="hidden" name="edit"     value="1">
                </form>
            </td>
            <td class="center">
                <button id="ft_btnE_<%=tid%>" type="button" class="btn-row-edit"   onclick="cfgInlineEdit('ft',<%=tid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="ft_btnS_<%=tid%>" type="button" class="btn-row-save"   onclick="cfgInlineSave('ft',<%=tid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="ft_btnC_<%=tid%>" type="button" class="btn-row-cancel" onclick="cfgInlineCancel('ft',<%=tid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 4 : Category
     ══════════════════════════════════════════════════ -->
<div id="tab-category" class="cfg-tab-panel<%="category".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=caList.size()%> <%= msg.getString("config.count.categories") %></span>
    <form method="post" id="ca_frm" action="../../CategoryController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.category.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="ca_categoryName"><%= msg.getString("config.category.label_category_name") %></label>
                    <input type="text" name="categoryName" id="ca_categoryName" required placeholder="e.g. Fertilizer, Pesticide">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="ca_bulkBar">
        <span><strong id="ca_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('ca','../../CategoryController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('ca')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="ca_frmBulk" action="../../CategoryController"></form>
    <table class="cfg-table tbl-data" id="ca_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="ca_chkAll" onclick="cfgToggleAll('ca',this)"></th>
            <th width="8%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_category_name") %></th>
            <th width="16%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (CategoryEntity ca : caList) {
               int caid = ca.getCategoryId();
               String caval = ca.getCategoryName() != null ? ca.getCategoryName() : "";
               String caesc = caval.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="ca_row<%=caid%>">
            <td class="center"><input type="checkbox" class="ca_chk" value="<%=caid%>" onchange="cfgUpdateBulkBar('ca','ca_chk')"></td>
            <td><%=caid%></td>
            <td>
                <span id="ca_vn_<%=caid%>"><%=caval%></span>
                <input type="text" id="ca_en_<%=caid%>" class="inp-inline" value="<%=caesc%>" style="display:none">
                <form id="ca_frmUpd_<%=caid%>" method="post" action="../../CategoryController" style="display:none">
                    <input type="hidden" name="categoryId"   value="<%=caid%>">
                    <input type="hidden" name="categoryName" id="ca_hn_<%=caid%>">
                    <input type="hidden" name="edit"         value="1">
                </form>
            </td>
            <td class="center">
                <button id="ca_btnE_<%=caid%>" type="button" class="btn-row-edit"   onclick="cfgInlineEdit('ca',<%=caid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="ca_btnS_<%=caid%>" type="button" class="btn-row-save"   onclick="cfgInlineSave('ca',<%=caid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="ca_btnC_<%=caid%>" type="button" class="btn-row-cancel" onclick="cfgInlineCancel('ca',<%=caid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 5 : Product
     ══════════════════════════════════════════════════ -->
<div id="tab-product" class="cfg-tab-panel<%="product".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=prList.size()%> <%= msg.getString("config.count.products") %></span>
    <form method="post" id="pr_frm" action="../../FertilizerController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.product.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="pr_fertilizerName"><%= msg.getString("config.fertilizer.label_product_name") %></label>
                    <input type="text" name="fertilizerName" id="pr_fertilizerName" required placeholder="e.g. Urea, DAP, Neem Oil">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="pr_bulkBar">
        <span><strong id="pr_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('pr','../../FertilizerController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('pr')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="pr_frmBulk" action="../../FertilizerController"></form>
    <table class="cfg-table tbl-data" id="pr_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="pr_chkAll" onclick="cfgToggleAll('pr',this)"></th>
            <th width="8%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_product_name") %></th>
            <th width="16%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (FertilizerEntity pr : prList) {
               int prid = pr.getFertilizerId();
               String prval = pr.getFertilizerName() != null ? pr.getFertilizerName() : "";
               String presc = prval.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="pr_row<%=prid%>">
            <td class="center"><input type="checkbox" class="pr_chk" value="<%=prid%>" onchange="cfgUpdateBulkBar('pr','pr_chk')"></td>
            <td><%=prid%></td>
            <td>
                <span id="pr_vn_<%=prid%>"><%=prval%></span>
                <input type="text" id="pr_en_<%=prid%>" class="inp-inline" value="<%=presc%>" style="display:none">
                <form id="pr_frmUpd_<%=prid%>" method="post" action="../../FertilizerController" style="display:none">
                    <input type="hidden" name="fertilizerId"   value="<%=prid%>">
                    <input type="hidden" name="fertilizerName" id="pr_hn_<%=prid%>">
                    <input type="hidden" name="edit"           value="1">
                </form>
            </td>
            <td class="center">
                <button id="pr_btnE_<%=prid%>" type="button" class="btn-row-edit"   onclick="cfgInlineEdit('pr',<%=prid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="pr_btnS_<%=prid%>" type="button" class="btn-row-save"   onclick="cfgInlineSave('pr',<%=prid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="pr_btnC_<%=prid%>" type="button" class="btn-row-cancel" onclick="cfgInlineCancel('pr',<%=prid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 6 : Brand
     ══════════════════════════════════════════════════ -->
<div id="tab-brand" class="cfg-tab-panel<%="brand".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=brList.size()%> <%= msg.getString("config.count.brands") %></span>
    <form method="post" id="br_frm" action="../../BrandController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.brand.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="br_brandName"><%= msg.getString("config.brand.label_brand_name") %></label>
                    <input type="text" name="brandName" id="br_brandName" required placeholder="e.g. Tata, Coromandel">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="br_bulkBar">
        <span><strong id="br_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('br','../../BrandController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('br')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="br_frmBulk" action="../../BrandController"></form>
    <table class="cfg-table tbl-data" id="br_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="br_chkAll" onclick="cfgToggleAll('br',this)"></th>
            <th width="8%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_brand_name") %></th>
            <th width="16%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (BrandEntity br : brList) {
               int brid = br.getBrandId();
               String brval = br.getBrandName() != null ? br.getBrandName() : "";
               String bresc = brval.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="br_row<%=brid%>">
            <td class="center"><input type="checkbox" class="br_chk" value="<%=brid%>" onchange="cfgUpdateBulkBar('br','br_chk')"></td>
            <td><%=brid%></td>
            <td>
                <span id="br_vn_<%=brid%>"><%=brval%></span>
                <input type="text" id="br_en_<%=brid%>" class="inp-inline" value="<%=bresc%>" style="display:none">
                <form id="br_frmUpd_<%=brid%>" method="post" action="../../BrandController" style="display:none">
                    <input type="hidden" name="brandId"   value="<%=brid%>">
                    <input type="hidden" name="brandName" id="br_hn_<%=brid%>">
                    <input type="hidden" name="edit"      value="1">
                </form>
            </td>
            <td class="center">
                <button id="br_btnE_<%=brid%>" type="button" class="btn-row-edit"   onclick="cfgInlineEdit('br',<%=brid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="br_btnS_<%=brid%>" type="button" class="btn-row-save"   onclick="cfgInlineSave('br',<%=brid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="br_btnC_<%=brid%>" type="button" class="btn-row-cancel" onclick="cfgInlineCancel('br',<%=brid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>
</div>

<!-- ══════════════════════════════════════════════════
     TAB 7 : Units
     ══════════════════════════════════════════════════ -->
<div id="tab-unit" class="cfg-tab-panel<%="unit".equals(activeTab)?" active":""%>">
    <span class="cfg-count-chip"><%=unList.size()%> <%= msg.getString("config.count.units") %></span>
    <form method="post" id="un_frm" action="../../UnitController">
        <div class="cfg-form-card">
            <div class="cfg-form-card-title"><%= msg.getString("config.unit.form_title_add") %></div>
            <div class="cfg-form-row">
                <div class="cfg-field" style="min-width:220px;">
                    <label for="un_unitName"><%= msg.getString("config.units.label_unit_name") %></label>
                    <input type="text" name="unitName" id="un_unitName" required placeholder="e.g. Kg, Litre, Bag">
                </div>
                <div style="align-self:flex-end;">
                    <input type="submit" class="btn-add" name="add" value="<%= msg.getString("btn.add") %>">
                </div>
            </div>
        </div>
    </form>
    <div class="cfg-bulk-bar" id="un_bulkBar">
        <span><strong id="un_selCount">0</strong> selected</span>
        <button type="button" class="btn-delete" onclick="cfgDeleteSelected('un','../../UnitController')"><%= msg.getString("btn.delete_selected") %></button>
        <button type="button" class="btn-cancel" onclick="cfgClearSelection('un')"><%= msg.getString("btn.clear") %></button>
    </div>
    <form method="post" id="un_frmBulk" action="../../UnitController"></form>
    <table class="cfg-table tbl-data" id="un_table">
        <thead><tr>
            <th width="4%" style="text-align:center;"><input type="checkbox" id="un_chkAll" onclick="cfgToggleAll('un',this)"></th>
            <th width="8%"><%= msg.getString("tbl.col_id") %></th>
            <th><%= msg.getString("tbl.col_unit_name") %></th>
            <th width="16%" style="text-align:center;"><%= msg.getString("tbl.col_action") %></th>
        </tr></thead>
        <tbody>
        <% for (UnitEntity un : unList) {
               int unid = un.getUnitId();
               String unval = un.getUnitName() != null ? un.getUnitName() : "";
               String unesc = unval.replace("\\","\\\\").replace("\"","&quot;"); %>
        <tr id="un_row<%=unid%>">
            <td class="center"><input type="checkbox" class="un_chk" value="<%=unid%>" onchange="cfgUpdateBulkBar('un','un_chk')"></td>
            <td><%=unid%></td>
            <td>
                <span id="un_vn_<%=unid%>"><%=unval%></span>
                <input type="text" id="un_en_<%=unid%>" class="inp-inline" value="<%=unesc%>" style="display:none">
                <form id="un_frmUpd_<%=unid%>" method="post" action="../../UnitController" style="display:none">
                    <input type="hidden" name="unitId"   value="<%=unid%>">
                    <input type="hidden" name="unitName" id="un_hn_<%=unid%>">
                    <input type="hidden" name="edit"     value="1">
                </form>
            </td>
            <td class="center">
                <button id="un_btnE_<%=unid%>" type="button" class="btn-row-edit"   onclick="cfgInlineEdit('un',<%=unid%>)"><%= msg.getString("btn.edit") %></button>
                <button id="un_btnS_<%=unid%>" type="button" class="btn-row-save"   onclick="cfgInlineSave('un',<%=unid%>)" style="display:none"><%= msg.getString("btn.save") %></button>
                <button id="un_btnC_<%=unid%>" type="button" class="btn-row-cancel" onclick="cfgInlineCancel('un',<%=unid%>)" style="display:none"><%= msg.getString("btn.cancel") %></button>
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
    if (dtMap[name]) dtMap[name].columns.adjust().draw(false);
    history.replaceState(null, '', '?tab=' + name);
}

/* ── DataTables init ── */
$(document).ready(function () {
    var idToTab = {si_table:'site', cr_table:'crop', ft_table:'task',
                   ca_table:'category', pr_table:'product', br_table:'brand', un_table:'unit'};
    Object.keys(idToTab).forEach(function(id) {
        var dt;
        if ($.fn.DataTable.isDataTable('#' + id)) {
            dt = $('#' + id).DataTable();
        } else {
            dt = $('#' + id).DataTable({
                pageLength: 25, autoWidth: false,
                language: {
                    search: '', searchPlaceholder: 'Search...',
                    lengthMenu: 'Show _MENU_ entries',
                    info: '_START_ - _END_ of _TOTAL_',
                    infoEmpty: '0 entries', emptyTable: 'No records found',
                    paginate: { previous: '&#8249;', next: '&#8250;' }
                }
            });
        }
        dtMap[idToTab[id]] = dt;
    });
});

/* ══════════════════════════════════════════
   INLINE ROW EDITING — single-field tabs
   p  = prefix (ut, cr, ft, ca, pr, br, un)
   id = record id
   ══════════════════════════════════════════ */
function cfgInlineEdit(p, id) {
    var span = document.getElementById(p + '_vn_' + id);
    var inp  = document.getElementById(p + '_en_' + id);
    span.style.display = 'none';
    inp.style.display  = '';
    inp.focus(); inp.select();
    document.getElementById(p + '_btnE_' + id).style.display = 'none';
    document.getElementById(p + '_btnS_' + id).style.display = '';
    document.getElementById(p + '_btnC_' + id).style.display = '';
    var row = document.getElementById(p + '_row' + id);
    if (row) row.classList.add('editing-row');
    /* save on Enter */
    inp.onkeydown = function(e) { if (e.key === 'Enter') cfgInlineSave(p, id); };
}

function cfgInlineCancel(p, id) {
    var span = document.getElementById(p + '_vn_' + id);
    var inp  = document.getElementById(p + '_en_' + id);
    inp.value          = span.innerText;   /* restore original */
    span.style.display = '';
    inp.style.display  = 'none';
    document.getElementById(p + '_btnE_' + id).style.display = '';
    document.getElementById(p + '_btnS_' + id).style.display = 'none';
    document.getElementById(p + '_btnC_' + id).style.display = 'none';
    var row = document.getElementById(p + '_row' + id);
    if (row) row.classList.remove('editing-row');
}

function cfgInlineSave(p, id) {
    var val = document.getElementById(p + '_en_' + id).value.trim();
    if (!val) { document.getElementById(p + '_en_' + id).focus(); return; }
    document.getElementById(p + '_hn_' + id).value = val;
    document.getElementById(p + '_frmUpd_' + id).submit();
}

/* ══════════════════════════════════════════
   INLINE ROW EDITING — Site Information (3 fields)
   ══════════════════════════════════════════ */
function siInlineEdit(id) {
    ['n','a','l'].forEach(function(f) {
        document.getElementById('si_v' + f + '_' + id).style.display = 'none';
        document.getElementById('si_e' + f + '_' + id).style.display = '';
    });
    document.getElementById('si_en_' + id).focus();
    document.getElementById('si_btnE_' + id).style.display = 'none';
    document.getElementById('si_btnS_' + id).style.display = '';
    document.getElementById('si_btnC_' + id).style.display = '';
    var row = document.getElementById('si_row' + id);
    if (row) row.classList.add('editing-row');
}

function siInlineCancel(id) {
    ['n','a','l'].forEach(function(f) {
        var span = document.getElementById('si_v' + f + '_' + id);
        var inp  = document.getElementById('si_e' + f + '_' + id);
        inp.value         = span.innerText;
        span.style.display = '';
        inp.style.display  = 'none';
    });
    document.getElementById('si_btnE_' + id).style.display = '';
    document.getElementById('si_btnS_' + id).style.display = 'none';
    document.getElementById('si_btnC_' + id).style.display = 'none';
    var row = document.getElementById('si_row' + id);
    if (row) row.classList.remove('editing-row');
}

function siInlineSave(id) {
    document.getElementById('si_hn_' + id).value = document.getElementById('si_en_' + id).value.trim();
    document.getElementById('si_ha_' + id).value = document.getElementById('si_ea_' + id).value.trim();
    document.getElementById('si_hl_' + id).value = document.getElementById('si_el_' + id).value.trim();
    document.getElementById('si_frmUpd_' + id).submit();
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
</script>
</body>
</html>
