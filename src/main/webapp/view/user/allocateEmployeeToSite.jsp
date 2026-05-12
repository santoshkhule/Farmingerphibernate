<%@page import="com.san.farm.adminuser.entity.*"%>
<%@page import="com.san.farm.adminuser.dao.*"%>
<%@page import="com.san.farm.util.FarmUtility"%>
<%@page import="java.util.List"%>
<%@ page language="java" contentType="text/html; charset=ISO-8859-1" pageEncoding="ISO-8859-1"%>
<%
    /* ── cropToSiteId ── */
    int cropToSiteId = 0;
    try {
        String ctSid = request.getParameter("cropToSiteId");
        if (ctSid != null && !ctSid.trim().isEmpty()) cropToSiteId = Integer.parseInt(ctSid.trim());
    } catch (Exception ignore) {}

    /* ── site info ── */
    AssignCropToSiteService cropSvc = new AssignCropToSiteService();
    AssignCropToSiteEntity cropToSite = cropSvc.getAssignCropToSiteInfoByCropToSiteId(cropToSiteId);

    /* ── dropdown data ── */
    EmployeeInfoService empSvc = new EmployeeInfoService();
    ConfigFarmTaskService taskSvc = new ConfigFarmTaskService();
    List<EmployeeInfoEntity> employees = empSvc.getListOfEmployee();
    List<ConfigFarmTaskEntity> tasks = taskSvc.fetch();

    /* ── existing allocations for current assignment (stats + display table) ── */
    AssignResourceEmployeeToFarmService allocSvc = new AssignResourceEmployeeToFarmService();
    List<AssignEmployeeToFarmEntity> allocations = allocSvc.getByCropToSiteId(cropToSiteId);

    /* ── site display info ── */
    String siteName = (cropToSite != null && cropToSite.getSiteInformationEntity() != null)
                    ? cropToSite.getSiteInformationEntity().getSiteName() : "Unknown Site";
    String siteDate = (cropToSite != null && cropToSite.getCropAssignDate() != null)
                    ? FarmUtility.convertfrom_yymmddToddmmyy(cropToSite.getCropAssignDate().toString()) : "";

    /* ── crops string ── */
    String cropNamesStr = "";
    if (cropToSite != null && cropToSite.getCropToSiteRefEntity() != null) {
        StringBuilder sb = new StringBuilder();
        for (AssignCropToSiteRefEntity ref : cropToSite.getCropToSiteRefEntity()) {
            if (sb.length() > 0) sb.append(", ");
            sb.append(ref.getConfigCropEntity().getCropName());
        }
        cropNamesStr = sb.toString();
    }

    /* ── totals ── */
    double totalAmount = 0, totalAdv = 0;
    for (AssignEmployeeToFarmEntity a : allocations) {
        totalAmount += a.getAmount();
        totalAdv    += a.getAdvPayment();
    }

    /* ── physical siteInfoId + all site allocations (for duplicate validation) ── */
    int siteInfoId = (cropToSite != null && cropToSite.getSiteInformationEntity() != null)
                   ? cropToSite.getSiteInformationEntity().getSiteInfoId() : 0;
    List<AssignEmployeeToFarmEntity> siteAllocations = siteInfoId > 0
                   ? allocSvc.getListBySiteInfoId(siteInfoId) : allocations;

    /* ── today's date ── */
    String todayStr = new java.text.SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date());
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<link rel="stylesheet" href="../../css/style.css">
<link rel="stylesheet" href="../../css/jquery-ui.css">
<title>Allocate Employees — <%=siteName%></title>
<style>
    .site-banner { background:#e8f5e9; border:1px solid var(--green-bd); border-radius:var(--r-md);
                   padding:8px 16px; margin-bottom:12px; display:flex; align-items:center; gap:18px; flex-wrap:wrap; }
    .site-banner .sb-label { font-size:0.78em; color:var(--text-muted); text-transform:uppercase; }
    .site-banner .sb-val   { font-weight:700; color:var(--green-dk); }
    .stats-bar  { display:flex; gap:12px; flex-wrap:wrap; margin-bottom:12px; }
    .stat-card  { background:#fff; border:1px solid var(--gray-200); border-radius:var(--r-md);
                  padding:8px 18px; min-width:130px; text-align:center; }
    .stat-card .sc-val   { font-size:1.25em; font-weight:700; color:var(--green-dk); }
    .stat-card .sc-label { font-size:0.72em; color:var(--text-muted); text-transform:uppercase; margin-top:2px; }
    .stat-card.highlight { background:#e8f5e9; border-color:var(--green-bd); }
    .section-title { font-weight:700; color:var(--green-dk); font-size:0.95em;
                     border-bottom:2px solid var(--green-bd); padding-bottom:4px;
                     margin:14px 0 8px; display:flex; align-items:center; gap:10px; }
    .back-link  { font-size:12px; color:var(--green-dk); text-decoration:none; }
    .back-link:hover { text-decoration:underline; }
    .btn-add-row { background:#fff; border:1px solid var(--green-dk); color:var(--green-dk);
                   padding:2px 10px; cursor:pointer; border-radius:var(--r-sm);
                   font-size:12px; font-weight:700; }
    .btn-add-row:hover { background:#e8f5e9; }
    .btn-save-all { background:var(--green-dk); color:#fff; border:none; padding:5px 20px;
                    cursor:pointer; border-radius:var(--r-sm); font-size:13px; font-weight:700; }
    .btn-save-all:hover { background:#2e7d32; }
    .btn-remove-row { color:#c62828; border:none; background:none; font-size:16px;
                      cursor:pointer; line-height:1; padding:0 4px; }
    .inp-sm  { font-size:12px; padding:3px 4px; }
    .sel-emp { width:140px; }
    .sel-typework { width:120px; }
    .sel-task { width:150px; }
    .sel-status { width:100px; }
    .inp-num  { width:70px; text-align:right; }
    .inp-date { width:90px; }
    .inp-rem  { width:110px; }
    .status-Pending   { color:#e65100; font-weight:600; }
    .status-Completed { color:#2e7d32; font-weight:600; }
    .status-Rejected  { color:#c62828; font-weight:600; }
    .btn-row-edit   { background:#e8f5e9; border:1px solid var(--green-dk); color:var(--green-dk);
                      padding:2px 8px; cursor:pointer; border-radius:2px; font-size:11px; font-weight:600; }
    .btn-row-edit:hover { background:#c8e6c9; }
    .btn-row-save   { background:#28a745; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; margin-left:2px; }
    .btn-row-cancel { background:#6c757d; color:#fff; border:none; padding:3px 10px;
                      cursor:pointer; border-radius:3px; font-size:12px; margin-left:2px; }
</style>
</head>
<body>
<%@include file="../../header.jsp" %>
<script src="../../js/jquery-ui.js"></script>
<script>
/* ─── Employee options HTML (built from server data) ─── */
var empOptions = '<option value="">-- Select Employee --</option>';
<%
    for (EmployeeInfoEntity e : employees) {
        String fn = e.getFirstName()  != null ? e.getFirstName().trim()  : "";
        String mn = e.getMiddleName() != null && !e.getMiddleName().trim().isEmpty()
                    ? " " + e.getMiddleName().trim() : "";
        String ln = e.getLastName()   != null ? " " + e.getLastName().trim() : "";
        String fullName = (fn + mn + ln).replace("'", "\\'").replace("\"", "&quot;");
%>
empOptions += '<option value="<%=e.getEmployeeInfoId()%>"><%=fullName%></option>';
<% } %>

/* ─── Task options HTML ─── */
var taskOptions = '<option value="">-- Select Task --</option>';
<%
    for (ConfigFarmTaskEntity t : tasks) {
        String tName = t.getTaskName() != null ? t.getTaskName().replace("'", "\\'").replace("\"", "&quot;") : "";
%>
taskOptions += '<option value="<%=t.getTaskId()%>"><%=tName%></option>';
<% } %>

var todayDate = '<%=todayStr%>';

/* ─── Site-wide allocations for duplicate checking (same employee+date+task+site) ─── */
var existingAllocs = [
<%
    for (AssignEmployeeToFarmEntity xa : siteAllocations) {
        int xEmpId = xa.getEmployeeInfoEntity() != null ? xa.getEmployeeInfoEntity().getEmployeeInfoId() : 0;
        if (xEmpId == 0) continue;
        String xDate = xa.getAssignWorkDate() != null
                     ? FarmUtility.convertfrom_yymmddToddmmyy(xa.getAssignWorkDate().toString()) : "";
        if (xa.getListFarmTaskEntities().isEmpty()) {
%>
    {empId:'<%=xEmpId%>', date:'<%=xDate%>', taskId:'0'},
<%
        } else {
            for (ConfigFarmTaskEntity xt : xa.getListFarmTaskEntities()) {
%>
    {empId:'<%=xEmpId%>', date:'<%=xDate%>', taskId:'<%=xt.getTaskId()%>'},
<%
            }
        }
    }
%>
];

$(function() {
    $(".date-inp").datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
});

function validateBeforeSubmit() {
    /* Step 1: populate hidden taskIdsCsv from each row's multi-select */
    $('#empTableBody tr').each(function() {
        var selected = [];
        $(this).find('.task-multi option:selected').each(function() {
            if ($(this).val()) selected.push($(this).val());
        });
        $(this).find('.task-csv').val(selected.join(','));
    });

    var rows  = $('#empTableBody tr');
    var seen  = {};   /* "empId|date|taskId" -> rowNum, per-task granularity */
    var valid = true, msg = '';

    rows.each(function(idx) {
        if (!valid) return false;

        var empSel  = $(this).find('select[name="empId"]');
        var dateInp = $(this).find('input[name="workDate"]');
        var taskSel = $(this).find('.task-multi');

        var empId   = empSel.val() || '';
        var date    = $.trim(dateInp.val());
        if (!empId) return;

        var empName = empSel.find('option:selected').text();

        /* collect selected task IDs */
        var selTasks = [];
        taskSel.find('option:selected').each(function() {
            if ($(this).val()) selTasks.push($(this).val());
        });

        /* check each selected task individually */
        for (var t = 0; t < selTasks.length; t++) {
            var tid = selTasks[t];
            var key = empId + '|' + date + '|' + tid;

            /* within-form duplicate */
            if (seen.hasOwnProperty(key)) {
                var tName = taskSel.find('option[value="' + tid + '"]').text();
                msg = 'Row ' + (idx + 1) + ' duplicates row ' + seen[key] + ':\n'
                    + '"' + empName + '" — ' + (date || 'no date') + ' — task "' + tName + '".\n'
                    + 'Remove or change the duplicate row.';
                valid = false; return false;
            }

            /* against already-saved records (entire physical site) */
            for (var i = 0; i < existingAllocs.length; i++) {
                var ex = existingAllocs[i];
                if (ex.empId === empId && ex.date === date && ex.taskId === tid) {
                    var tName2 = taskSel.find('option[value="' + tid + '"]').text();
                    msg = '"' + empName + '" on ' + (date || 'no date') + ' is already assigned task "'
                        + tName2 + '" at site "<%=siteName%>".\nChange the employee, date or task.';
                    valid = false; return false;
                }
            }

            seen[key] = idx + 1;
        }
    });

    if (!valid) { alert('Duplicate Entry Detected:\n\n' + msg); return false; }
    return true;
}

function addRow() {
    var tr = $('<tr>');
    tr.html(
        '<td><select name="empId" class="inp-sm sel-emp">'      + empOptions  + '</select></td>' +
        '<td><input type="text" name="workDate" class="inp-sm inp-date date-inp-dyn" value="' + todayDate + '" placeholder="dd/mm/yyyy" readonly></td>' +
        '<td><select multiple size="3" class="inp-sm sel-task task-multi">' + taskOptions + '</select>' +
            '<input type="hidden" name="taskIdsCsv" class="task-csv"></td>' +
        '<td><select name="typeOfWork" class="inp-sm sel-typework">' +
            '<option value="Contract">Contract</option>' +
            '<option value="Per Day Payment">Per Day Payment</option>' +
        '</select></td>' +
        '<td><input type="number" name="amount"     class="inp-sm inp-num" value="0" step="0.01" min="0"></td>' +
        '<td><input type="number" name="advPayment" class="inp-sm inp-num" value="0" step="0.01" min="0"></td>' +
        '<td><select name="workStatus" class="inp-sm sel-status">' +
            '<option value="Pending">Pending</option>' +
            '<option value="Completed">Completed</option>' +
            '<option value="Rejected">Rejected</option>' +
        '</select></td>' +
        '<td><input type="text" name="remark" class="inp-sm inp-rem"></td>' +
        '<td style="text-align:center;"><button type="button" class="btn-remove-row" onclick="removeRow(this)">&#10005;</button></td>'
    );
    $('#empTableBody').append(tr);
    tr.find('.date-inp-dyn').datepicker({ changeMonth:true, changeYear:true, dateFormat:"dd/mm/yy" });
}

function removeRow(btn) {
    var rows = document.getElementById('empTableBody').rows;
    if (rows.length <= 1) { alert('At least one row is required.'); return; }
    $(btn).closest('tr').remove();
}

/* ── Inline edit for Already-Assigned rows ── */
var ALLOC_FIELDS = ['Date','Emp','Tasks','TypeOfWork','Amount','AdvPay','Status','Remark'];

function editAllocRow(id) {
    ALLOC_FIELDS.forEach(function(f) {
        var sp  = document.getElementById('view' + f + '_' + id);
        var inp = document.getElementById('edit' + f + '_' + id);
        if (sp)  sp.style.display = 'none';
        if (inp) inp.style.display = '';
    });
    var hint = document.getElementById('editTasksHint_' + id);
    if (hint) hint.style.display = '';
    $('#editDate_' + id).datepicker({ changeMonth:true, changeYear:true, dateFormat:'dd/mm/yy' });
    document.getElementById('btnEdit_'   + id).style.display = 'none';
    document.getElementById('btnRemove_' + id).style.display = 'none';
    document.getElementById('btnSave_'   + id).style.display = '';
    document.getElementById('btnCancel_' + id).style.display = '';
}

function cancelAllocRow(id) {
    ALLOC_FIELDS.forEach(function(f) {
        var sp  = document.getElementById('view' + f + '_' + id);
        var inp = document.getElementById('edit' + f + '_' + id);
        if (sp)  sp.style.display = '';
        if (inp) inp.style.display = 'none';
    });
    var hint = document.getElementById('editTasksHint_' + id);
    if (hint) hint.style.display = 'none';
    document.getElementById('btnEdit_'   + id).style.display = '';
    document.getElementById('btnRemove_' + id).style.display = '';
    document.getElementById('btnSave_'   + id).style.display = 'none';
    document.getElementById('btnCancel_' + id).style.display = 'none';
}

function saveAllocRow(id) {
    /* collect selected task IDs */
    var taskSel = document.getElementById('editTasks_' + id);
    var tids = [];
    for (var i = 0; i < taskSel.options.length; i++) {
        if (taskSel.options[i].selected && taskSel.options[i].value)
            tids.push(taskSel.options[i].value);
    }
    document.getElementById('hidTasksCsv_' + id).value  = tids.join(',');
    document.getElementById('hidEmp_'        + id).value  = document.getElementById('editEmp_'       + id).value;
    document.getElementById('hidDate_'       + id).value  = document.getElementById('editDate_'      + id).value;
    document.getElementById('hidTypeOfWork_' + id).value  = document.getElementById('editTypeOfWork_' + id).value;
    document.getElementById('hidAmount_'     + id).value  = document.getElementById('editAmount_'    + id).value;
    document.getElementById('hidAdvPay_'   + id).value  = document.getElementById('editAdvPay_' + id).value;
    document.getElementById('hidStatus_'   + id).value  = document.getElementById('editStatus_' + id).value;
    document.getElementById('hidRemark_'   + id).value  = document.getElementById('editRemark_' + id).value;
    document.getElementById('frmUpdate_'   + id).submit();
}
</script>

<fieldset>
<legend>Allocate Employees to Site</legend>

<a class="back-link" href="assignCropToSite.jsp">&#8592; Back to Assign Crop To Site</a>

<!-- Site banner -->
<div class="site-banner" style="margin-top:8px;">
    <div><div class="sb-label">Site</div><div class="sb-val"><%=siteName%></div></div>
    <% if (!siteDate.isEmpty()) { %>
    <div><div class="sb-label">Assignment Date</div><div class="sb-val"><%=siteDate%></div></div>
    <% } %>
    <% if (!cropNamesStr.isEmpty()) { %>
    <div><div class="sb-label">Crops</div><div class="sb-val"><%=cropNamesStr%></div></div>
    <% } %>
</div>

<!-- Stats bar -->
<div class="stats-bar">
    <div class="stat-card highlight">
        <div class="sc-val"><%=allocations.size()%></div>
        <div class="sc-label">Assignments</div>
    </div>
    <div class="stat-card highlight">
        <div class="sc-val">&#8377; <%=String.format("%.2f", totalAmount)%></div>
        <div class="sc-label">Total Amount</div>
    </div>
    <div class="stat-card highlight">
        <div class="sc-val">&#8377; <%=String.format("%.2f", totalAdv)%></div>
        <div class="sc-label">Total Advance</div>
    </div>
</div>

<!-- ── New assignment form ── -->
<form method="post" action="<%=request.getContextPath()%>/AllocateEmployeeController"
      onsubmit="return validateBeforeSubmit()">
    <input type="hidden" name="action"      value="save">
    <input type="hidden" name="cropToSiteId" value="<%=cropToSiteId%>">

    <div class="section-title">
        New Employee Assignment
        <button type="button" class="btn-add-row" onclick="addRow()">+ Add Row</button>
    </div>

    <div style="overflow-x:auto;">
    <table border="1" class="tbl-data" width="100%" cellspacing="0">
        <thead>
        <tr>
            <th>Employee</th>
            <th>Date</th>
            <th>Task</th>
            <th>Type of Work</th>
            <th>Amount (Rs)</th>
            <th>Advance (Rs)</th>
            <th>Work Status</th>
            <th>Remark</th>
            <th></th>
        </tr>
        </thead>
        <tbody id="empTableBody">
        <tr>
            <td>
                <select name="empId" class="inp-sm sel-emp">
                    <option value="">-- Select Employee --</option>
                    <% for (EmployeeInfoEntity e : employees) {
                        String fn = e.getFirstName()  != null ? e.getFirstName().trim()  : "";
                        String mn = e.getMiddleName() != null && !e.getMiddleName().trim().isEmpty()
                                    ? " " + e.getMiddleName().trim() : "";
                        String ln = e.getLastName()   != null ? " " + e.getLastName().trim() : "";
                    %>
                    <option value="<%=e.getEmployeeInfoId()%>"><%=fn + mn + ln%></option>
                    <% } %>
                </select>
            </td>
            <td>
                <input type="text" name="workDate" class="inp-sm inp-date date-inp"
                       value="<%=todayStr%>" placeholder="dd/mm/yyyy" readonly>
            </td>
            <td>
                <select multiple size="3" class="inp-sm sel-task task-multi">
                    <% for (ConfigFarmTaskEntity t : tasks) { %>
                    <option value="<%=t.getTaskId()%>"><%=t.getTaskName()%></option>
                    <% } %>
                </select>
                <input type="hidden" name="taskIdsCsv" class="task-csv">
                <div style="font-size:10px;color:var(--text-muted);margin-top:2px;">Ctrl+click to multi-select</div>
            </td>
            <td>
                <select name="typeOfWork" class="inp-sm sel-typework">
                    <option value="Contract">Contract</option>
                    <option value="Per Day Payment">Per Day Payment</option>
                </select>
            </td>
            <td>
                <input type="number" name="amount" class="inp-sm inp-num" value="0" step="0.01" min="0">
            </td>
            <td>
                <input type="number" name="advPayment" class="inp-sm inp-num" value="0" step="0.01" min="0">
            </td>
            <td>
                <select name="workStatus" class="inp-sm sel-status">
                    <option value="Pending">Pending</option>
                    <option value="Completed">Completed</option>
                    <option value="Rejected">Rejected</option>
                </select>
            </td>
            <td>
                <input type="text" name="remark" class="inp-sm inp-rem">
            </td>
            <td style="text-align:center;">
                <button type="button" class="btn-remove-row" onclick="removeRow(this)">&#10005;</button>
            </td>
        </tr>
        </tbody>
    </table>
    </div>

    <div style="margin:10px 0;">
        <button type="submit" class="btn-save-all">Save All</button>
    </div>
</form>

<!-- ── Already assigned ── -->
<div class="section-title" style="margin-top:18px;">
    Already Assigned
    <span style="font-size:0.8em; font-weight:normal; color:var(--text-muted);">(<%=allocations.size()%> record(s))</span>
</div>

<% if (allocations.isEmpty()) { %>
<p style="color:var(--text-muted); font-size:13px;">No employees assigned yet.</p>
<% } else { %>
<div style="overflow-x:auto;">
<table border="1" class="tbl-data" width="100%" cellspacing="0">
    <thead>
    <tr>
        <th>Date</th>
        <th>Employee</th>
        <th>Task(s)</th>
        <th>Type of Work</th>
        <th>Amount (Rs)</th>
        <th>Advance (Rs)</th>
        <th>Status</th>
        <th>Remark</th>
        <th>Action</th>
    </tr>
    </thead>
    <tbody>
    <%
        for (AssignEmployeeToFarmEntity a : allocations) {
            int rid = a.getAssignResourceId();
            EmployeeInfoEntity emp = a.getEmployeeInfoEntity();
            int curEmpId = emp != null ? emp.getEmployeeInfoId() : 0;
            String empFn = emp != null && emp.getFirstName()  != null ? emp.getFirstName().trim()  : "";
            String empMn = emp != null && emp.getMiddleName() != null && !emp.getMiddleName().trim().isEmpty()
                           ? " " + emp.getMiddleName().trim() : "";
            String empLn = emp != null && emp.getLastName()   != null ? " " + emp.getLastName().trim() : "";
            String empName = empFn + empMn + empLn;

            StringBuilder taskNames = new StringBuilder();
            StringBuilder curTaskIdsCsv = new StringBuilder();
            for (ConfigFarmTaskEntity t : a.getListFarmTaskEntities()) {
                if (taskNames.length()    > 0) taskNames.append(", ");
                if (curTaskIdsCsv.length() > 0) curTaskIdsCsv.append(",");
                taskNames.append(t.getTaskName());
                curTaskIdsCsv.append(t.getTaskId());
            }

            String aDate          = a.getAssignWorkDate() != null
                                  ? FarmUtility.convertfrom_yymmddToddmmyy(a.getAssignWorkDate().toString()) : "";
            String statusCls      = "status-" + (a.getWorkStatus() != null ? a.getWorkStatus() : "");
            String comment        = a.getComment()     != null ? a.getComment()     : "";
            String curStatus      = a.getWorkStatus()  != null ? a.getWorkStatus()  : "Pending";
            String curTypeOfWork  = a.getTypeOfWork()  != null ? a.getTypeOfWork()  : "Contract";
    %>
    <tr id="allocRow_<%=rid%>">
        <!-- Date -->
        <td>
            <span id="viewDate_<%=rid%>"><%=aDate%></span>
            <input type="text" id="editDate_<%=rid%>" class="inp-sm inp-date"
                   value="<%=aDate%>" style="display:none;" readonly placeholder="dd/mm/yyyy">
        </td>
        <!-- Employee -->
        <td>
            <span id="viewEmp_<%=rid%>"><%=empName%></span>
            <select id="editEmp_<%=rid%>" class="inp-sm sel-emp" style="display:none;">
                <% for (EmployeeInfoEntity ev : employees) {
                    String efn = ev.getFirstName()  != null ? ev.getFirstName().trim()  : "";
                    String emn = ev.getMiddleName() != null && !ev.getMiddleName().trim().isEmpty()
                                 ? " " + ev.getMiddleName().trim() : "";
                    String eln = ev.getLastName()   != null ? " " + ev.getLastName().trim() : "";
                    String esel = ev.getEmployeeInfoId() == curEmpId ? "selected" : "";
                %>
                <option value="<%=ev.getEmployeeInfoId()%>" <%=esel%>><%=efn+emn+eln%></option>
                <% } %>
            </select>
        </td>
        <!-- Task(s) -->
        <td>
            <span id="viewTasks_<%=rid%>"><%=taskNames.length() > 0 ? taskNames.toString() : "<span style='color:var(--text-muted)'>—</span>"%></span>
            <select id="editTasks_<%=rid%>" multiple size="3" class="inp-sm sel-task" style="display:none;">
                <% for (ConfigFarmTaskEntity tv : tasks) {
                    boolean isSel = false;
                    for (ConfigFarmTaskEntity ct : a.getListFarmTaskEntities()) {
                        if (ct.getTaskId() == tv.getTaskId()) { isSel = true; break; }
                    }
                %>
                <option value="<%=tv.getTaskId()%>" <%=isSel ? "selected" : ""%>><%=tv.getTaskName()%></option>
                <% } %>
            </select>
            <div id="editTasksHint_<%=rid%>" style="font-size:10px;color:var(--text-muted);display:none;">Ctrl+click for multi</div>
        </td>
        <!-- Type of Work -->
        <td style="text-align:center;">
            <span id="viewTypeOfWork_<%=rid%>"><%=curTypeOfWork%></span>
            <select id="editTypeOfWork_<%=rid%>" class="inp-sm sel-typework" style="display:none;">
                <option value="Contract"        <%="Contract".equals(curTypeOfWork)        ? "selected" : ""%>>Contract</option>
                <option value="Per Day Payment" <%="Per Day Payment".equals(curTypeOfWork) ? "selected" : ""%>>Per Day Payment</option>
            </select>
        </td>
        <!-- Amount -->
        <td style="text-align:right;">
            <span id="viewAmount_<%=rid%>"><%=String.format("%.2f", a.getAmount())%></span>
            <input type="number" id="editAmount_<%=rid%>" class="inp-sm inp-num"
                   value="<%=a.getAmount()%>" step="0.01" min="0" style="display:none;">
        </td>
        <!-- Advance -->
        <td style="text-align:right;">
            <span id="viewAdvPay_<%=rid%>"><%=String.format("%.2f", a.getAdvPayment())%></span>
            <input type="number" id="editAdvPay_<%=rid%>" class="inp-sm inp-num"
                   value="<%=a.getAdvPayment()%>" step="0.01" min="0" style="display:none;">
        </td>
        <!-- Status -->
        <td style="text-align:center;">
            <span id="viewStatus_<%=rid%>" class="<%=statusCls%>"><%=curStatus%></span>
            <select id="editStatus_<%=rid%>" class="inp-sm sel-status" style="display:none;">
                <option value="Pending"   <%="Pending".equals(curStatus)   ? "selected" : ""%>>Pending</option>
                <option value="Completed" <%="Completed".equals(curStatus) ? "selected" : ""%>>Completed</option>
                <option value="Rejected"  <%="Rejected".equals(curStatus)  ? "selected" : ""%>>Rejected</option>
            </select>
        </td>
        <!-- Remark -->
        <td>
            <span id="viewRemark_<%=rid%>"><%=comment%></span>
            <input type="text" id="editRemark_<%=rid%>" class="inp-sm inp-rem"
                   value="<%=comment%>" style="display:none;">
        </td>
        <!-- Action -->
        <td style="text-align:center; white-space:nowrap;">
            <button type="button" class="btn-row-edit" id="btnEdit_<%=rid%>"
                    onclick="editAllocRow(<%=rid%>)">Edit</button>

            <span id="btnRemove_<%=rid%>">
            <form method="post" action="<%=request.getContextPath()%>/AllocateEmployeeController" style="display:inline;">
                <input type="hidden" name="action"           value="delete">
                <input type="hidden" name="assignResourceId" value="<%=rid%>">
                <input type="hidden" name="cropToSiteId"     value="<%=cropToSiteId%>">
                <button type="submit" class="btn-delete"
                    onclick="return (window.top||window).confirm('Remove this assignment?')">Remove</button>
            </form>
            </span>

            <!-- Hidden update form — populated and submitted by saveAllocRow() -->
            <form id="frmUpdate_<%=rid%>" method="post"
                  action="<%=request.getContextPath()%>/AllocateEmployeeController">
                <input type="hidden" name="action"           value="update">
                <input type="hidden" name="assignResourceId" value="<%=rid%>">
                <input type="hidden" name="cropToSiteId"     value="<%=cropToSiteId%>">
                <input type="hidden" id="hidEmp_<%=rid%>"          name="empId">
                <input type="hidden" id="hidDate_<%=rid%>"         name="workDate">
                <input type="hidden" id="hidTasksCsv_<%=rid%>"     name="taskIdsCsv">
                <input type="hidden" id="hidTypeOfWork_<%=rid%>"   name="typeOfWork">
                <input type="hidden" id="hidAmount_<%=rid%>"       name="amount">
                <input type="hidden" id="hidAdvPay_<%=rid%>"       name="advPayment">
                <input type="hidden" id="hidStatus_<%=rid%>"       name="workStatus">
                <input type="hidden" id="hidRemark_<%=rid%>"       name="remark">
            </form>

            <button type="button" class="btn-row-save" id="btnSave_<%=rid%>"
                    style="display:none;" onclick="saveAllocRow(<%=rid%>)">Save</button>
            <button type="button" class="btn-row-cancel" id="btnCancel_<%=rid%>"
                    style="display:none;" onclick="cancelAllocRow(<%=rid%>)">Cancel</button>
        </td>
    </tr>
    <% } %>
    </tbody>
    <tfoot>
    <tr style="font-weight:bold;">
        <td colspan="4" style="text-align:right;">Total</td>
        <td style="text-align:right;"><%=String.format("%.2f", totalAmount)%></td>
        <td style="text-align:right;"><%=String.format("%.2f", totalAdv)%></td>
        <td colspan="3"></td>
    </tr>
    </tfoot>
</table>
</div>
<% } %>

</fieldset>
<%@include file="../../footer.jsp" %>
</body>
</html>
