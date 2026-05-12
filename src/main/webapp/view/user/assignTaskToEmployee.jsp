<%@page import="com.san.farm.adminuser.entity.AssignEmployeeToFarmEntity"%>
<%@page import="com.san.farm.adminuser.entity.EmployeeInfoEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigCropEntity"%>
<%@page import="com.san.farm.adminuser.entity.ConfigFarmTaskEntity"%>
<%@page import="com.san.farm.adminuser.entity.AssignCropToSiteEntity"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/jquery-ui.css">
<link rel="stylesheet" href="<%=request.getContextPath()%>/css/style.css">
<title>Edit Assignment</title>
<style>
    /* ── page layout ── */
    .edit-wrap       { max-width:860px; margin:0 auto; padding:10px 0 30px; }
    .page-header     { display:flex; align-items:center; gap:14px; margin-bottom:18px; flex-wrap:wrap; }
    .page-title      { font-size:1.15em; font-weight:700; color:var(--green-dk); margin:0; }
    .back-link       { font-size:12px; color:var(--green-dk); text-decoration:none; }
    .back-link:hover { text-decoration:underline; }

    /* ── info chips shown at top ── */
    .info-bar        { display:flex; gap:10px; flex-wrap:wrap; margin-bottom:18px; }
    .info-chip       { background:#f1f8e9; border:1px solid var(--green-bd); border-radius:20px;
                       padding:4px 14px; font-size:12px; display:inline-flex; gap:5px; align-items:center; }
    .chip-lbl        { color:var(--text-muted); }
    .chip-val        { font-weight:700; color:var(--green-dk); }

    /* ── form card sections ── */
    .form-card       { background:#fff; border:1px solid var(--gray-200,#e0e0e0);
                       border-radius:var(--r-md,6px); padding:18px 22px; margin-bottom:14px;
                       box-shadow:0 1px 3px rgba(0,0,0,.04); }
    .card-title      { font-size:0.78em; font-weight:700; text-transform:uppercase;
                       letter-spacing:.6px; color:var(--green-dk); border-bottom:2px solid var(--green-bd,#a5d6a7);
                       padding-bottom:6px; margin:0 0 16px; }

    /* ── field grid ── */
    .form-grid       { display:grid; grid-template-columns:repeat(auto-fit, minmax(210px,1fr)); gap:14px 20px; }
    .form-grid.col2  { grid-template-columns:repeat(2,1fr); }
    .form-grid.col3  { grid-template-columns:repeat(3,1fr); }
    .field           { display:flex; flex-direction:column; gap:5px; }
    .field.span2     { grid-column:span 2; }
    .field label     { font-size:11px; font-weight:700; text-transform:uppercase;
                       letter-spacing:.4px; color:var(--text-muted,#666); }
    .req             { color:#c62828; margin-left:2px; }
    .field input[type="text"],
    .field input[type="number"],
    .field select,
    .field textarea  { border:1px solid #ccc; border-radius:var(--r-sm,3px); padding:8px 10px;
                       font-size:13px; width:100%; box-sizing:border-box; transition:border-color .15s; }
    .field input:focus,
    .field select:focus,
    .field textarea:focus { outline:none; border-color:var(--green-dk); box-shadow:0 0 0 3px rgba(56,142,60,.1); }
    .field .hint     { font-size:10px; color:var(--text-muted,#888); margin-top:1px; }
    select[multiple] { padding:4px 6px; line-height:1.6; }

    /* ── status badge inside select label area ── */
    .status-pill     { display:inline-block; padding:2px 10px; border-radius:12px; font-size:11px; font-weight:700; }
    .pill-Pending    { background:#fff3e0; color:#e65100; }
    .pill-Completed  { background:#e8f5e9; color:#2e7d32; }
    .pill-Reject     { background:#fdecea; color:#c62828; }

    /* ── action bar ── */
    .action-bar      { display:flex; gap:10px; justify-content:flex-end; margin-top:6px; }
    .btn-save        { background:var(--green-dk); color:#fff; border:none; padding:10px 32px;
                       border-radius:var(--r-sm,3px); font-size:14px; font-weight:700; cursor:pointer; }
    .btn-save:hover  { background:#2e7d32; }
    .btn-cancel      { background:#fff; color:var(--green-dk); border:1px solid var(--green-dk);
                       padding:10px 22px; border-radius:var(--r-sm,3px); font-size:14px;
                       font-weight:600; cursor:pointer; text-decoration:none; display:inline-block; }
    .btn-cancel:hover{ background:#f1f8e9; }

    /* ── error state ── */
    .field-error input,
    .field-error select { border-color:#c62828 !important; }
    .err-msg { font-size:11px; color:#c62828; display:none; margin-top:2px; }
</style>
</head>
<body>
<%@include file="../../header.jsp"%>
<script src="<%=request.getContextPath()%>/js/jquery-ui.js"></script>
<script>
$(function() {
    $("#txtDate").datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
});

function validate() {
    var ok = true;

    function mark(id, msg) {
        var wrap = document.getElementById(id).closest ? document.getElementById(id).parentElement : null;
        document.getElementById(id).style.borderColor = '#c62828';
        var e = document.getElementById('err_' + id);
        if (e) { e.style.display = 'block'; e.innerText = msg; }
        ok = false;
    }
    function clear(id) {
        document.getElementById(id).style.borderColor = '';
        var e = document.getElementById('err_' + id);
        if (e) e.style.display = 'none';
    }

    var emp    = document.getElementById('selEmpId').value;
    var work   = document.getElementById('selWorkType').value;
    var status = document.getElementById('selWorkStatus').value;

    clear('selEmpId'); clear('selWorkType'); clear('selWorkStatus');

    if (!emp || emp === '-1')      { mark('selEmpId',      'Please select an employee.'); }
    if (!work || work === '-1')    { mark('selWorkType',   'Please select a work type.'); }
    if (!status || status === '-1'){ mark('selWorkStatus', 'Please select a work status.'); }

    if (!ok) { document.querySelector('.btn-save').classList.add('shake'); }
    return ok;
}
</script>

<fieldset>
<legend>Edit Assignment</legend>
<%
AssignEmployeeToFarmEntity assignment = (AssignEmployeeToFarmEntity) request.getAttribute("assignment");
if (assignment == null) {
%>
    <p style="color:var(--text-muted); padding:20px;">No record found. Please select an assignment to edit.</p>
<%
} else {
    String formattedDate = (String) request.getAttribute("formattedDate");
    @SuppressWarnings("unchecked")
    List<EmployeeInfoEntity> employees = (List<EmployeeInfoEntity>) request.getAttribute("employees");
    @SuppressWarnings("unchecked")
    List<ConfigCropEntity> crops = (List<ConfigCropEntity>) request.getAttribute("crops");
    @SuppressWarnings("unchecked")
    List<ConfigFarmTaskEntity> tasks = (List<ConfigFarmTaskEntity>) request.getAttribute("tasks");
    @SuppressWarnings("unchecked")
    List<AssignCropToSiteEntity> cropToSites = (List<AssignCropToSiteEntity>) request.getAttribute("cropToSites");

    int currentEmpId       = (assignment.getEmployeeInfoEntity() != null) ? assignment.getEmployeeInfoEntity().getEmployeeInfoId() : -1;
    int currentCropId      = (assignment.getCropEntity()         != null) ? assignment.getCropEntity().getCropId()                 : -1;
    int currentCropToSiteId= (assignment.getCropToSiteEntity()   != null) ? assignment.getCropToSiteEntity().getAssignCroptoSiteId() : -1;
    String curStatus       = assignment.getWorkStatus() != null ? assignment.getWorkStatus() : "";
    String curTypeOfWork   = assignment.getTypeOfWork() != null ? assignment.getTypeOfWork() : "";

    /* build current employee full name for info chip */
    String curEmpName = "";
    if (assignment.getEmployeeInfoEntity() != null) {
        EmployeeInfoEntity ce = assignment.getEmployeeInfoEntity();
        curEmpName = (ce.getFirstName()  != null ? ce.getFirstName()  + " " : "")
                   + (ce.getMiddleName() != null ? ce.getMiddleName() + " " : "")
                   + (ce.getLastName()   != null ? ce.getLastName()          : "");
        curEmpName = curEmpName.trim();
    }
    String curSiteName = (assignment.getCropToSiteEntity() != null && assignment.getCropToSiteEntity().getSiteInformationEntity() != null)
                       ? assignment.getCropToSiteEntity().getSiteInformationEntity().getSiteName() : "";
%>

<div class="edit-wrap">

    <!-- page header -->
    <div class="page-header">
        <a class="back-link" href="<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp">&#8592; Back to All Assignments</a>
        <span style="color:#ccc;">|</span>
        <span class="page-title">Edit Assignment &nbsp;<span style="font-weight:normal;font-size:0.85em;color:var(--text-muted);">#<%=assignment.getAssignResourceId()%></span></span>
    </div>

    <!-- info chips — read-only summary at a glance -->
    <div class="info-bar">
        <% if (!curEmpName.isEmpty()) { %>
        <span class="info-chip"><span class="chip-lbl">Employee:</span><span class="chip-val"><%=curEmpName%></span></span>
        <% } %>
        <% if (formattedDate != null && !formattedDate.isEmpty()) { %>
        <span class="info-chip"><span class="chip-lbl">Work Date:</span><span class="chip-val"><%=formattedDate%></span></span>
        <% } %>
        <% if (!curSiteName.isEmpty()) { %>
        <span class="info-chip"><span class="chip-lbl">Site:</span><span class="chip-val"><%=curSiteName%></span></span>
        <% } %>
        <% if (!curStatus.isEmpty()) { %>
        <span class="info-chip"><span class="chip-lbl">Status:</span>
            <span class="status-pill pill-<%=curStatus%>"><%=curStatus%></span>
        </span>
        <% } %>
    </div>

    <form action="<%=request.getContextPath()%>/AssignResourcesController" method="post" onsubmit="return validate();">
        <input type="hidden" name="hdnAssignResourceId" value="<%=assignment.getAssignResourceId()%>">

        <!-- Section 1: Employee & Date -->
        <div class="form-card">
            <div class="card-title">Employee &amp; Date</div>
            <div class="form-grid col2">
                <div class="field">
                    <label for="selEmpId">Employee Name <span class="req">*</span></label>
                    <select name="selEmpId" id="selEmpId" required>
                        <option value="-1">-- Select Employee --</option>
                        <% if (employees != null) { for (EmployeeInfoEntity emp : employees) {
                            String fn = emp.getFirstName()  != null ? emp.getFirstName().trim()  + " " : "";
                            String mn = emp.getMiddleName() != null ? emp.getMiddleName().trim() + " " : "";
                            String ln = emp.getLastName()   != null ? emp.getLastName().trim()          : "";
                        %>
                        <option value="<%=emp.getEmployeeInfoId()%>"
                            <%=emp.getEmployeeInfoId() == currentEmpId ? "selected" : ""%>><%=fn+mn+ln%></option>
                        <% } } %>
                    </select>
                    <span class="err-msg" id="err_selEmpId"></span>
                </div>
                <div class="field">
                    <label for="txtDate">Work Date <span class="req">*</span></label>
                    <input type="text" name="txtDate" id="txtDate"
                        value="<%=formattedDate != null ? formattedDate : ""%>"
                        placeholder="dd/mm/yyyy" required
                        pattern="(0[1-9]|[12][0-9]|3[01])\/(0[1-9]|1[0-2])\/\d{4}"
                        oninvalid="setCustomValidity('Enter Date: Select From Calendar')"
                        onchange="setCustomValidity('')">
                </div>
            </div>
        </div>

        <!-- Section 2: Site & Crop -->
        <div class="form-card">
            <div class="card-title">Site &amp; Crop Assignment</div>
            <div class="form-grid col2">
                <div class="field">
                    <label for="selCropToSiteId">Crop-Site Assignment</label>
                    <select name="selCropToSiteId" id="selCropToSiteId">
                        <option value="-1">-- Select --</option>
                        <% if (cropToSites != null) { for (AssignCropToSiteEntity cts : cropToSites) {
                            String siteLbl = (cts.getSiteInformationEntity() != null)
                                           ? cts.getSiteInformationEntity().getSiteName()
                                           : "Site " + cts.getAssignCroptoSiteId();
                        %>
                        <option value="<%=cts.getAssignCroptoSiteId()%>"
                            <%=cts.getAssignCroptoSiteId() == currentCropToSiteId ? "selected" : ""%>>
                            <%=siteLbl%> &nbsp;(<%=cts.getCropAssignDate()%>)
                        </option>
                        <% } } %>
                    </select>
                </div>
                <div class="field">
                    <label for="selCropId">Crop</label>
                    <select name="selCropId" id="selCropId">
                        <option value="-1">-- Select Crop --</option>
                        <% if (crops != null) { for (ConfigCropEntity crop : crops) { %>
                        <option value="<%=crop.getCropId()%>"
                            <%=crop.getCropId() == currentCropId ? "selected" : ""%>><%=crop.getCropName()%></option>
                        <% } } %>
                    </select>
                </div>
            </div>
        </div>

        <!-- Section 3: Work Details -->
        <div class="form-card">
            <div class="card-title">Work Details</div>
            <div class="form-grid col3">
                <div class="field">
                    <label for="selWorkType">Type of Work <span class="req">*</span></label>
                    <select name="selWorkType" id="selWorkType" required>
                        <option value="-1">-- Select --</option>
                        <option value="Contract"        <%="Contract".equals(curTypeOfWork)        ? "selected" : ""%>>Contract</option>
                        <option value="Per Day Payment" <%="Per Day Payment".equals(curTypeOfWork) ? "selected" : ""%>>Per Day Payment</option>
                    </select>
                    <span class="err-msg" id="err_selWorkType"></span>
                </div>
                <div class="field">
                    <label for="selWorkStatus">Work Status <span class="req">*</span></label>
                    <select name="selWorkStatus" id="selWorkStatus" required>
                        <option value="-1">-- Select --</option>
                        <option value="Completed" <%="Completed".equals(curStatus) ? "selected" : ""%>>Completed</option>
                        <option value="Pending"   <%="Pending".equals(curStatus)   ? "selected" : ""%>>Pending</option>
                        <option value="Reject"    <%="Reject".equals(curStatus)    ? "selected" : ""%>>Reject</option>
                    </select>
                    <span class="err-msg" id="err_selWorkStatus"></span>
                </div>
                <div class="field">
                    <label for="selWork">Task(s)</label>
                    <select name="selWork" id="selWork" multiple size="4">
                        <% if (tasks != null) {
                            List<ConfigFarmTaskEntity> currentTasks = assignment.getListFarmTaskEntities();
                            for (ConfigFarmTaskEntity task : tasks) {
                                boolean sel = false;
                                if (currentTasks != null) {
                                    for (ConfigFarmTaskEntity ct : currentTasks) {
                                        if (ct.getTaskId() == task.getTaskId()) { sel = true; break; }
                                    }
                                }
                        %>
                        <option value="<%=task.getTaskId()%>" <%=sel ? "selected" : ""%>><%=task.getTaskName()%></option>
                        <% } } %>
                    </select>
                    <span class="hint">Ctrl+click to select multiple tasks</span>
                </div>
            </div>
        </div>

        <!-- Section 4: Payment -->
        <div class="form-card">
            <div class="card-title">Payment</div>
            <div class="form-grid col2">
                <div class="field">
                    <label for="txtAmount">Amount (Rs)</label>
                    <input type="number" name="txtAmount" id="txtAmount"
                           value="<%=assignment.getAmount()%>" step="0.01" min="0" placeholder="0.00">
                </div>
                <div class="field">
                    <label for="txtAdvPayment">Advance Payment (Rs)</label>
                    <input type="number" name="txtAdvPayment" id="txtAdvPayment"
                           value="<%=assignment.getAdvPayment()%>" step="0.01" min="0" placeholder="0.00">
                </div>
            </div>
        </div>

        <!-- Section 5: Remarks -->
        <div class="form-card">
            <div class="card-title">Remarks</div>
            <div class="field">
                <label for="txtComment">Comment</label>
                <textarea name="txtComment" id="txtComment" rows="3"
                          placeholder="Add any notes or remarks here…"><%=assignment.getComment() != null ? assignment.getComment() : ""%></textarea>
            </div>
        </div>

        <!-- Action bar -->
        <div class="action-bar">
            <a class="btn-cancel"
               href="<%=request.getContextPath()%>/view/user/01assignTaskToEmployeeViewAll.jsp">Cancel</a>
            <button type="submit" class="btn-save" name="sbtSave">Save Changes</button>
        </div>

    </form>
</div>
<% } %>
</fieldset>
<%@include file="../../footer.jsp"%>
</body>
</html>
