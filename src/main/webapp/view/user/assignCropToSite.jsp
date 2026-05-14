<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteRefEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignCropToSiteRefService"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="com.san.farm.adminuser.dao.AssignCropToSiteService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.dao.ConfigCropService"%>
<%@page import="com.san.farm.adminuser.entity.ConfigSiteInformationEntity"%>
<%@page import="java.util.List"%>
<%@page import="com.san.farm.adminuser.dao.ConfigSiteInformationService"%>
<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    ConfigSiteInformationService informationService = new ConfigSiteInformationService();
    List<ConfigSiteInformationEntity> listOfSite = informationService.fetch();
    ConfigCropService cropService = new ConfigCropService();
    List<ConfigCropEntity> listOfCrop = cropService.fetch();
    AssignCropToSiteService cropToSiteService = new AssignCropToSiteService();
    List<AssignCropToSiteEntity> cropToSiteEntities = cropToSiteService.getListOFAssignCropToSite();
    int totalRecords = cropToSiteEntities.size();
%>
<!DOCTYPE html>
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<meta name="viewport" content="width=device-width, initial-scale=1">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title>Site Resource Allocation</title>
<style>
    .page-header  { display:flex; align-items:center; gap:10px; margin-bottom:12px; }
    .page-title   { font-size:1.1em; font-weight:700; color:var(--green-dk); margin:0; }
    .count-chip   { background:var(--green-md); color:#fff; font-size:11px; font-weight:700;
                    padding:2px 9px; border-radius:12px; }

    .form-grid    { display:flex; gap:16px; flex-wrap:wrap; align-items:flex-end; }
    .fg-field     { display:flex; flex-direction:column; gap:3px; }
    .fg-field label { font-size:12px; font-weight:600; color:var(--green-dk); }
    .fg-field select,
    .fg-field input[type=text] {
        font-size:13px; padding:4px 7px; border:1px solid var(--gray-400);
        border-radius:var(--r-sm); background:#fff; }
    .fg-field select:focus,
    .fg-field input[type=text]:focus { border-color:var(--blue-md); outline:none; }

    /* ── Checkbox dropdown ── */
    .chk-drop        { position:relative; display:inline-block; }
    .chk-drop-btn    { background:#fff; border:1px solid var(--gray-400); border-radius:var(--r-sm);
                       padding:4px 26px 4px 8px; font-size:13px; cursor:pointer; text-align:left;
                       min-width:170px; max-width:200px; position:relative; white-space:nowrap;
                       overflow:hidden; text-overflow:ellipsis; font-family:inherit; color:#333; }
    .chk-drop-btn::after { content:'\25BE'; position:absolute; right:8px; top:50%;
                            transform:translateY(-50%); color:#888; pointer-events:none; }
    .chk-drop-btn.has-val { border-color:var(--green-bd); background:var(--green-lt);
                             color:var(--green-dk); font-weight:600; }
    .chk-drop-panel  { position:absolute; top:calc(100% + 2px); left:0; z-index:1000; background:#fff;
                       border:1px solid var(--gray-400); border-radius:var(--r-sm);
                       box-shadow:0 4px 12px rgba(0,0,0,.15); min-width:190px; max-height:210px;
                       overflow-y:auto; padding:4px 0; }
    .chk-drop-item   { display:flex; align-items:center; gap:7px; padding:5px 12px;
                       font-size:12px; cursor:pointer; user-select:none; }
    .chk-drop-item:hover { background:var(--green-lt); }
    .chk-drop-item input { margin:0; cursor:pointer; accent-color:var(--green-md); }

    /* smaller dropdown variant used inside table rows during edit */
    .chk-drop-btn.sm { min-width:130px; max-width:150px; font-size:11px; padding:2px 22px 2px 6px; }
    .chk-drop-panel.sm .chk-drop-item { padding:4px 10px; font-size:11px; }

    .bulk-bar     { display:none; background:#fdecea; border:1px solid #e06060;
                    padding:6px 14px; border-radius:var(--r-sm); margin-bottom:8px;
                    align-items:center; gap:10px; }

    .edit-sel     { width:120px; font-size:11px; }
    .edit-date-inp{ width:88px;  font-size:11px; padding:2px; }

    .btn-row-save  { background:#28a745; color:#fff; border:none; padding:3px 9px;
                     cursor:pointer; border-radius:var(--r-sm); font-size:11px; }
    .btn-row-cancel{ background:#6c757d; color:#fff; border:none; padding:3px 9px;
                     cursor:pointer; border-radius:var(--r-sm); font-size:11px; }

    /* icon nav buttons — always visible */
    .btn-icon-nav  { width:26px; height:26px; border-radius:var(--r-sm); cursor:pointer;
                     font-size:13px; display:inline-flex; align-items:center;
                     justify-content:center; vertical-align:middle; line-height:1; }
    .btn-fert      { background:#e3f2fd; border:1px solid #90caf9; }
    .btn-fert:hover{ background:#bbdefb; }
    .btn-emp       { background:#e8f5e9; border:1px solid var(--green-bd); }
    .btn-emp:hover { background:var(--green-row); }
    .actions-cell  { text-align:center; white-space:nowrap; }
    .actions-cell > * { vertical-align:middle; }
</style>
</head>
<body>

<%@include file="../../header.jsp" %>
<script src="../../js/jquery-ui.js"></script>

<script>
$(function() {
    $("#cropAssignDate").datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });

    /* close all dropdowns when clicking outside */
    $(document).on('click', function(e) {
        if (!$(e.target).closest('.chk-drop').length) {
            $('.chk-drop-panel').hide();
        }
    });

    /* add-form submit validation */
    $('#addCropForm').on('submit', function(e) {
        if ($('#addCropPanel input:checked').length === 0) {
            e.preventDefault();
            alert('Please select at least one crop.');
            $('#addCropPanel').show();
        }
    });
});

/* ── Checkbox dropdown helpers ── */
function toggleDrop(panelId, btnId, event) {
    if (event) event.stopPropagation();
    var $panel = $('#' + panelId);
    /* close others */
    $('.chk-drop-panel').not($panel).hide();
    $panel.toggle();
}

function updateDropBtn(panelId, btnId) {
    var $panel  = $('#' + panelId);
    var $btn    = $('#' + btnId);
    var $checked = $panel.find('input[type=checkbox]:checked');
    if ($checked.length === 0) {
        $btn.text('Select crops...').removeClass('has-val');
    } else if ($checked.length === 1) {
        $btn.text($checked.first().closest('.chk-drop-item').text().trim()).addClass('has-val');
    } else {
        $btn.text($checked.length + ' crops selected').addClass('has-val');
    }
    /* restore the ::after arrow removed by .text() — keep via class, not textContent change */
}

/* ── Inline edit ── */
function editRow(id) {
    $('#spanSite' + id).hide(); $('#inpSite'  + id).show();
    $('#spanCrop' + id).hide(); $('#cropDrop' + id).show();
    $('#spanDate' + id).hide(); $('#inpDate'  + id).show();
    $('#inpDate' + id).datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
    $('#btnEdit' + id).hide();
    $('#btnSave' + id).show();
    $('#btnCancel' + id).show();
}

function cancelEdit(id) {
    $('#spanSite' + id).show(); $('#inpSite'  + id).hide();
    $('#spanCrop' + id).show();
    $('#cropDrop' + id).hide(); $('#cropDropPanel' + id).hide();
    $('#spanDate' + id).show(); $('#inpDate'  + id).hide();
    $('#btnEdit' + id).show();
    $('#btnSave' + id).hide();
    $('#btnCancel' + id).hide();
}

function saveRow(id) {
    var dateVal = $('#inpDate' + id).val();
    if (!dateVal) { alert('Please enter a date.'); return; }
    var $checked = $('#cropDropPanel' + id + ' input[type=checkbox]:checked');
    if ($checked.length === 0) { alert('Please select at least one crop.'); return; }
    var $frm = $('#frmEdit' + id);
    $('#hidSite' + id).val($('#inpSite' + id).val());
    $('#hidDate' + id).val(dateVal);
    $frm.find('input.dyn-crop').remove();
    $checked.each(function() {
        $frm.append($('<input>').attr({ type:'hidden', name:'cropId', 'class':'dyn-crop', value:this.value }));
    });
    $frm[0].submit();
}

/* ── Bulk delete ── */
function toggleSelectAll(chk) {
    $('input.rowChk').prop('checked', chk.checked);
    updateBulkBar();
}

function updateBulkBar() {
    var checked = $('input.rowChk:checked').length;
    var all     = $('input.rowChk').length;
    $('#bulkBar').css('display', checked > 0 ? 'flex' : 'none');
    $('#selCount').text(checked);
    $('#chkAll').prop('checked', checked === all && all > 0);
}

function deleteSelected() {
    var $checked = $('input.rowChk:checked');
    if (!$checked.length) return;
    if (!(window.top || window).confirm('Delete ' + $checked.length + ' selected record(s)?')) return;
    var $form = $('#frmBulkDelete').empty();
    $checked.each(function() {
        $form.append($('<input>').attr({ type:'hidden', name:'deleteIds', value:this.value }));
    });
    $form.append($('<input>').attr({ type:'hidden', name:'deleteSelected', value:'1' }));
    $form[0].submit();
}

function clearSelection() {
    $('input.rowChk, #chkAll').prop('checked', false);
    $('#bulkBar').hide();
}
</script>

<fieldset>
<legend>Site Resource Allocation</legend>

    <div class="page-header">
        <span class="page-title">Allocations</span>
        <span class="count-chip"><%=totalRecords%></span>
    </div>

    <!-- Add form -->
    <div class="form-panel">
        <form id="addCropForm" action="../../AssignCropToSiteController" method="post">
            <div class="form-grid">
                <div class="fg-field">
                    <label for="siteInfoId">Site</label>
                    <select name="siteInfoId" id="siteInfoId" required>
                        <option value="">-- Select Site --</option>
                        <% for(ConfigSiteInformationEntity s : listOfSite) { %>
                        <option value="<%=s.getSiteInfoId()%>"><%=s.getSiteName()%></option>
                        <% } %>
                    </select>
                </div>

                <div class="fg-field">
                    <label>Crop</label>
                    <div class="chk-drop">
                        <button type="button" class="chk-drop-btn" id="addCropBtn"
                            onclick="toggleDrop('addCropPanel','addCropBtn',event)">Select crops...</button>
                        <div class="chk-drop-panel" id="addCropPanel" style="display:none;">
                            <% for(ConfigCropEntity c : listOfCrop) { %>
                            <label class="chk-drop-item">
                                <input type="checkbox" name="cropId" value="<%=c.getCropId()%>"
                                    onchange="updateDropBtn('addCropPanel','addCropBtn')">
                                <%=c.getCropName()%>
                            </label>
                            <% } %>
                        </div>
                    </div>
                </div>

                <div class="fg-field">
                    <label for="cropAssignDate">Date</label>
                    <input type="text" name="cropAssignDate" id="cropAssignDate"
                        pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
                        oninvalid="setCustomValidity('Enter Date: Select From Calendar')"
                        onchange="setCustomValidity('')"
                        placeholder="dd/mm/yyyy" required>
                </div>

                <div class="fg-field">
                    <label>&nbsp;</label>
                    <input type="submit" name="add" value="Add" class="btn-add">
                </div>
            </div>
        </form>
    </div>

    <!-- Bulk delete form -->
    <form id="frmBulkDelete" method="post" action="../../AssignCropToSiteController"></form>

    <!-- Bulk action bar -->
    <div id="bulkBar" class="bulk-bar">
        <span><strong id="selCount">0</strong> record(s) selected</span>
        <button type="button" class="btn-delete" onclick="deleteSelected()">Delete Selected</button>
        <button type="button" class="btn-row-cancel" onclick="clearSelection()">Clear</button>
    </div>

    <table id="assignCropTable" class="tbl-data" cellspacing="0">
        <thead>
        <tr>
            <th width="3%"><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)"></th>
            <th>Site</th>
            <th>Crop</th>
            <th>Date</th>
            <th width="14%">Actions</th>
        </tr>
        </thead>
        <tbody>
        <%
            for(AssignCropToSiteEntity cropToSiteEntity : cropToSiteEntities) {
                if(cropToSiteEntity == null) continue;
                int rowId = cropToSiteEntity.getAssignCroptoSiteId();
                List<AssignCropToSiteRefEntity> refs = cropToSiteEntity.getCropToSiteRefEntity();
                String cropIdStr = null, cropNameStr = null;
                for(AssignCropToSiteRefEntity ref : refs) {
                    int cid = ref.getConfigCropEntity().getCropId();
                    String cname = ref.getConfigCropEntity().getCropName();
                    cropIdStr   = (cropIdStr   == null) ? String.valueOf(cid)   : cropIdStr   + "," + cid;
                    cropNameStr = (cropNameStr == null) ? cname                 : cropNameStr + ", " + cname;
                }
                String assignDate      = FarmUtility.convertfrom_yymmddToddmmyy(cropToSiteEntity.getCropAssignDate().toString());
                String currentSiteId   = String.valueOf(cropToSiteEntity.getSiteInformationEntity().getSiteInfoId());
                String currentSiteName = cropToSiteEntity.getSiteInformationEntity() != null
                                       ? cropToSiteEntity.getSiteInformationEntity().getSiteName() : "";
                final String finalCropIdStr = cropIdStr != null ? cropIdStr : "";
                String displayCropName = cropNameStr != null ? cropNameStr : "";
                /* button label: N crops or the single name */
                int cropCount = refs.size();
                String dropBtnLabel = cropCount == 0 ? "Select crops..."
                                    : cropCount == 1 ? displayCropName
                                    : cropCount + " crops selected";
        %>
        <tr id="row-<%=rowId%>">

            <td style="text-align:center;">
                <input type="checkbox" class="rowChk" value="<%=rowId%>" onchange="updateBulkBar()">
            </td>

            <!-- Site -->
            <td>
                <span id="spanSite<%=rowId%>"><%=currentSiteName%></span>
                <select class="edit-sel" id="inpSite<%=rowId%>" style="display:none;">
                    <% for(ConfigSiteInformationEntity s : listOfSite) {
                        String sel = String.valueOf(s.getSiteInfoId()).equals(currentSiteId) ? "selected" : "";
                    %>
                    <option value="<%=s.getSiteInfoId()%>" <%=sel%>><%=s.getSiteName()%></option>
                    <% } %>
                </select>
            </td>

            <!-- Crop -->
            <td>
                <span id="spanCrop<%=rowId%>"><%=displayCropName%></span>
                <div class="chk-drop" id="cropDrop<%=rowId%>" style="display:none;">
                    <button type="button" class="chk-drop-btn sm <%=cropCount > 0 ? "has-val" : ""%>"
                        id="cropDropBtn<%=rowId%>"
                        onclick="toggleDrop('cropDropPanel<%=rowId%>','cropDropBtn<%=rowId%>',event)"><%=dropBtnLabel%></button>
                    <div class="chk-drop-panel sm" id="cropDropPanel<%=rowId%>" style="display:none;">
                        <% for(ConfigCropEntity c : listOfCrop) {
                            String chk = ("," + finalCropIdStr + ",").contains("," + c.getCropId() + ",") ? "checked" : "";
                        %>
                        <label class="chk-drop-item">
                            <input type="checkbox" value="<%=c.getCropId()%>" <%=chk%>
                                onchange="updateDropBtn('cropDropPanel<%=rowId%>','cropDropBtn<%=rowId%>')">
                            <%=c.getCropName()%>
                        </label>
                        <% } %>
                    </div>
                </div>
            </td>

            <!-- Date -->
            <td>
                <span id="spanDate<%=rowId%>"><%=assignDate%></span>
                <input type="text" class="edit-date-inp" id="inpDate<%=rowId%>"
                    value="<%=assignDate%>" style="display:none;" placeholder="dd/mm/yyyy">
            </td>

            <!-- Actions: single row -->
            <td class="actions-cell">
                <button type="button" class="btn-row-edit" id="btnEdit<%=rowId%>"
                    onclick="editRow(<%=rowId%>)">Edit</button>

                <form method="post" action="../../AssignCropToSiteController"
                    id="frmEdit<%=rowId%>" style="display:inline;">
                    <input type="hidden" name="edit"           value="edit">
                    <input type="hidden" name="cropToSiteId"   value="<%=rowId%>">
                    <input type="hidden" name="siteInfoId"     id="hidSite<%=rowId%>">
                    <input type="hidden" name="cropAssignDate" id="hidDate<%=rowId%>">
                    <button type="button" class="btn-row-save" id="btnSave<%=rowId%>"
                        style="display:none;" onclick="saveRow(<%=rowId%>)">Save</button>
                </form>

                <button type="button" class="btn-row-cancel" id="btnCancel<%=rowId%>"
                    style="display:none;" onclick="cancelEdit(<%=rowId%>)">Cancel</button>

                &nbsp;
                <button type="button" class="btn-icon-nav btn-fert"
                    title="Allocate Fertilizers"
                    onclick="window.location.href='allocateFertilizersToSite.jsp?cropToSiteId=<%=rowId%>'">&#127807;</button>
                <button type="button" class="btn-icon-nav btn-emp"
                    title="Allocate Employees"
                    onclick="window.location.href='allocateEmployeeToSite.jsp?cropToSiteId=<%=rowId%>'">&#128100;</button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
