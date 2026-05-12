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
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    ConfigSiteInformationService informationService = new ConfigSiteInformationService();
    List<ConfigSiteInformationEntity> listOfSite = informationService.fetch();
    ConfigCropService cropService = new ConfigCropService();
    List<ConfigCropEntity> listOfCrop = cropService.fetch();
    AssignCropToSiteService cropToSiteService = new AssignCropToSiteService();
    List<AssignCropToSiteEntity> cropToSiteEntities = cropToSiteService.getListOFAssignCropToSite();
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title>Site Resource Allocation</title>
<style>
    .edit-sel       { width:120px; font-size:11px; }
    .edit-sel-multi { width:130px; font-size:11px; }
    .edit-date-inp  { width:88px;  font-size:11px; padding:2px; }
    .btn-row-edit   { background:#e8f5e9; border:1px solid var(--green-dk); color:var(--green-dk);
                      padding:2px 8px; cursor:pointer; border-radius:2px; font-size:11px; font-weight:600; }
    .btn-row-edit:hover { background:#c8e6c9; }
    .btn-row-save   { background:#28a745; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; }
    .btn-row-cancel { background:#6c757d; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; }
    .btn-alloc-site { background:#1565c0; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; font-weight:600; margin-left:4px; }
    .btn-alloc-site:hover { background:#0d47a1; }
    .btn-emp-site   { background:#00695c; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; font-weight:600; margin-left:4px; }
    .btn-emp-site:hover { background:#004d40; }
    #bulkBar { display:none; background:#fdecea; border:1px solid #e06060;
               padding:6px 14px; border-radius:3px; margin-bottom:8px; }
</style>
</head>
<body>

<%@include file="../../header.jsp" %>

<!-- jquery-ui loaded AFTER header.jsp so it attaches to header's jQuery instance -->
<script src="../../js/jquery-ui.js"></script>

<script>
$(function() {
    $("#cropAssignDate").datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
});

/* ── inline edit ── */
function editRow(id) {
    ['Site','Crop','Date'].forEach(function(f) {
        var sp  = document.getElementById('span' + f + id);
        var inp = document.getElementById('inp'  + f + id);
        if (sp)  sp.style.display  = 'none';
        if (inp) inp.style.display = '';
    });
    $("#inpDate" + id).datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
    document.getElementById('btnEdit'   + id).style.display = 'none';
    document.getElementById('btnSave'   + id).style.display = '';
    document.getElementById('btnCancel' + id).style.display = '';
}

function cancelEdit(id) {
    ['Site','Crop','Date'].forEach(function(f) {
        var sp  = document.getElementById('span' + f + id);
        var inp = document.getElementById('inp'  + f + id);
        if (sp)  sp.style.display  = '';
        if (inp) inp.style.display = 'none';
    });
    document.getElementById('btnEdit'   + id).style.display = '';
    document.getElementById('btnSave'   + id).style.display = 'none';
    document.getElementById('btnCancel' + id).style.display = 'none';
}

function saveRow(id) {
    var dateVal = document.getElementById('inpDate' + id).value;
    if (!dateVal) { alert('Please enter a date.'); return; }
    var sel = document.getElementById('inpCrop' + id);
    var selected = [];
    for (var i = 0; i < sel.options.length; i++) {
        if (sel.options[i].selected) selected.push(sel.options[i].value);
    }
    if (selected.length === 0) { alert('Please select at least one crop.'); return; }
    var frm = document.getElementById('frmEdit' + id);
    document.getElementById('hidSite' + id).value = document.getElementById('inpSite' + id).value;
    document.getElementById('hidDate' + id).value = dateVal;
    frm.querySelectorAll('input.dyn-crop').forEach(function(el) { el.parentNode.removeChild(el); });
    selected.forEach(function(v) {
        var inp = document.createElement('input');
        inp.type = 'hidden'; inp.name = 'cropId'; inp.className = 'dyn-crop'; inp.value = v;
        frm.appendChild(inp);
    });
    frm.submit();
}

/* ── bulk delete ── */
function toggleSelectAll(chk) {
    document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = chk.checked; });
    updateBulkBar();
}

function updateBulkBar() {
    var checked = document.querySelectorAll('input.rowChk:checked');
    var all     = document.querySelectorAll('input.rowChk');
    document.getElementById('bulkBar').style.display  = checked.length > 0 ? 'block' : 'none';
    document.getElementById('selCount').innerText     = checked.length;
    document.getElementById('chkAll').checked         = (checked.length === all.length && all.length > 0);
}

function deleteSelected() {
    var checked = document.querySelectorAll('input.rowChk:checked');
    if (checked.length === 0) return;
    if (!(window.top || window).confirm('Delete ' + checked.length + ' selected record(s)?')) return;
    var form = document.getElementById('frmBulkDelete');
    form.innerHTML = '';
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

function clearSelection() {
    document.querySelectorAll('input.rowChk').forEach(function(b) { b.checked = false; });
    document.getElementById('chkAll').checked = false;
    document.getElementById('bulkBar').style.display = 'none';
}
</script>

<fieldset>
<legend>Site Resource Allocation</legend>

    <!-- Add form -->
    <form action="../../AssignCropToSiteController" method="post">
        <table border="0">
            <tr>
                <td>Site:</td>
                <td>
                    <select name="siteInfoId" id="siteInfoId" required>
                    <% for(ConfigSiteInformationEntity s : listOfSite) { %>
                        <option value="<%=s.getSiteInfoId()%>"><%=s.getSiteName()%></option>
                    <% } %>
                    </select>
                </td>
            </tr>
            <tr>
                <td style="text-align:right;">Crop:</td>
                <td>
                    <select name="cropId" id="cropId" multiple="multiple" required>
                    <% for(ConfigCropEntity c : listOfCrop) { %>
                        <option value="<%=c.getCropId()%>"><%=c.getCropName()%></option>
                    <% } %>
                    </select>
                </td>
            </tr>
            <tr>
                <td style="text-align:right;">Date:</td>
                <td>
                    <input type="text" name="cropAssignDate" id="cropAssignDate"
                        pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
                        oninvalid="setCustomValidity('Enter Date: Select From Calender')"
                        onchange="setCustomValidity('')" title="Enter Date"
                        placeholder="dd/mm/yyyy" required="required">
                </td>
            </tr>
            <tr>
                <td colspan="2" style="text-align:center;">
                    <input type="submit" name="add" value="Add">
                </td>
            </tr>
        </table>
    </form>

    <!-- Bulk delete form — outside the table -->
    <form id="frmBulkDelete" method="post" action="../../AssignCropToSiteController"></form>

    <!-- Bulk action bar -->
    <div id="bulkBar">
        <span id="selCount">0</span> record(s) selected &nbsp;
        <button type="button" class="btn-delete" onclick="deleteSelected()">Delete Selected</button>
        &nbsp;
        <button type="button" class="btn-row-cancel" onclick="clearSelection()">Clear Selection</button>
    </div>

    <hr>

    <table id="assignCropTable" border="1" width="100%" class="tbl-data" cellspacing="0">
        <thead>
        <tr>
            <th width="3%"><input type="checkbox" id="chkAll" onclick="toggleSelectAll(this)"></th>
            <th>Date</th>
            <th>Site</th>
            <th>Crop</th>
            <th>Actions</th>
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
                    cropIdStr   = (cropIdStr   == null) ? String.valueOf(cid) : cropIdStr   + "," + cid;
                    cropNameStr = (cropNameStr == null) ? cname               : cropNameStr + ", " + cname;
                }
                String assignDate      = FarmUtility.convertfrom_yymmddToddmmyy(cropToSiteEntity.getCropAssignDate().toString());
                String currentSiteId   = String.valueOf(cropToSiteEntity.getSiteInformationEntity().getSiteInfoId());
                String currentSiteName = cropToSiteEntity.getSiteInformationEntity() != null
                                       ? cropToSiteEntity.getSiteInformationEntity().getSiteName() : "";
                final String finalCropIdStr = cropIdStr != null ? cropIdStr : "";
        %>
        <tr id="row-<%=rowId%>">

            <!-- Checkbox -->
            <td style="text-align:center;">
                <input type="checkbox" class="rowChk" value="<%=rowId%>" onchange="updateBulkBar()">
            </td>

            <!-- Date -->
            <td>
                <span id="spanDate<%=rowId%>"><%=assignDate%></span>
                <input type="text" class="edit-date-inp" id="inpDate<%=rowId%>"
                    value="<%=assignDate%>" style="display:none;" placeholder="dd/mm/yyyy">
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
                <span id="spanCrop<%=rowId%>"><%=cropNameStr != null ? cropNameStr : ""%></span>
                <select class="edit-sel-multi" id="inpCrop<%=rowId%>" multiple="multiple" style="display:none;">
                    <% for(ConfigCropEntity c : listOfCrop) {
                        String sel = ("," + finalCropIdStr + ",").contains("," + c.getCropId() + ",") ? "selected" : "";
                    %>
                    <option value="<%=c.getCropId()%>" <%=sel%>><%=c.getCropName()%></option>
                    <% } %>
                </select>
            </td>

            <!-- Actions -->
            <td style="text-align:center; white-space:nowrap;">
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

                <button type="button" class="btn-alloc-site" id="btnAlloc<%=rowId%>"
                    onclick="window.location.href='allocateFertilizersToSite.jsp?cropToSiteId=<%=rowId%>'">
                    Allocate Fertilizers
                </button>
                <button type="button" class="btn-emp-site" id="btnEmpAlloc<%=rowId%>"
                    onclick="window.location.href='allocateEmployeeToSite.jsp?cropToSiteId=<%=rowId%>'">
                    Allocate Employee
                </button>
            </td>
        </tr>
        <% } %>
        </tbody>
    </table>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
